import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'rag_service.dart';
import 'model_management_service.dart';
import '../../core/constants/system_prompt.dart';
import 'package:intl/intl.dart';

class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;
  LlmService._internal();

  final _ragService = RAGService();

  InferenceModel? _model;
  InferenceChat? _chat;
  bool _isModelLoaded = false;
  bool _isInitializing = false;

  // ── Системний промпт береться з констант ──────────────────────────────
  String get _systemPrompt {
    final now = DateTime.now();
    final dateStr = DateFormat('dd.MM.yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);
    
    return """
${SystemPrompt.chaplain}

ПОТОЧНИЙ ЧАС ТА ДАТА: $dateStr, $timeStr.
ВИКОРИСТОВУЙ ЦЮ ІНФОРМАЦІЮ ДЛЯ ОРІЄНТАЦІЇ В ЧАСІ РОЗМОВ (наприклад, "вчора ми говорили про...").
""";
  }

  // Максимальна кількість повідомлень у контексті (8 обмінів = 16 повідомлень)
  static const int _maxContextMessages = 16;

  // ── ПУБЛІЧНИЙ МЕТОД: ініціалізація при старті App ─────────────────────
  Future<void> initializeAtStartup() async {
    if (_isModelLoaded || _isInitializing) return;
    _isInitializing = true;

    try {
      // Ініціалізуємо плагін (Modern API)
      await FlutterGemma.initialize();

      // Паралельно: модель + RAG
      await Future.wait<void>([
        _initModel(),
        _ragService.initialize(),
      ]);
      debugPrint('✅ LlmService + RAG: ініціалізовано');
    } catch (e) {
      debugPrint('❌ LlmService initializeAtStartup: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initModel() async {
    final modelPath = await ModelManagementService().getActiveModelPath();
    if (modelPath == null) {
      debugPrint('⚠️ LlmService: шлях до моделі не знайдено.');
      return;
    }

    final fileType = modelPath.endsWith('.litertlm') 
        ? ModelFileType.litertlm 
        : ModelFileType.task;

    try {
      // Встановлюємо модель як активну
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: fileType,
      ).fromFile(modelPath).install();

      // Отримуємо екземпляр моделі
      _model = await FlutterGemma.getActiveModel(maxTokens: 2048);
      
      // Створюємо чат-сесію
      _chat = await _model!.createChat(
        temperature: 0.7,
        topK: 40,
        systemInstruction: _systemPrompt,
      );

      _isModelLoaded = true;
      debugPrint('✅ Модель завантажена та чат створено: $modelPath');
    } catch (e) {
      debugPrint('❌ Помилка _initModel: $e');
    }
  }

  // ── СТРІМІНГ ВІДПОВІДІ ─────────────────────────────────────────────────
  Stream<String> generateResponse(
    String userMessage,
    List<Map<String, String>> history,
  ) async* {
    if (!_isModelLoaded) {
      await initializeAtStartup();
    }

    if (!_isModelLoaded || _chat == null) {
      yield 'Вибачте, брате. Модель не завантажена. '
          'Будь ласка, завантажте її у налаштуваннях.';
      return;
    }

    try {
      final ragContext = await _ragService.getContext(userMessage);

      // Очищаємо історію чату, щоб синхронізувати з вхідною історією
      await _chat!.clearHistory();

      // Будуємо список повідомлень
      final historySubset = history.length > _maxContextMessages
          ? history.sublist(history.length - _maxContextMessages)
          : history;

      final now = DateTime.now();

      for (var i = 0; i < historySubset.length; i++) {
        final msg = historySubset[i];
        final isUser = msg['role'] == 'user';
        final timestampStr = msg['timestamp'] ?? '';
        var text = msg['content'] ?? '';
        
        // Форматуємо часову мітку для контексту ШІ
        String timePrefix = '';
        if (timestampStr.isNotEmpty) {
          try {
            final ts = DateTime.parse(timestampStr);
            final diff = now.difference(ts).inDays;
            
            if (ts.year == now.year && ts.month == now.month && ts.day == now.day) {
              timePrefix = '[Сьогодні ${DateFormat('HH:mm').format(ts)}] ';
            } else if (diff == 1 || (diff == 0 && ts.day != now.day)) {
              timePrefix = '[Вчора ${DateFormat('HH:mm').format(ts)}] ';
            } else {
              timePrefix = '[${DateFormat('dd.MM HH:mm').format(ts)}] ';
            }
          } catch (e) {
            debugPrint('Помилка парсингу дати: $e');
          }
        }

        final roleLabel = isUser ? 'Користувач' : 'Капелан';
        var formattedText = '$timePrefix$roleLabel: $text';

        // Для RAG додаємо контекст до останнього повідомлення, якщо воно від юзера
        if (i == historySubset.length - 1 && isUser && ragContext.isNotEmpty) {
          formattedText = 'Контекст з бази знань:\n$ragContext\n\n$formattedText';
        }

        await _chat!.addQueryChunk(Message(text: formattedText, isUser: isUser));
      }

      // Додаємо поточне повідомлення
      var currentMessage = userMessage;
      if (ragContext.isNotEmpty && historySubset.isEmpty) {
        currentMessage = 'Контекст з бази знань:\n$ragContext\n\n$currentMessage';
      }

      await _chat!.addQueryChunk(Message(text: currentMessage, isUser: true));

      // Стрімінг відповіді
      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } on Exception catch (e) {
      debugPrint('❌ generateResponse помилка: $e');
      yield '\n\n⚠️ Технічна помилка. Спробуйте ще раз.';
    }
  }
}
