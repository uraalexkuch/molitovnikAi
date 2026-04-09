import 'package:flutter/material.dart';
import '../../services/ai/llm_service.dart';
import '../../services/storage/database_service.dart';

class ChatProvider with ChangeNotifier {
  final _llmService = LlmService();
  final _dbService = DatabaseService();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Завантаження історії з БД
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final dbMessages = await _dbService.getMessages();
      _messages = dbMessages.map((m) => {
        'role': m['role'] as String,
        'content': m['content'] as String,
      }).toList();
      _error = '';
    } catch (e) {
      _error = 'Не вдалося завантажити історію повідомлень';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Відправка повідомлення
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Додаємо повідомлення користувача в локальний стейт
    _messages.add({'role': 'user', 'content': text});
    _isLoading = true;
    notifyListeners();

    // 2. Зберігаємо в БД (зашифровано)
    await _dbService.insertMessage('user', text);

    try {
      // 3. Генеруємо відповідь через Gemma
      String fullResponse = "";
      
      // Додаємо пусте повідомлення асистента, яке будемо наповнювати
      _messages.add({'role': 'assistant', 'content': ''});
      final assistantIndex = _messages.length - 1;

      await for (final token in _llmService.generateResponse(text, _messages.sublist(0, _messages.length - 1))) {
        fullResponse += token;
        _messages[assistantIndex]['content'] = fullResponse;
        notifyListeners(); // Стрімінг токенів в UI
      }

      // 4. Зберігаємо фінальну відповідь в БД
      await _dbService.insertMessage('assistant', fullResponse);
      _error = '';
    } catch (e) {
      _error = 'Помилка ШІ: Переконайтеся, що модель завантажена та пристрій має достатньо пам\'яті.';
      _messages.add({'role': 'assistant', 'content': 'Вибачте, сталася технічна помилка. Спробуйте пізніше.'});
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очищення чату (Panic Wipe сумісність)
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
