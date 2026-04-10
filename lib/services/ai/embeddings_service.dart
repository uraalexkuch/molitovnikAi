import 'package:flutter/foundation.dart';

/// Семантичні вектори для RAG.
class EmbeddingsService {
  static final EmbeddingsService instance = EmbeddingsService._();
  EmbeddingsService._();


  Future<void> initialize() async {
    // У flutter_gemma 0.4.6 немає EmbeddingModel,
    // тому відразу використовуємо надійний хеш-метод (Fallback).
    debugPrint('✅ EmbeddingsService: готово (Hash Mode)');
  }

  Future<List<double>> embed(String text) async {
    return hashFallbackSync(text);
  }

  /// Hash-based fallback — детерміністичний, без моделі (доступний для Isolates).
  static List<double> hashFallbackSync(String text) {
    const dim = 384;
    final embedding = List<double>.filled(dim, 0.0);
    final tokens = text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2);

    for (final token in tokens) {
      final h1 = token.hashCode;
      final h2 = '${token}salt'.hashCode;
      embedding[h1.abs() % dim] += 1.0;
      embedding[h2.abs() % dim] += 0.7;
    }

    final norm = embedding.fold(0.0, (s, v) => s + v * v);
    final sqrtNorm = norm > 0 ? norm : 1.0;
    return embedding.map((v) => v / sqrtNorm).toList();
  }

  /// Cosine similarity між двома векторами
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = normA * normB;
    return denom > 0 ? dot / denom : 0.0;
  }
}