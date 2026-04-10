import 'dart:convert';
import 'package:flutter/services.dart';
import 'church_day_model.dart';

class CalendarService {
  static Future<List<ChurchDay>> loadCalendarData(int targetYear) async {
    try {
      final String response = await rootBundle.loadString('assets/data/church_calendar.json');
      final data = json.decode(response);
      
      List<ChurchDay> days = [];
      
      // Шукаємо блок даних для потрібного року
      final years = data['years'] as List;
      final yearData = years.firstWhere(
        (element) => element['year'] == targetYear,
        orElse: () => null,
      );

      if (yearData != null) {
        for (var item in yearData['holidays']) {
          days.add(ChurchDay.fromJson(item));
        }
      }
      
      // Сортування від найближчого
      days.sort((a, b) => a.date.compareTo(b.date));
      return days;
    } catch (e) {
      print('Помилка завантаження календаря: $e');
      return [];
    }
  }
}
