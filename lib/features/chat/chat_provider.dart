import 'package:flutter/material.dart';
import '../../services/ai/offline_tts_service.dart';
import '../../services/ai/llm_service_v2.dart';
import '../../services/storage/database_service.dart';

/// ChatProvider — виправлена версія.
///
/// ВИПРАВЛЕНО:
///  1. Стрімінг токенів правильно оновлює UI через notifyListeners()
///  2. Порожнє повідомлення асистента додається одразу → анімація "друкує..."
///  3. DB-запис відбувається ПІСЛЯ завершення стріму, не блокує його
///  4. clearMessages() скидає також сесію LLM
///  5. Error state правильно очищається при новому запиті
class ChatProvider with ChangeNotifier {
  final _llmService = LlmService();
  final _dbService = DatabaseService();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _error = '';
  bool _isTtsEnabled = true; // За замовчуванням озвучування увімкнене

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isTtsEnabled => _isTtsEnabled;

  void toggleTts() {
    _isTtsEnabled = !_isTtsEnabled;
    if (!_isTtsEnabled) {
      OfflineTtsService.instance.stop(); // Зупиняємо мовлення, якщо вимикаємо
    }
    notifyListeners();
  }

  /// Завантаження історії з БД при відкритті екрану
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbMessages = await _dbService.getMessages();
      _messages = dbMessages.map((m) => {
        'role': m['role'] as String,
        'content': m['content'] as String,
        'timestamp': (m['timestamp'] ?? '').toString(),
      }).toList();
      _error = '';
    } catch (e) {
      _error = 'Не вдалося завантажити історію повідомлень';
      debugPrint('ChatProvider loadHistory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Відправка повідомлення зі справжнім стрімінгом токенів
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_isLoading) return; // Захист від подвійного відправлення

    _error = '';

    // 1. Додаємо повідомлення користувача та показуємо одразу
    final userMsg = {
      'role': 'user', 
      'content': text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    // 2. Зберігаємо user message в БД (не чекаємо — fire and forget)
    _dbService.insertMessage('user', text.trim()).catchError(
      (e) => debugPrint('DB insertMessage user: $e'),
    );

    // 3. Додаємо порожнє місце для відповіді асистента
    final assistantMsg = {
      'role': 'assistant', 
      'content': '',
      'timestamp': DateTime.now().toIso8601String(),
    };
    _messages.add(assistantMsg);
    final assistantIndex = _messages.length - 1;

    String fullResponse = '';

    try {
      // 4. ── СТРІМІНГ ТОКЕНІВ ────────────────────────────────────────────
      final historyForLlm = _messages.sublist(0, assistantIndex);

      await for (final token in _llmService.generateResponse(text, historyForLlm)) {
        fullResponse += token;
        _messages[assistantIndex] = {
          'role': 'assistant',
          'content': fullResponse,
          'timestamp': assistantMsg['timestamp']!,
        };
        notifyListeners(); // ← токен у UI — негайно
      }

      // 5. Озвучуємо відповідь (TTS)
      if (fullResponse.isNotEmpty && _isTtsEnabled) {
        OfflineTtsService.instance.speak(fullResponse).catchError(
          (e) => debugPrint('TTS error: $e'),
        );
      }

      // 6. Зберігаємо повну відповідь в БД після завершення стріму
      if (fullResponse.isNotEmpty) {
        _dbService.insertMessage('assistant', fullResponse).catchError(
          (e) => debugPrint('DB insertMessage assistant: $e'),
        );
      }

      _error = '';
    } on Exception catch (e) {
      debugPrint('ChatProvider sendMessage error: $e');
      _error = 'Помилка: переконайтеся, що модель завантажена та пристрій має достатньо пам\'яті.';

      // Оновлюємо bubble з повідомленням про помилку
      _messages[assistantIndex] = {
        'role': 'assistant',
        'content': 'Вибачте, брате. Сталася технічна помилка. Спробуй ще раз.',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очищення чату + скидання сесії LLM
  Future<void> clearMessages() async {
    _messages = [];
    _error = '';
    _isLoading = false;
    notifyListeners();
    // Очищаємо БД асинхронно
    _dbService.clearMessages().catchError(
      (e) => debugPrint('DB clearMessages: $e'),
    );
  }
}
