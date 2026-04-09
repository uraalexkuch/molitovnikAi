import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelDownloadService {
  static final ModelDownloadService _instance = ModelDownloadService._internal();
  factory ModelDownloadService() => _instance;
  ModelDownloadService._internal();

  static const String _modelUrl = 'https://huggingface.co/google/gemma-1.1-2b-it-gpu-int4/resolve/main/gemma-1.1-2b-it-gpu-int4.task';
  static const String _modelFileName = 'gemma_model.task';
  static const String _isDownloadedKey = 'is_llm_model_downloaded';

  Future<bool> isModelDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final isDownloaded = prefs.getBool(_isDownloadedKey) ?? false;
    
    if (isDownloaded) {
      final file = File(await getModelPath());
      return await file.exists();
    }
    return false;
  }

  Future<String> getModelPath() async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/$_modelFileName';
  }

  Future<void> startDownload({
    required Function(double) onProgress,
    required Function(String) onCompleted,
    required Function(String) onError,
  }) async {
    final path = await getModelPath();
    
    final task = DownloadTask(
      url: _modelUrl,
      filename: _modelFileName,
      baseDirectory: BaseDirectory.applicationSupport,
      updates: Updates.statusAndProgress,
    );

    FileDownloader().configureNotification(
      running: const TaskNotification('Завантаження ШІ', 'Завантаження моделі Gemma 4...'),
      complete: const TaskNotification('Завантаження завершено', 'Модель готова до роботи'),
      error: const TaskNotification('Помилка завантаження', 'Не вдалося завантажити модель'),
    );

    FileDownloader().registerCallbacks(
      onProgress: (progress) => onProgress(progress),
      onStatus: (status) async {
        if (status == TaskStatus.complete) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isDownloadedKey, true);
          onCompleted(path);
        } else if (status == TaskStatus.failed) {
          onError('Відхилено сервером або немає мережі');
        }
      },
    );

    await FileDownloader().enqueue(task);
  }
}
