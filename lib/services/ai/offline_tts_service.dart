import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'tts_isolate_worker.dart';

/// Сервіс для локального (Offline) синтезу мовлення (TTS).
/// Використовує Sherpa-ONNX (VITS) та модель uk-mykyta в фоновому ізоляті.
class OfflineTtsService {
  static final OfflineTtsService instance = OfflineTtsService._();
  OfflineTtsService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  Isolate? _workerIsolate;
  SendPort? _workerSendPort;
  ReceivePort? _workerResponsePort;
  
  String? _modelPath;
  String? _tokensPath;
  String? _dataDirPath;

  /// Ініціалізація: копіювання моделей та запуск фонового воркера.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Налаштування аудіо-сесії
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      final docDir = await getApplicationDocumentsDirectory();
      final ttsDir = Directory(p.join(docDir.path, 'tts'));
      if (!ttsDir.existsSync()) ttsDir.createSync(recursive: true);

      // Копіюємо основні файли моделі
      _modelPath = p.join(ttsDir.path, 'uk_UA-ukrainian_tts-medium.onnx');
      _tokensPath = p.join(ttsDir.path, 'tokens.txt');
      _dataDirPath = p.join(ttsDir.path, 'espeak-ng-data');

      final modelFiles = {
        'uk_UA-ukrainian_tts-medium.onnx': _modelPath!,
        'tokens.txt': _tokensPath!,
      };

      for (final entry in modelFiles.entries) {
        if (!File(entry.value).existsSync()) {
          final data = await rootBundle.load('assets/tts/${entry.key}');
          await File(entry.value).writeAsBytes(data.buffer.asUint8List());
        }
      }

      await _copyEspeakData(ttsDir.path);

      // Запускаємо ізолят-воркер
      _workerResponsePort = ReceivePort();
      _workerIsolate = await Isolate.spawn(ttsIsolateMain, _workerResponsePort!.sendPort);
      
      // Перше повідомлення від ізоляту - його SendPort
      _workerSendPort = await _workerResponsePort!.first as SendPort;

      _isInitialized = true;
      debugPrint('✅ OfflineTtsService: ізолят запущено та ініціалізовано');
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService init error: $e');
    }
  }

  Future<void> _copyEspeakData(String ttsPath) async {
    final targetBase = p.join(ttsPath, 'espeak-ng-data');
    final filesToCopy = [
      'config', 'phontab', 'phonindex', 'phondata', 'intonations', 'uk_dict', 'lang/zle/uk',
    ];

    for (final relativePath in filesToCopy) {
      final assetPath = 'assets/tts/espeak-ng-data/$relativePath';
      final targetPath = p.join(targetBase, relativePath);
      final targetFile = File(targetPath);
      
      if (targetFile.existsSync()) continue;

      try {
        final data = await rootBundle.load(assetPath);
        if (!targetFile.parent.existsSync()) targetFile.parent.createSync(recursive: true);
        await targetFile.writeAsBytes(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('⚠️ Помилка копіювання $assetPath: $e');
      }
    }
  }

  /// Озвучити текст через фоновий ізолят
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return;
    }

    try {
      await stop();

      // Створюємо тимчасовий порт для отримання результату саме для ЦЬОГО запиту
      final tempPort = ReceivePort();
      
      _workerSendPort!.send(TtsIsolateRequest(
        text: text,
        modelPath: _modelPath!,
        tokensPath: _tokensPath!,
        dataDirPath: _dataDirPath!,
        replyTo: tempPort.sendPort, // Передаємо порт для відповіді
      ));

      // Чекаємо на відповідь від конкретного порту
      final response = await tempPort.first;
      tempPort.close(); // Обов'язково закриваємо після отримання

      if (response is! TtsIsolateResponse) return;
      final ttsResponse = response;

      if (ttsResponse.error != null) {
        debugPrint('❌ Isolate error: ${ttsResponse.error}');
        return;
      }

      if (ttsResponse.audioBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'temp_speech.wav'));
      await tempFile.writeAsBytes(ttsResponse.audioBytes!, flush: true);

      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService stop error: $e');
    }
  }

  void dispose() {
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerResponsePort?.close();
    _audioPlayer.dispose();
  }
}