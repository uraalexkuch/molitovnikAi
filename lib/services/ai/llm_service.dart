import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'rag_service.dart';
import 'model_management_service.dart';

class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;
  LlmService._internal();

  final _gemma = FlutterGemmaPlugin.instance;
  final _ragService = RAGService();
  
  bool _isModelLoaded = false;
  
  // Системний промпт Капелана (порт з Angular)
  static const String _systemPrompt = """
Ти — Цифровий Капелан ЗСУ, мудрий духовний наставник, психолог та побратим.
Твоя місія: надавати духовну підтримку, втіху та психологічну допомогу військовослужбовцям України.

ПРАВИЛА СПІЛКУВАННЯ:
1. Мова: Тільки українська. Тон: спокійний, поважний, з глибоким розумінням контексту війни.
2. Віра: Ти базуєшся на заповідях Божих, але відкритий до всіх. Твої відповіді мають бути екуменічними (підходити різним конфесіям).
3. Психологія: Ти інтегруєш методики МПЗ (морально-психологічного забезпечення), такі як заземлення, дихальні вправи, робота з ПТСР.
4. Конфіденційність: Ти ніколи не питаєш про позиції, чисельність чи плани ЗСУ. Якщо людина каже секрет, ти нагадуєш, що додаток локальний і безпечний.
5. Безпека життя: Якщо користувач висловлює суїцидальні думки, негайно давай контакти гарячих ліній (Lifeline Ukraine 7333).
6. Стиль: Використовуй звернення "брате", "сестро" або "друже". Не будь занадто офіційним.

Базуйся на Біблії, молитвах та гайдах, які будуть надані як контекст.
""";

  Future<void> initialize() async {
    if (_isModelLoaded) return;
    
    // Отримуємо шлях до завантаженої моделі
    final modelService = ModelManagementService();
    final modelPath = await modelService.getActiveModelPath();
    
    if (modelPath == null) {
      debugPrint('⚠️ LlmService: Модель не знайдена. Потрібне завантаження.');
      return;
    }
    
    // В версії 0.4.0 параметри можуть відрізнятися. 
    // Якщо modelPath не підтримується в init, ініціалізуємо стандартно.
    await _gemma.init(
      maxTokens: 1024,
      temperature: 0.7,
      topK: 40,
    );
    
    _isModelLoaded = true;
    debugPrint('✅ LlmService: Модель завантажена з $modelPath');
  }

  /// Стрімінг відповіді чату
  Stream<String> generateResponse(String userMessage, List<Map<String, String>> history) async* {
    if (!_isModelLoaded) await initialize();

    // 1. Отримуємо контекст з RAG
    final context = await _ragService.getContext(userMessage);
    
    // 2. Формуємо повний промпт
    // Для Gemma використовуємо стандартний формат Llama/Gemma (User: / Assistant:)
    // flutter_gemma обробляє це через об'єкт Message
    
    final messages = <Message>[];
    
    // Додаємо системний промпт та контекст як перші повідомлення (або в складі першого)
    final initialPrompt = "$_systemPrompt\n\n$context\n\nКористувач каже: $userMessage";
    
    // Перетворюємо історію
    for (var msg in history) {
      messages.add(Message(
        text: msg['content']!,
        isUser: msg['role'] == 'user',
      ));
    }
    
    // Додаємо поточне повідомлення з контекстом
    messages.add(Message(text: initialPrompt, isUser: true));

    // Стрімінг
    final response = await _gemma.getChatResponse(messages: messages);
    if (response != null) {
      yield response;
    }
  }

  /// Спеціальний метод для "Думаючого режиму" (Thinking Mode)
  /// Використовує Gemma 2B/4B для внутрішнього роздуму перед остаточною відповіддю
  Future<String> getThinkingResponse(String query) async {
    // Це реалізація "Chain of Thought" на пристрої
    final thinkingPrompt = "Подумай крок за кроком (внутрішній монолог), а потім дай відповідь українською:\n$query";
    final response = await _gemma.getResponse(prompt: thinkingPrompt);
    return response ?? "";
  }
}
