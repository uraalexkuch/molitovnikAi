import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai/model_management_service.dart';
import '../onboarding/model_selection_dialog.dart';
import '../../core/widgets/orthodox_cross_widget.dart';
import 'widgets/word_of_the_day_card.dart';

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
              Colors.white.withOpacity(0.85),
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 36),

              // ── Логотип ПЦУ (замість хреста) ──
              const OrthodoxCrossWidget(size: 100),
              
              const SizedBox(height: 16),
              
              Text(
                'МОЛИТОВНИК &\nКАПЕЛАН',
                style: TextStyle(
                  fontSize: 32,
                  color: AppTheme.ocuBurgundy,
                  fontFamily: 'Church',
                  letterSpacing: 2.5,
                  shadows: [Shadow(color: AppTheme.goldAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Орнаментальний розподільник
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 1.2, color: AppTheme.ocuBurgundy),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: OrthodoxCrossWidget(
                      size: 20,
                      color: AppTheme.goldAccent.withOpacity(0.4),
                    ),
                  ),
                  Container(width: 40, height: 1.2, color: AppTheme.ocuBurgundy),
                ],
              ),
              
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Духовна підтримка та помічник у будь-яких умовах.',
                  style: TextStyle(
                    color: AppTheme.textDim, 
                    fontSize: 15, 
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              const WordOfTheDayCard(),
              
              const SizedBox(height: 24),
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
        
        if (isReady) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.ocuBurgundy.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.ocuBurgundy,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ШІ ПОТРЕБУЄ НАЛАШТУВАННЯ',
                          style: TextStyle(
                            color: AppTheme.ocuBurgundy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Church',
                          ),
                        ),
                        Text(
                          'Завантажте сувої знань для роботи',
                          style: TextStyle(color: AppTheme.textDim, fontSize: 12),
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
                    backgroundColor: AppTheme.ocuBurgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'ПЕРЕЙТИ ДО ЗАВАНТАЖЕННЯ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.goldAccent.withOpacity(0.5), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    color: AppTheme.textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(
                    color: AppTheme.textDim, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
