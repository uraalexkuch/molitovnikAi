import 'dart:convert';
import 'dart:math';
import 'dart:convert' show base64, utf8;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pointycastle/export.dart' as pc;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final String _saltKey = 'chaplain_encryption_salt_v1';
  final int _iterations = 100000;
  
  encrypt.Key? _key;

  /// Ініціалізація шифрування за допомогою PIN-коду
  Future<void> initialize(String pin) async {
    if (pin.length < 4) {
      throw Exception('PIN-код має містити мінімум 4 цифри');
    }

    final salt = await _getOrCreateSalt();
    final derivedKeyBytes = _deriveKey(pin, salt);
    _key = encrypt.Key(derivedKeyBytes);
  }

  /// Шифрування тексту (AES-GCM)
  String encryptText(String text) {
    if (_key == null) throw Exception('Шифрування не ініціалізовано');
    
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.gcm));
    
    final encrypted = encrypter.encrypt(text, iv: iv);
    
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
    combined.setAll(0, iv.bytes);
    combined.setAll(iv.bytes.length, encrypted.bytes);
    
    return base64.encode(combined);
  }

  /// Дешифрування тексту (AES-GCM)
  String decryptText(String encryptedBase64) {
    if (_key == null) throw Exception('Шифрування не ініціалізовано');
    
    final combined = base64.decode(encryptedBase64);
    if (combined.length < 12) throw Exception('Некоректні зашифровані дані');
    
    final iv = encrypt.IV(combined.sublist(0, 12));
    final ciphertext = combined.sublist(12);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.gcm));
    
    try {
      return encrypter.decrypt(encrypt.Encrypted(ciphertext), iv: iv);
    } catch (e) {
      throw Exception('Помилка дешифрування: невірний PIN або пошкоджені дані');
    }
  }

  bool get isInitialized => _key != null;

  void clearKey() {
    _key = null;
  }

  /// Повне очищення (Panic Wipe)
  Future<void> resetAll() async {
    _key = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saltKey);
    await _secureStorage.deleteAll();
  }

  /// Отримання або створення солі
  Future<Uint8List> _getOrCreateSalt() async {
    final prefs = await SharedPreferences.getInstance();
    String? saltBase64 = prefs.getString(_saltKey);
    
    if (saltBase64 == null) {
      final random = Random.secure();
      final salt = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
      saltBase64 = base64.encode(salt);
      await prefs.setString(_saltKey, saltBase64);
      return salt;
    }
    
    return base64.decode(saltBase64);
  }

  /// Реалізація PBKDF2 через HMAC-SHA256 (PointyCastle)
  Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = pc.KeyDerivator('SHA-256/HMAC/PBKDF2');
    final params = pc.Pbkdf2Parameters(salt, _iterations, 32); // 32 bytes for AES-256
    derivator.init(params);
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }
}
