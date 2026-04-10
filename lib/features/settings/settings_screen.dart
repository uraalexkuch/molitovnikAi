import 'package:flutter/material.dart';
import '../../services/security/biometric_service.dart';
import '../../services/security/encryption_service.dart';
import '../../services/storage/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/model_selection_dialog.dart';
import 'gratitude_makariy_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService.instance;
  final _secureStorage = const FlutterSecureStorage();
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    setState(() {
      _isBiometricAvailable = available;
      _biometricEnabled = enabled;
    });
  }

  void _showPinSetupDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('Встановіть PIN-код', style: TextStyle(color: AppTheme.ocuBurgundy, fontFamily: 'Church')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Цей код захистить ваш додаток та зашифрує повідомлення.', style: TextStyle(color: AppTheme.textMain)),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textMain, fontSize: 24, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '****',
                hintStyle: TextStyle(color: AppTheme.textDim.withOpacity(0.3)),
                counterText: "",
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.goldAccent)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.ocuBurgundy)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('СКАСУВАТИ', style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () async {
              if (pinController.text.length == 4) {
                // 1. Зберігаємо ПІН у безпечне сховище
                await _secureStorage.write(key: 'user_pin', value: pinController.text);
                
                // 2. Ініціалізуємо шифрування бази даних з новим ПІНом
                await EncryptionService().initialize(pinController.text);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN-код успішно встановлено'),
                      backgroundColor: AppTheme.ocuBurgundy,
                    ),
                  );
                }
              }
            },
            child: const Text('ЗБЕРЕГТИ', style: TextStyle(color: AppTheme.ocuBurgundy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
        title: const Text('Налаштування'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Автентифікація'),
          if (_isBiometricAvailable)
            SwitchListTile(
              activeThumbColor: AppTheme.ocuBurgundy,
              title: const Text('Біометричний вхід', style: TextStyle(color: AppTheme.textMain)),
              subtitle: const Text('Вхід без вводу PIN-коду', style: TextStyle(color: AppTheme.textDim)),
              value: _biometricEnabled,
              onChanged: (bool value) async {
                if (value) {
                  await _biometricService.setBiometricEnabled(true);
                } else {
                  await _biometricService.disableBiometrics();
                }
                setState(() => _biometricEnabled = value);
              },
            ),
          ListTile(
            title: const Text('Змінити PIN-код', style: TextStyle(color: AppTheme.textMain)),
            leading: const Icon(Icons.lock_outline, color: AppTheme.ocuBurgundy),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
            onTap: _showPinSetupDialog,
          ),
          const Divider(color: Colors.white10),
          
          _buildSectionTitle('Штучний інтелект'),
          ListTile(
            title: const Text('Керування моделями', style: TextStyle(color: AppTheme.textMain)),
            subtitle: const Text('Завантаження та вибір сувоїв знань', style: TextStyle(color: AppTheme.textDim)),
            leading: const Icon(Icons.auto_awesome_rounded, color: AppTheme.ocuBurgundy),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
            onTap: () => ModelSelectionDialog.show(context),
          ),
          const Divider(color: Colors.white10),

          _buildSectionTitle('Конфіденційність'),
          ListTile(
            title: const Text('Очистити історію чату', style: TextStyle(color: AppTheme.textMain)),
            subtitle: const Text('Видаляє всі повідомлення з бази', style: TextStyle(color: AppTheme.textDim)),
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.orange),
            onTap: () => _confirmAction(
              context, 
              'Видалити історію?', 
              () => DatabaseService().clearAllData()
            ),
          ),
          const Divider(color: Colors.white10),
          
          
          _buildSectionTitle('Panic Wipe (Екстрений режим)', color: AppTheme.ocuBurgundy),
          const ListTile(
            title: Text('Активація через Volume Down', style: TextStyle(color: AppTheme.textMain)),
            subtitle: Text('Швидке натискання 3 рази для знищення даних', style: TextStyle(color: AppTheme.textDim)),
            leading: Icon(Icons.warning_amber_rounded, color: AppTheme.ocuBurgundy),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocuBurgundy, 
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              onPressed: () => _confirmAction(
                context, 
                'ЗНИЩИТИ ВСІ ДАНІ?', 
                () => EncryptionService().resetAll(),
                isCritical: true,
              ),
              child: const Text('АКТИВУВАТИ PANIC WIPE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = AppTheme.goldAccent}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          fontFamily: 'Church',
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, Function() action, {bool isCritical = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: Text(title, style: TextStyle(color: isCritical ? AppTheme.ocuBurgundy : AppTheme.goldAccent)),
        content: Text(
          isCritical 
            ? 'Ця дія безповоротна. Усі ключі, повідомлення та налаштування будуть стерті!' 
            : 'Ви впевнені?',
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('СКАСУВАТИ', style: TextStyle(color: AppTheme.textDim))
          ),
          TextButton(
            onPressed: () {
              action();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Виконано успішно'), backgroundColor: AppTheme.ocuBurgundy)
              );
            }, 
            child: Text('ТАК, ВИКОНАТИ', style: TextStyle(color: isCritical ? Colors.red : Colors.blue))
          ),
        ],
      ),
    );
  }
}
