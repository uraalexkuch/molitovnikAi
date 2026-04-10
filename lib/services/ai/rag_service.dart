import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RAGService — виправлена версія.
///
/// ВИПРАВЛЕНО:
///  1. initialize() викликається при старті App (через LlmService.initializeAtStartup)
///  2. JSON-парсинг великих файлів виконується в compute() ізолейті
///  3. _isInitialized правильно захищає від повторного виклику
class RAGService {
  static final RAGService _instance = RAGService._internal();
  factory RAGService() => _instance;
  RAGService._internal();

  List<Map<String, dynamic>> _bibleChunks = [];
  List<Map<String, dynamic>> _prayers = [];
  List<Map<String, dynamic>> _guides = [];

  bool _isInitialized = false;

  /// Ініціалізація — викликати один раз при старті.
  /// JSON-парсинг в ізолейті щоб не блокувати UI thread.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Завантажуємо всі три файли паралельно
      final results = await Future.wait([
        _loadJson('assets/knowledge_base/bible-ohiienko.json'),
        _loadJson('assets/knowledge_base/prayers.json'),
        _loadJson('assets/knowledge_base/mhz-guides.json'),
      ]);

      // Парсимо в ізолейтах паралельно (не блокує UI)
      final parsed = await Future.wait([
        compute(_parseBible, results[0]),
        compute(_parsePrayers, results[1]),
        compute(_parseGuides, results[2]),
      ]);

      _bibleChunks = parsed[0];
      _prayers = parsed[1];
      _guides = parsed[2];

      _isInitialized = true;
      debugPrint(
        '✅ RAG: ${_bibleChunks.length} фрагментів Біблії, '
        '${_prayers.length} молитов, ${_guides.length} гайдів',
      );
    } catch (e) {
      debugPrint('❌ RAGService initialize: $e');
      // Продовжуємо без RAG — модель відповідатиме без контексту
      _isInitialized = true;
    }
  }

  /// Пошук релевантного контексту за запитом
  Future<String> getContext(String query) async {
    if (!_isInitialized) await initialize();

    final results = <String>[];

    final bibleMatches = _searchInList(_bibleChunks, query, limit: 2);
    results.addAll(bibleMatches.map(
      (m) => 'Біблія (${m['book']} ${m['chapter']}:${m['verse']}): ${m['text']}',
    ));

    final prayerMatches = _searchInList(_prayers, query, limit: 2);
    results.addAll(prayerMatches.map(
      (m) => "Молитва '${m['name']}': ${m['text']}",
    ));

    final guideMatches = _searchInList(_guides, query, limit: 1);
    results.addAll(guideMatches.map(
      (m) => "Психологічна порада '${m['title']}': ${m['content']}",
    ));

    if (results.isEmpty) return '';
    return results.join('\n\n');
  }

  // ── Приватні допоміжні ─────────────────────────────────────────────────

  Future<String> _loadJson(String path) async {
    return rootBundle.loadString(path);
  }

  // Функції для compute() — мають бути top-level або static
  static List<Map<String, dynamic>> _parseBible(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['chunks'] as List);
  }

  static List<Map<String, dynamic>> _parsePrayers(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['prayers'] as List);
  }

  static List<Map<String, dynamic>> _parseGuides(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['guides'] as List);
  }

  List<Map<String, dynamic>> _searchInList(
    List<Map<String, dynamic>> list,
    String query, {
    int limit = 2,
  }) {
    final queryLower = query.toLowerCase();
    final words = queryLower
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .toList();

    if (words.isEmpty) return [];

    final scored = <Map<String, dynamic>>[];
    for (final item in list) {
      double score = 0;
      final text = (item['text'] ?? item['content'] ?? '').toString().toLowerCase();
      final title = (item['name'] ?? item['title'] ?? item['book'] ?? '').toString().toLowerCase();
      final tags = (item['tags'] as List<dynamic>?)?.join(' ').toLowerCase() ?? '';
      final context = (item['category'] ?? item['occasion'] ?? '').toString().toLowerCase();

      for (final word in words) {
        if (text.contains(word)) score += 1.0;
        if (title.contains(word)) score += 2.0;
        if (tags.contains(word)) score += 1.5;
        if (context.contains(word)) score += 1.2;
      }

      if (score > 0) scored.add({'item': item, 'score': score});
    }

    scored.sort((a, b) =>
        (b['score'] as double).compareTo(a['score'] as double));

    return scored.take(limit).map((m) => m['item'] as Map<String, dynamic>).toList();
  }
}
