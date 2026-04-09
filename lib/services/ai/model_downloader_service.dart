import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Завантаження .task файлу моделі при першому запуску.
class ModelDownloaderService {
  static final ModelDownloaderService instance = ModelDownloaderService._();
  ModelDownloaderService._();

  static const _modelKey = 'model_downloaded_v1';

  // Джерело: https://huggingface.co/litert-community/gemma-3-1B-IT
  static const _modelUrl =
      'https://huggingface.co/litert-community/gemma-3-1B-IT/resolve/main/gemma3-1b-it-int4.task';
  static const _modelFileName = 'gemma3-1b-it-int4.task';

  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<String> downloadStatus = ValueNotifier('');

  Future<String?> getModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_modelKey) != true) return null;
    final file = await _modelFile();
    return file.existsSync() ? file.path : null;
  }

  Future<bool> isModelDownloaded() async {
    final path = await getModelPath();
    return path != null;
  }

  Future<String> downloadModel() async {
    final file = await _modelFile();

    if (file.existsSync()) {
      await _markDownloaded();
      return file.path;
    }

    downloadStatus.value = 'Підключення до сервера...';
    downloadProgress.value = 0.0;

    final dio = Dio();
    try {
      await dio.download(
        _modelUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            downloadProgress.value = progress;
            final mb = (received / 1024 / 1024).toStringAsFixed(0);
            final totalMb = (total / 1024 / 1024).toStringAsFixed(0);
            downloadStatus.value =
                'Завантаження Gemma ($mb / $totalMb MB)...';
          }
        },
      );

      await _markDownloaded();
      downloadStatus.value = '✅ Модель завантажена!';
      downloadProgress.value = 1.0;
      debugPrint('✅ Модель збережена: ${file.path}');
      return file.path;
    } catch (e) {
      if (file.existsSync()) await file.delete();
      downloadStatus.value = '❌ Помилка завантаження';
      debugPrint('❌ Download error: $e');
      rethrow;
    }
  }

  Future<File> _modelFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_modelFileName');
  }

  Future<void> _markDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modelKey, true);
  }

  Future<void> deleteModel() async {
    final file = await _modelFile();
    if (file.existsSync()) await file.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_modelKey);
    downloadProgress.value = 0.0;
    downloadStatus.value = '';
    debugPrint('🗑️ Модель видалена');
  }
}
