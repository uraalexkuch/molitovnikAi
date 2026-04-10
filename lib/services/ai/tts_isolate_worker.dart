import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Запит на генерацію мовлення
class TtsIsolateRequest {
  final String text;
  final String modelPath;
  final String tokensPath;
  final String dataDirPath;
  final double speed;
  final SendPort replyTo;

  TtsIsolateRequest({
    required this.text,
    required this.modelPath,
    required this.tokensPath,
    required this.dataDirPath,
    required this.replyTo,
    this.speed = 1.0,
  });
}

/// Відповідь від ізоляту
class TtsIsolateResponse {
  final Uint8List? audioBytes;
  final String? error;

  TtsIsolateResponse({this.audioBytes, this.error});
}

/// Точка входу для ізоляту
void ttsIsolateMain(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  sherpa.OfflineTts? tts;

  await for (final message in receivePort) {
    if (message is TtsIsolateRequest) {
      try {
        // Ініціалізуємо двигун, якщо він ще не створений
        if (tts == null) {
          final modelConfig = sherpa.OfflineTtsModelConfig(
            vits: sherpa.OfflineTtsVitsModelConfig(
              model: message.modelPath,
              lexicon: "",
              tokens: message.tokensPath,
              dataDir: message.dataDirPath,
              noiseScale: 0.667,
              noiseScaleW: 0.8,
            ),
            numThreads: 1,
            debug: kDebugMode,
            provider: "cpu",
          );

          tts = sherpa.OfflineTts(
            sherpa.OfflineTtsConfig(
              model: modelConfig,
              ruleFsts: "",
            ),
          );
        }

        // Генерація
        final audio = tts.generate(
          text: message.text, 
          sid: 0, 
          speed: message.speed
        );

        if (audio.samples.isEmpty) {
          message.replyTo.send(TtsIsolateResponse(error: "Empty samples generated"));
          continue;
        }

        // Енкудування у WAV (PCM 16-bit)
        final wavHeader = _createWavHeader(audio.samples.length, audio.sampleRate.toInt());
        
        final int16Samples = Int16List(audio.samples.length);
        for (var i = 0; i < audio.samples.length; i++) {
          int16Samples[i] = (audio.samples[i] * 32767).clamp(-32768, 32767).toInt();
        }

        final builder = BytesBuilder();
        builder.add(wavHeader);
        builder.add(int16Samples.buffer.asUint8List());
        
        message.replyTo.send(TtsIsolateResponse(audioBytes: builder.toBytes()));

      } catch (e) {
        message.replyTo.send(TtsIsolateResponse(error: e.toString()));
      }
    }
 else if (message == "stop") {
      // Можна додати логіку зупинки, якщо API дозволяє
    }
  }
}

/// Створення WAV заголовку (PCM)
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
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, 16, Endian.little); 

  // data
  header.setUint8(36, 0x64); // d
  header.setUint8(37, 0x61); // a
  header.setUint8(38, 0x74); // t
  header.setUint8(39, 0x61); // a
  header.setUint32(40, dataSize, Endian.little);

  return header.buffer.asUint8List();
}
