import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/theme/app_theme.dart';
import '../../pages/Data/dummy_data.dart';
import 'widgets/prayer_header.dart';
import 'widgets/featured_prayer_card.dart';
import 'widgets/category_chip_bar.dart';
import 'widgets/prayer_list_item.dart';
import 'prayer_list_screen.dart';
import 'prayer_detail_screen.dart';
import '../../services/ai/offline_tts_service.dart';

class PrayerbookScreen extends StatefulWidget {
  const PrayerbookScreen({super.key});

  @override
  State<PrayerbookScreen> createState() => _PrayerbookScreenState();
}

class _PrayerbookScreenState extends State<PrayerbookScreen> {
  String _selectedCategory = "Всі";
  final List<String> _categories = ["Всі", "Ранкові", "Бойові", "Вечірні", "Псалми"];

  PrayerSectionType _getTypeForMeal(String mealId) {
    if (mealId == 'm1') return PrayerSectionType.morning;
    if (mealId == 'm2') return PrayerSectionType.evening;
    if (mealId == 'm5' || mealId == 'm6') return PrayerSectionType.battle;
    if (mealId == 'm3' || mealId == 'm4') return PrayerSectionType.battle;
    return PrayerSectionType.other;
  }

  void _navigateToDetail(BuildContext context, String id, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerDetailScreen(prayerId: id),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Фільтрація (спрощена для демонстрації)
    final filteredMeals = DUMMY_MEALS.where((meal) {
      if (_selectedCategory == "Всі") return true;
      if (_selectedCategory == "Ранкові") return meal.id == 'm1';
      if (_selectedCategory == "Вечірні") return meal.id == 'm2';
      if (_selectedCategory == "Бойові") return ['m3', 'm4', 'm5'].contains(meal.id);
      if (_selectedCategory == "Псалми") return meal.id == 'm6';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.parchmentWhite,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/old_paper3.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2, // Дуже легка текстура, щоб не заважати читанню
          ),
        ),
        child: Column(
          children: [
            const PrayerHeader(title: "Молитовник"),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FeaturedPrayerCard(
                    title: "Молитва воїна перед битвою",
                    subtitle: "Спасителю мій, Ти поклав за нас життя Своє, щоб спасти нас. Озброй мене силою та мужністю...",
                    onPlay: () async {
                      // Викликаємо озвучення конкретно цієї молитви з атмосферним вступом
                      final tts = OfflineTtsService.instance;
                      await tts.stop(); // Зупиняємо попереднє, якщо грало
                      await tts.speak(
                        "Помолимося перед битвою. "
                        "Спасителю мій, Ти поклав за нас життя Своє, щоб спасти нас. "
                        "Ти заповідав і нам покладати життя своє за друзів наших. "
                        "Озброй мене силою та мужністю на подолання ворогів наших. Амінь."
                      );
                    },
                  ),
                  
                  CategoryChipBar(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                    child: Text(
                      _selectedCategory == "Всі" ? "ОСНОВНІ МОЛИТВИ" : _selectedCategory.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  
                  ...filteredMeals.map((meal) => PrayerListItem(
                    title: meal.title,
                    description: meal.titlestep.first,
                    durationMinutes: meal.duration,
                    hasAudio: true, // В офлайні аудіо доступне для всіх через TTS
                    type: _getTypeForMeal(meal.id),
                    onTap: () => _navigateToDetail(context, meal.id, meal.title),
                  )),
                  
                  SizedBox(height: 30.sp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
