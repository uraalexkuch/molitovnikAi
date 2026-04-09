import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Семантичні вектори для RAG.
/// Порт з Angular: embeddings.service.ts
class EmbeddingsService {
  static final EmbeddingsService instance = EmbeddingsService._();
  EmbeddingsService._();

  EmbeddingModel? _embedder;
  bool _isReady = false;

  Future<void> initialize() async {
    try {
      _embedder = await FlutterGemmaPlugin.instance.createEmbeddingModel();
      _isReady = true;
      debugPrint('✅ EmbeddingsService: готово');
    } catch (e) {
      debugPrint('⚠️ EmbeddingsService: використовую hash fallback ($e)');
      _isReady = false;
    }
  }

  Future<List<double>> embed(String text) async {
    if (_isReady && _embedder != null) {
      try {
        return await _embedder!.getEmbedding(text);
      } catch (_) {}
    }
    return _hashFallback(text);
  }

  /// Hash-based fallback — детерміністичний, без моделі.
  /// Порт з Angular embeddings.service.ts
  List<double> _hashFallback(String text) {
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
