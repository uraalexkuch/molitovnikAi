import 'package:flutter/material.dart';
import '../../services/security/biometric_service.dart';
import '../../services/security/encryption_service.dart';
import '../../services/storage/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/model_selection_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService.instance;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
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
              activeColor: AppTheme.liturgicalRed,
              title: const Text('Біометричний вхід'),
              subtitle: const Text('Вхід без вводу PIN-коду', style: TextStyle(color: Colors.white38)),
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
            title: const Text('Змінити PIN-код'),
            leading: const Icon(Icons.lock_outline, color: AppTheme.goldAccent),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {},
          ),
          const Divider(color: Colors.white10),
          
          _buildSectionTitle('Штучний інтелект'),
          ListTile(
            title: const Text('Керування моделями'),
            subtitle: const Text('Завантаження та вибір сувоїв знань', style: TextStyle(color: Colors.white38)),
            leading: const Icon(Icons.auto_awesome_rounded, color: AppTheme.goldAccent),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () => ModelSelectionDialog.show(context),
          ),
          const Divider(color: Colors.white10),

          _buildSectionTitle('Конфіденційність'),
          ListTile(
            title: const Text('Очистити історію чату'),
            subtitle: const Text('Видаляє всі повідомлення з бази', style: TextStyle(color: Colors.white38)),
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.orange),
            onTap: () => _confirmAction(
              context, 
              'Видалити історію?', 
              () => DatabaseService().clearAllData()
            ),
          ),
          const Divider(color: Colors.white10),
          
          _buildSectionTitle('Panic Wipe (Екстрений режим)', color: AppTheme.liturgicalRed),
          const ListTile(
            title: Text('Активація через Volume Down'),
            subtitle: Text('Швидке натискання 3 рази для знищення даних', style: TextStyle(color: Colors.white38)),
            leading: Icon(Icons.warning_amber_rounded, color: AppTheme.liturgicalRed),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.liturgicalRed, 
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
        backgroundColor: AppTheme.surfaceDark,
        title: Text(title, style: TextStyle(color: isCritical ? AppTheme.liturgicalRed : AppTheme.goldAccent)),
        content: Text(
          isCritical 
            ? 'Ця дія безповоротна. Усі ключі, повідомлення та налаштування будуть стерті!' 
            : 'Ви впевнені?',
          style: const TextStyle(color: AppTheme.parchment),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('СКАСУВАТИ', style: TextStyle(color: Colors.white54))
          ),
          TextButton(
            onPressed: () {
              action();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Виконано успішно'), backgroundColor: AppTheme.liturgicalRed)
              );
            }, 
            child: Text('ТАК, ВИКОНАТИ', style: TextStyle(color: isCritical ? Colors.red : Colors.blue))
          ),
        ],
      ),
    );
  }
}
