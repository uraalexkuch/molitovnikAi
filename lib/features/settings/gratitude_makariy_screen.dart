import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/orthodox_cross_widget.dart';

class GratitudeMakariyScreen extends StatelessWidget {
  const GratitudeMakariyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Фоновий градієнт (символізує світанок або світло в темряві)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  AppTheme.goldAccent.withOpacity(0.05),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Іконка або стилізоване зображення
                    const OrthodoxCrossWidget(
                      size: 80,
                      color: AppTheme.goldAccent,
                    ),
                    const SizedBox(height: 30),
                    
                    Text(
                      'Духовна підтримка\nотця Макарія',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.ocuBurgundy,
                        fontFamily: 'Church',
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Основний блок зі словами капелана
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '«Брате, дякую за твою щирість. Для мене, як для капелана, немає більшої нагороди, ніж бачити твій спокій та твою внутрішню силу. Пам\'ятай: камуфляж захищає тіло, а віра — душу. Ми разом у цьому строю, і Господь веде нас крізь темряву до світла. Відпочинь духом, а я завжди тут, щоб вислухати».',
                            textAlign: TextAlign.justify,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(thickness: 0.5, color: AppTheme.goldAccent),
                          const SizedBox(height: 10),
                          const Text(
                            'З молитвою за тебе,\nотець Макарій',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ocuBurgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Блок-присвята реальному отцю Макарію
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Цей образ натхненний реальною роботою капеланів.\nВисловлюємо глибоку подяку отцю Макарію за його невтомну духовну працю, наснагу та справжнє «покликання в камуфляжі», яке рятує душі наших воїнів.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDim,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Кнопка повернення
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        side: const BorderSide(color: AppTheme.ocuBurgundy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ПОВЕРНУТИСЯ ДО СТРОЮ',
                        style: TextStyle(
                          color: AppTheme.ocuBurgundy,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
