import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Overlay завантаження моделі при першому запуску.
/// Показує прогрес: "Завантаження моделі Gemma... 45%"
class InitOverlayWidget extends StatelessWidget {
  final ValueNotifier<(int, String)> progress;
  final String status;

  const InitOverlayWidget({
    super.key,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark.withOpacity(0.96),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Свічка-іконка
              const Text('🕯️', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              Text(
                'Молитовник & Капелан',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                'Духовна підтримка захисників України',
                style: TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Прогрес-бар
              ValueListenableBuilder<(int, String)>(
                valueListenable: progress,
                builder: (context, val, _) {
                  final (percent, msg) = val;
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percent > 0 ? percent / 100 : null,
                          backgroundColor:
                              AppTheme.goldAccent.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.goldAccent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        msg,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (percent > 0 && percent < 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$percent%',
                            style: TextStyle(
                              color: AppTheme.goldAccent.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Підказка при першому завантаженні
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldAccent.withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  '📱 При першому запуску завантажується модель Gemma.\n'
                  'Потрібне з\'єднання з інтернетом один раз.\n'
                  'Далі — повністю офлайн.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
