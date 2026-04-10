import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'features/chat/chat_provider.dart';
import 'services/ai/llm_service.dart';
import 'services/storage/database_service.dart';

void main() async {
  // ── Глобальне налаштування ──────────────────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── Ініціалізація БД ────────────────────────────────────────────────────
  await DatabaseService().initialize();
  await initializeDateFormatting('uk_UA', null);

  // ── Eager-ініціалізація LLM + RAG ──────────────────────────────────────
  // ВАЖЛИВО: запускаємо ДО першого повідомлення користувача.
  // Якщо модель не завантажена — initializeAtStartup() просто пропускає.
  // Це усуває зависання при першому запиті в чаті.
  LlmService().initializeAtStartup(); // fire-and-forget, не await

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MolitovnikApp(),
    ),
  );
}
