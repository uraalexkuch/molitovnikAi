import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai/model_management_service.dart';
import '../onboarding/model_selection_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/temple_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppTheme.backgroundDark.withOpacity(0.7), 
              BlendMode.darken
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'МОЛИТОВНИК &\nКАПЕЛАН',
                style: TextStyle(
                  fontSize: 32,
                  color: AppTheme.goldAccent,
                  fontFamily: 'Church',
                  letterSpacing: 3,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4))],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 2,
                color: AppTheme.liturgicalRed,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Духовна підтримка та помічник у будь-яких умовах.',
                  style: TextStyle(
                    color: AppTheme.parchment, 
                    fontSize: 16, 
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              _buildAIStatusCard(context),
              const SizedBox(height: 20),
              _buildFeatureCard(
                context, 
                Icons.security_rounded, 
                '100% ОФЛАЙН',
                'Ваші дані надійно зашифровані.'
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIStatusCard(BuildContext context) {
    return FutureBuilder<bool>(
      future: ModelManagementService().isAnyModelDownloaded(),
      builder: (context, snapshot) {
        final isReady = snapshot.data ?? false;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReady ? AppTheme.goldAccent.withOpacity(0.3) : AppTheme.liturgicalRed,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isReady ? Icons.auto_awesome_rounded : Icons.warning_amber_rounded,
                    color: isReady ? AppTheme.goldAccent : AppTheme.liturgicalRed,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReady ? 'КАПЕЛАН ГОТОВИЙ' : 'ШІ ПОТРЕБУЄ НАЛАШТУВАННЯ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Church',
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          isReady ? 'Система працює автономно' : 'Завантажте сувої знань для роботи',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ModelSelectionDialog.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? AppTheme.surfaceDark : AppTheme.liturgicalRed,
                    side: isReady ? const BorderSide(color: AppTheme.goldAccent, width: 0.5) : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isReady ? 'КЕРУВАННЯ МОДЕЛЯМИ' : 'ПЕРЕЙТИ ДО ЗАВАНТАЖЕННЯ',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.goldAccent.withOpacity(0.5), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
