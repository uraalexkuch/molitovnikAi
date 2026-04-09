import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/message.dart';
import '../ai/embeddings_service.dart';

/// Завантаження бази знань з assets.
class KnowledgeBaseService {
  static final KnowledgeBaseService instance = KnowledgeBaseService._();
  KnowledgeBaseService._();

  final List<KnowledgeChunk> _chunks = [];
  bool _isLoaded = false;

  List<KnowledgeChunk> get allChunks => List.unmodifiable(_chunks);
  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    debugPrint('📚 KnowledgeBase: завантажую базу знань...');

    try {
      await Future.wait([
        _loadAsset('assets/knowledge_base/bible-ohiienko.json', 'bible'),
        _loadAsset('assets/knowledge_base/prayers.json', 'prayers'),
        _loadAsset('assets/knowledge_base/mhz-guides.json', 'mhz-guides'),
      ]);
      _isLoaded = true;
      debugPrint('✅ KnowledgeBase: ${_chunks.length} чанків завантажено');
    } catch (e) {
      debugPrint('⚠️ KnowledgeBase error: $e');
    }
  }

  Future<void> _loadAsset(String path, String source) async {
    try {
      final raw = await rootBundle.loadString(path);
      final data = json.decode(raw) as List;

      for (final item in data) {
        final content = item['content'] as String? ?? '';
        final location = item['location'] as String? ??
            item['reference'] as String? ?? source;

        if (content.length < 10) continue; 

        // Векторизуємо кожен чанк
        final embedding = await EmbeddingsService.instance.embed(
          '$location: $content',
        );

        _chunks.add(KnowledgeChunk(
          id: '${source}_${_chunks.length}',
          content: content,
          source: source,
          location: location,
          embedding: embedding,
        ));
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load $path: $e');
    }
  }
}
