import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'rag_service.dart';
import 'model_management_service.dart';
import '../../core/constants/system_prompt.dart';
import 'package:intl/intl.dart';

/// LlmService — версія з правильним стрімінгом та пам'яттю.
class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;
  LlmService._internal();

  final _ragService = RAGService();

  InferenceModel? _model;
  InferenceChat? _chat;
  bool _isModelLoaded = false;
  bool _isInitializing = false;

  String get _systemPrompt {
    final now = DateTime.now();
    final dateStr = DateFormat('dd.MM.yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);
    
    return """
${SystemPrompt.chaplain}

ПОТОЧНИЙ ЧАС ТА ДАТА: $dateStr, $timeStr.
ВИКОРИСТОВУЙ ЦЮ ІНФОРМАЦІЮ ДЛЯ ОРІЄНТАЦІЇ В ЧАСІ РОЗМОВ.
""";
  }

  static const int _maxContextMessages = 16;

  Future<void> initializeAtStartup() async {
    if (_isModelLoaded || _isInitializing) return;
    _isInitializing = true;
    try {
      // Даємо системі час на фіналізацію файлових операцій після завантаження
      await Future.delayed(const Duration(milliseconds: 500));
      
      await FlutterGemma.initialize();
      await Future.wait([_initModel(), _ragService.initialize()]);
    } catch (e) {
      debugPrint('❌ LlmService: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initModel() async {
    final modelPath = await ModelManagementService().getActiveModelPath();
    if (modelPath == null) return;
    final fileType = modelPath.endsWith('.litertlm') ? ModelFileType.litertlm : ModelFileType.task;
    try {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt, fileType: fileType).fromFile(modelPath).install();
      _model = await FlutterGemma.getActiveModel(maxTokens: 2048);
      _chat = await _model!.createChat(temperature: 0.7, topK: 40, systemInstruction: _systemPrompt);
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('❌ _initModel: $e');
    }
  }

  Stream<String> generateResponse(String userMessage, List<Map<String, String>> history) async* {
    if (!_isModelLoaded) await initializeAtStartup();
    if (!_isModelLoaded || _chat == null) {
      yield 'Модель не завантажена.';
      return;
    }
    try {
      final ragContext = await _ragService.getContext(userMessage);
      await _chat!.clearHistory();
      final historySubset = history.length > _maxContextMessages ? history.sublist(history.length - _maxContextMessages) : history;
      final now = DateTime.now();
      for (var i = 0; i < historySubset.length; i++) {
        final msg = historySubset[i];
        final isUser = msg['role'] == 'user';
        final timestampStr = msg['timestamp'] ?? '';
        var text = msg['content'] ?? '';
        String timePrefix = '';
        if (timestampStr.isNotEmpty) {
          try {
            final ts = DateTime.parse(timestampStr);
            if (ts.year == now.year && ts.month == now.month && ts.day == now.day) {
              timePrefix = '[Сьогодні ${DateFormat('HH:mm').format(ts)}] ';
            } else {
              timePrefix = '[${DateFormat('dd.MM HH:mm').format(ts)}] ';
            }
          } catch (e) {}
        }
        final roleLabel = isUser ? 'Користувач' : 'Капелан';
        var formattedText = '$timePrefix$roleLabel: $text';
        if (i == historySubset.length - 1 && isUser && ragContext.isNotEmpty) {
          formattedText = 'Контекст з бази знань:\n$ragContext\n\n$formattedText';
        }
        await _chat!.addQueryChunk(Message(text: formattedText, isUser: isUser));
      }
      var currentMessage = userMessage;
      if (ragContext.isNotEmpty && historySubset.isEmpty) {
        currentMessage = 'Контекст з бази знань:\n$ragContext\n\n$currentMessage';
      }
      await _chat!.addQueryChunk(Message(text: currentMessage, isUser: true));
      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) yield response.token;
      }
    } catch (e) {
      yield 'Помилка.';
    }
  }
}
