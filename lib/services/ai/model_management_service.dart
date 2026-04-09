import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIModel {
  final String id;
  final String name;
  final String description;
  final String url;
  final String fileName;
  final double sizeInGb;

  AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.fileName,
    required this.sizeInGb,
  });
}

class ModelManagementService {
  static final ModelManagementService _instance = ModelManagementService._internal();
  factory ModelManagementService() => _instance;
  ModelManagementService._internal();

  static const String _currentModelIdKey = 'current_llm_model_id';
  static const String _modelPrefixKey = 'is_model_downloaded_';

  final List<AIModel> availableModels = [
    AIModel(
      id: 'gemma_1b',
      name: 'Gemma 3 1B IT (Lite)',
      description: 'Швидка та легка модель. Ідеально для телефонів з середніми характеристиками.',
      url: 'https://huggingface.co/litert-community/gemma-3-1B-IT/resolve/main/gemma3-1b-it-int4.task',
      fileName: 'gemma3_1b_it_int4.task',
      sizeInGb: 0.8,
    ),
    AIModel(
      id: 'gemma_2b',
      name: 'Gemma 2 2B IT (Pro)',
      description: 'Вища якість відповідей. Потребує більше оперативної пам\'яті (8ГБ+).',
      url: 'https://huggingface.co/google/gemma-2-2b-it-gpu-int4/resolve/main/gemma-2-2b-it-gpu-int4.task',
      fileName: 'gemma2_2b_it_int4.task',
      sizeInGb: 1.4,
    ),
  ];

  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<bool> isDownloading = ValueNotifier(false);

  Future<bool> isAnyModelDownloaded() async {
    for (var model in availableModels) {
      if (await isModelDownloaded(model.id)) return true;
    }
    return false;
  }

  Future<bool> isModelDownloaded(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    final isDownloaded = prefs.getBool('$_modelPrefixKey$modelId') ?? false;
    
    if (isDownloaded) {
      final file = File(await getModelPath(modelId));
      return await file.exists();
    }
    return false;
  }

  Future<String> getModelPath(String modelId) async {
    final directory = await getApplicationSupportDirectory();
    final model = availableModels.firstWhere((m) => m.id == modelId);
    return '${directory.path}/${model.fileName}';
  }

  Future<String?> getActiveModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    final modelId = prefs.getString(_currentModelIdKey);
    if (modelId != null && await isModelDownloaded(modelId)) {
      return getModelPath(modelId);
    }
    
    // Fallback до першої завантаженої моделі
    for (var model in availableModels) {
      if (await isModelDownloaded(model.id)) {
        await prefs.setString(_currentModelIdKey, model.id);
        return getModelPath(model.id);
      }
    }
    return null;
  }

  Future<void> downloadModel(AIModel model, {required Function(String) onCompleted, required Function(String) onError}) async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    final path = await getModelPath(model.id);
    
    final task = DownloadTask(
      url: model.url,
      filename: model.fileName,
      baseDirectory: BaseDirectory.applicationSupport,
      updates: Updates.statusAndProgress,
    );

    FileDownloader().configureNotification(
      running: TaskNotification('Цифровий Капелан', 'Завантаження моделі ${model.name}...'),
      complete: const TaskNotification('Завантаження завершено', 'Модель готова до роботи'),
      error: const TaskNotification('Помилка', 'Не вдалося завантажити модель'),
    );

    FileDownloader().updates.listen((update) async {
      if (update is TaskProgressUpdate && update.task.taskId == task.taskId) {
        downloadProgress.value = update.progress;
      } else if (update is TaskStatusUpdate && update.task.taskId == task.taskId) {
        final status = update.status;
        if (status == TaskStatus.complete) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('$_modelPrefixKey${model.id}', true);
          await prefs.setString(_currentModelIdKey, model.id);
          isDownloading.value = false;
          onCompleted(path);
        } else if (status == TaskStatus.failed || status == TaskStatus.canceled) {
          isDownloading.value = false;
          onError('Відхилено сервером або немає мережі');
        }
      }
    });

    await FileDownloader().enqueue(task);
  }
}
