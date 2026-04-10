import 'package:flutter/material.dart';
import '../word_of_the_day_service.dart';
import '../../../core/theme/app_theme.dart';

class WordOfTheDayCard extends StatelessWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = WordOfTheDayService.getTodayWord();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceLight,
              AppTheme.surfaceLight.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 20, color: AppTheme.goldAccent),
                  const SizedBox(width: 8),
                  Text(
                    'СЛОВО ДНЯ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppTheme.ocuBurgundy,
                      fontFamily: 'Church',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Цитата з Біблії
              Text(
                '«${word.quote}»',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  word.reference,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDim,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppTheme.goldAccent.withOpacity(0.2)),
              ),
              
              // Коментар капелана
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, size: 24, color: AppTheme.goldAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      word.commentary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppTheme.textMain.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
