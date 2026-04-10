import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'features/chat/chat_provider.dart';
import 'services/ai/llm_service_v2.dart';
import 'services/ai/offline_tts_service.dart';
import 'services/security/encryption_service.dart';
import 'services/storage/database_service.dart';

void main() async {
  // ── Глобальне налаштування ──────────────────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ВАЖЛИВО: спочатку ключі, потім база
    await EncryptionService().initializeDefaultIfNeeded();

    // ── Ініціалізація БД ────────────────────────────────────────────────────
    await DatabaseService().initialize();
  } catch (e) {
    debugPrint('Помилка ініціалізації сховища: $e');
  }

  await initializeDateFormatting('uk_UA', null);

  // ── Eager-ініціалізація LLM + RAG + TTS ──────────────────────────
  // ВАЖЛИВО: запускаємо ДО першого повідомлення користувача.
  LlmService().initializeAtStartup(); // fire-and-forget, не await
  OfflineTtsService.instance.initialize(); // ініціалізація моделей голосу у фоні
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MolitovnikApp(),
    ),
  );
}
