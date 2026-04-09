import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class RAGService {
  static final RAGService _instance = RAGService._internal();
  factory RAGService() => _instance;
  RAGService._internal();

  final _gemma = FlutterGemmaPlugin.instance;
  
  List<Map<String, dynamic>> _bibleChunks = [];
  List<Map<String, dynamic>> _prayers = [];
  List<Map<String, dynamic>> _guides = [];

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Завантаження JSON активів
    final bibleData = await rootBundle.loadString('assets/knowledge_base/bible-ohiienko.json');
    _bibleChunks = List<Map<String, dynamic>>.from(json.decode(bibleData)['chunks']);

    final prayersData = await rootBundle.loadString('assets/knowledge_base/prayers.json');
    _prayers = List<Map<String, dynamic>>.from(json.decode(prayersData)['prayers']);

    final guidesData = await rootBundle.loadString('assets/knowledge_base/mhz-guides.json');
    _guides = List<Map<String, dynamic>>.from(json.decode(guidesData)['guides']);

    _isInitialized = true;
  }

  /// Пошук релевантного контексту за запитом
  Future<String> getContext(String query) async {
    if (!_isInitialized) await initialize();

    // 1. Спрощений пошук за ключовими словами (Fallback)
    // В ідеалі тут має бути cosine similarity через Gemma Embeddings,
    // але для мобільної версії та швидкості почнемо з гібридного пошуку.
    
    final results = <String>[];
    
    // Шукаємо в Біблії
    final bibleMatches = _searchInList(_bibleChunks, query, limit: 2);
    results.addAll(bibleMatches.map((m) => "Біблія (${m['book']} ${m['chapter']}:${m['verse']}): ${m['text']}"));

    // Шукаємо в молитвах
    final prayerMatches = _searchInList(_prayers, query, limit: 2);
    results.addAll(prayerMatches.map((m) => "Молитва '${m['name']}': ${m['text']}"));

    // Шукаємо в гайдах МПЗ
    final guideMatches = _searchInList(_guides, query, limit: 1);
    results.addAll(guideMatches.map((m) => "Психологічна порада '${m['title']}': ${m['content']}"));

    if (results.isEmpty) return "";
    
    return "Ось релевантна інформація з бази знань:\n\n" + results.join("\n\n");
  }

  List<Map<String, dynamic>> _searchInList(List<Map<String, dynamic>> list, String query, {int limit = 2}) {
    final queryLower = query.toLowerCase();
    final words = queryLower.split(' ').where((w) => w.length > 3).toList();
    
    if (words.isEmpty) return [];

    final scored = list.map((item) {
      double score = 0;
      final text = (item['text'] ?? item['content'] ?? '').toString().toLowerCase();
      final title = (item['name'] ?? item['title'] ?? item['book'] ?? '').toString().toLowerCase();
      final tags = (item['tags'] as List<dynamic>?)?.join(' ').toLowerCase() ?? '';
      final context = (item['category'] ?? item['occasion'] ?? '').toString().toLowerCase();

      for (var word in words) {
        if (text.contains(word)) score += 1.0;
        if (title.contains(word)) score += 2.0;
        if (tags.contains(word)) score += 1.5;
        if (context.contains(word)) score += 1.2;
      }
      
      return {'item': item, 'score': score};
    }).where((m) => (m['score'] as double) > 0).toList();



    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored.take(limit).map((m) => m['item'] as Map<String, dynamic>).toList();
  }
}
