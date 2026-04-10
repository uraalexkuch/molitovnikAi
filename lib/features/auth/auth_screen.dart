import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/theme/app_theme.dart';
import '../../services/security/biometric_service.dart';
import '../../services/security/encryption_service.dart';
import '../../app.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _pinController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  final _biometricService = BiometricService.instance;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final enabled = await _biometricService.isBiometricEnabled();
    if (enabled) {
      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        _onSuccess();
      }
    }
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;
    if (pin.length != 4) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final savedPin = await _secureStorage.read(key: 'user_pin');
      
      // Якщо ПІН ще не встановлено, то 0000 - це наш дефолт
      final effectiveSavedPin = savedPin ?? "0000";

      if (pin == effectiveSavedPin) {
        // Обов'язково ініціалізуємо шифрування цим ПІНом перед входом
        await EncryptionService().initialize(pin);
        _onSuccess();
      } else {
        setState(() {
          _errorMessage = 'Невірний PIN-код';
          _pinController.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Помилка доступу';
        _isLoading = false;
      });
    }
  }

  void _onSuccess() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentWhite,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/old_paper3.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_outlined, size: 60, color: AppTheme.ocuBurgundy),
            const SizedBox(height: 10),
            Text(
              'ЗАХИЩЕНИЙ ВХІД',
              style: TextStyle(
                fontFamily: 'Church',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.ocuBurgundy,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
              ),
              child: const Text(
                'Початковий код: 0000\n(змініть його в налаштуваннях)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Відображення введених "зірочок"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool filled = _pinController.text.length > index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.ocuBurgundy, width: 2),
                    color: filled ? AppTheme.ocuBurgundy : Colors.transparent,
                  ),
                );
              }),
            ),
            
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 40),

            // Цифрова клавіатура
            SizedBox(
              width: 280,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) { // Біометрія
                    return IconButton(
                      icon: const Icon(Icons.fingerprint, size: 36, color: AppTheme.ocuBurgundy),
                      onPressed: _checkBiometrics,
                    );
                  }
                  if (index == 11) { // Видалити
                    return IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 28, color: AppTheme.textDim),
                      onPressed: () {
                        if (_pinController.text.isNotEmpty) {
                          setState(() => _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1));
                        }
                      },
                    );
                  }
                  
                  final number = index == 10 ? 0 : index + 1;
                  return _buildNumberButton(number);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return InkWell(
      onTap: () {
        if (_pinController.text.length < 4) {
          setState(() {
            _pinController.text += number.toString();
          });
          if (_pinController.text.length == 4) {
            _verifyPin();
          }
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 22.sp,
            fontFamily: 'Church',
            color: AppTheme.textMain,
          ),
        ),
      ),
    );
  }
}
