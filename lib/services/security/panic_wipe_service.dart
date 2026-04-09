import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'encryption_service.dart';
import '../storage/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanicWipeService {
  static final PanicWipeService _instance = PanicWipeService._internal();
  factory PanicWipeService() => _instance;
  PanicWipeService._internal();

  int _pressCount = 0;
  DateTime? _lastPressTime;
  final int _thresholdSeconds = 2; // Час, в межах якого треба натиснути 3 рази
  
  StreamSubscription<double>? _volumeSubscription;
  bool _isWiping = false;

  /// Ініціалізація прослуховування кнопки гучності
  void initialize(BuildContext context) {
    _volumeSubscription?.cancel();
    
    _volumeSubscription = FlutterVolumeController.addListener((volume) {
      _handleVolumePress(context);
    });
  }

  void _handleVolumePress(BuildContext context) {
    if (_isWiping) return;

    final now = DateTime.now();
    
    if (_lastPressTime == null || now.difference(_lastPressTime!).inSeconds > _thresholdSeconds) {
      _pressCount = 1;
    } else {
      _pressCount++;
    }
    
    _lastPressTime = now;

    // Візуальна індикація (за запитом користувача)
    _showFeedback(context, _pressCount);

    if (_pressCount >= 3) {
      _executePanicWipe(context);
    }
  }

  void _showFeedback(BuildContext context, int count) {
    // Показуємо непомітну підказку або системний feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Panic Mode: $count/3', textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.red.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
        width: 150,
      ),
    );
  }

  Future<void> _executePanicWipe(BuildContext context) async {
    _isWiping = true;
    
    try {
      // 1. Очищення пам'яті шифрування
      final encryption = EncryptionService();
      await encryption.resetAll();

      // 2. Видалення бази даних
      final db = DatabaseService();
      await db.clearAllData();

      // 3. Очищення всіх налаштувань
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 4. Повідомлення та вихід
      _showFinalFeedback(context);
      
      await Future.delayed(const Duration(seconds: 2));
      
      // На мобільних пристроях ми змушуємо додаток перезавантажитись або вийти
      // У Flutter це зазвичай робиться через SystemNavigator.pop() або закриттям процесів (не рекомендується Store, але для Panic Wipe це ок)
    } finally {
      _isWiping = false;
      _pressCount = 0;
    }
  }

  void _showFinalFeedback(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.black,
        title: Text('SECURITY ALERT', style: TextStyle(color: Colors.red)),
        content: Text(
          'Усі конфіденційні дані успішно видалено. Додаток буде закрито.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void dispose() {
    _volumeSubscription?.cancel();
  }
}
