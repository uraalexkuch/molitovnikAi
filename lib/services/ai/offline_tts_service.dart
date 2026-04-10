import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Сервіс для локального (Offline) синтезу мовлення (TTS).
/// Використовує Sherpa-ONNX (VITS) та модель uk-mykyta.
class OfflineTtsService {
  static final OfflineTtsService instance = OfflineTtsService._();
  OfflineTtsService._();

  sherpa.OfflineTts? _tts;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Ініціалізація: копіювання моделей з assets у файлову систему пристрою.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Налаштування аудіо-сесії (ВИПРАВЛЕННЯ 3)
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      final docDir = await getApplicationDocumentsDirectory();
      final ttsDir = Directory(p.join(docDir.path, 'tts'));
      if (!ttsDir.existsSync()) ttsDir.createSync(recursive: true);

      // 1. Копіюємо основні файли моделі
      final modelFiles = [
        'uk_UA-ukrainian_tts-medium.onnx',
        'tokens.txt',
      ];

      for (final file in modelFiles) {
        final targetPath = p.join(ttsDir.path, file);
        if (!File(targetPath).existsSync()) {
          final data = await rootBundle.load('assets/tts/$file');
          final bytes = data.buffer.asUint8List();
          await File(targetPath).writeAsBytes(bytes);
        }
      }

      // 2. Копіюємо espeak-ng-data (ВИПРАВЛЕННЯ 2)
      await _copyEspeakData(ttsDir.path);

      final modelConfig = sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: p.join(ttsDir.path, 'uk_UA-ukrainian_tts-medium.onnx'),
          lexicon: "",
          tokens: p.join(ttsDir.path, 'tokens.txt'),
          dataDir: p.join(ttsDir.path, 'espeak-ng-data'),
          noiseScale: 0.667,
          noiseScaleW: 0.8,
        ),
        numThreads: 1,
        debug: kDebugMode,
        provider: "cpu",
      );

      _tts = sherpa.OfflineTts(
        sherpa.OfflineTtsConfig(
          model: modelConfig,
          ruleFsts: "",
        ),
      );

      _isInitialized = true;
      debugPrint('✅ OfflineTtsService: ініціалізовано');
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService init error: $e');
    }
  }

  /// Копіювання espeak-ng-data (ВИПРАВЛЕННЯ 2)
  Future<void> _copyEspeakData(String ttsPath) async {
    final targetBase = p.join(ttsPath, 'espeak-ng-data');
    
    // Список обов'язкових файлів та піддиректорій для української мови
    final filesToCopy = [
      'config',
      'phontab',
      'phonindex',
      'phondata',
      'intonations',
      'uk_dict',
      'lang/zle/uk', // Східнослов'янська група
    ];

    for (final relativePath in filesToCopy) {
      final assetPath = 'assets/tts/espeak-ng-data/$relativePath';
      final targetPath = p.join(targetBase, relativePath);
      
      final targetFile = File(targetPath);
      if (targetFile.existsSync()) continue;

      try {
        final data = await rootBundle.load(assetPath);
        if (!targetFile.parent.existsSync()) {
          targetFile.parent.createSync(recursive: true);
        }
        await targetFile.writeAsBytes(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('⚠️ Помилка копіювання $assetPath: $e');
      }
    }
  }

  /// Озвучити текст (ВИПРАВЛЕННЯ 4: Race condition fix)
  Future<void> speak(String text) async {
    if (!_isInitialized || _tts == null) {
      await initialize();
      if (!_isInitialized || _tts == null) return;
    }

    try {
      await stop();

      final audio = await Task.run(() => _tts!.generate(text: text, sid: 0, speed: 1.0));
      if (audio.samples.isEmpty) return;

      final wavData = _createWavHeader(
        audio.samples.length,
        audio.sampleRate.toInt(),
      );

      final int16Samples = Int16List(audio.samples.length);
      for (var i = 0; i < audio.samples.length; i++) {
        int16Samples[i] = (audio.samples[i] * 32767).clamp(-32768, 32767).toInt();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'temp_speech.wav'));

      final builder = BytesBuilder();
      builder.add(wavData);
      builder.add(int16Samples.buffer.asUint8List());

      // Чекаємо повного запису файлу перед відтворенням
      await tempFile.writeAsBytes(builder.toBytes(), flush: true);

      // Встановлюємо шлях і чекаємо ініціалізації плеєра
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService speak error: $e');
    }
  }

  /// Зупинити відтворення
  Future<void> stop() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint('⚠️ OfflineTtsService stop error: $e');
    }
  }

  /// Створення 44-байтного WAV заголовку (PCM)
  Uint8List _createWavHeader(int numSamples, int sampleRate) {
    const channels = 1;
    final byteRate = sampleRate * channels * 2;
    const blockAlign = channels * 2;
    final dataSize = numSamples * channels * 2;
    final fileSize = 36 + dataSize;

    final header = ByteData(44);

    // RIFF
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);

    // WAVE
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little); // subchunk1size (PCM = 16)
    header.setUint16(20, 1, Endian.little);  // audioFormat (1 = PCM)
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little); // bitsPerSample

    // data
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    return header.buffer.asUint8List();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}