import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/chat/chat_provider.dart';
import 'services/ai/rag_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Орієнтація: тільки портрет (для польового використання)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Попередня ініціалізація бази знань (RAG)
  await RAGService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MolitovnikApp(),
    ),
  );
}
