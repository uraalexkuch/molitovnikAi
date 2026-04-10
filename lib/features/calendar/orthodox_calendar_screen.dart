import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'church_day_model.dart';
import 'calendar_service.dart';

class OrthodoxCalendarScreen extends StatelessWidget {
  const OrthodoxCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календар ПЦУ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<ChurchDay>>(
        future: CalendarService.loadCalendarData(currentYear),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Помилка завантаження календаря або дані відсутні.'),
            );
          }

          final days = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final bool isPast = day.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
              
              return Opacity(
                opacity: isPast ? 0.6 : 1.0, // Минулі свята трохи прозорі
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: day.isGreatFeast 
                          ? Colors.amber.withOpacity(0.5) 
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd').format(day.date),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: day.isGreatFeast ? Colors.red[700] : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            DateFormat('MMM', 'uk_UA').format(day.date),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      day.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: day.isGreatFeast ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (day.fastingType != FastingType.none)
                          Row(
                            children: [
                              Icon(Icons.eco_outlined, size: 14, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                day.fastingText,
                                style: TextStyle(color: Colors.green[700], fontSize: 12),
                              ),
                            ],
                          ),
                        if (day.description != null && day.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            day.description!,
                            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
