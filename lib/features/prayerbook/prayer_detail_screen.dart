import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';
import 'package:molitovnik/core/theme/app_theme.dart';
import 'package:molitovnik/core/widgets/orthodox_cross_widget.dart';
import '../../services/ai/offline_tts_service.dart';

class PrayerDetailScreen extends StatefulWidget {
  final String prayerId;

  const PrayerDetailScreen({
    super.key,
    required this.prayerId,
  });

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  bool _isPlaying = false;
  String _title = "";
  String _fullText = "";

  @override
  void initState() {
    super.initState();
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == widget.prayerId);
    _title = selectedMeal.title;
    // Об'єднуємо всі кроки молитви в один текст для озвучення
    _fullText = selectedMeal.steps.join(".\n");
  }

  @override
  void dispose() {
    // Обов'язково зупиняємо аудіо при виході з екрана
    if (_isPlaying) {
      OfflineTtsService.instance.stop();
    }
    super.dispose();
  }

  void _toggleAudio() async {
    final tts = OfflineTtsService.instance;
    if (_isPlaying) {
      // Зупиняємо читання
      await tts.stop();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      
      // Додаємо атмосферний вступ від імені капелана перед читанням
      final speechText = "Помолимося разом, брате. $_title. $_fullText";
      
      await tts.speak(speechText);
      // Коли відтворення завершиться, скидаємо стан
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == widget.prayerId);

    return Scaffold(
      backgroundColor: AppTheme.parchmentWhite,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/old_paper3.jpg"),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 18.h,
              pinned: true,
              backgroundColor: AppTheme.chestnutHeader,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  selectedMeal.title,
                  style: TextStyle(
                    fontFamily: 'Church',
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.1,
                      child: OrthodoxCrossWidget(
                        size: 80.sp,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Міні-кнопка в шапці також залишається синхронізованою
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                    color: AppTheme.goldAccent,
                    size: 24.sp,
                  ),
                  onPressed: _toggleAudio,
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.sp, 25.sp, 20.sp, 80.sp), // Відступ знизу для FAB
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stepTitle = selectedMeal.titlestep.length > index 
                        ? selectedMeal.titlestep[index] 
                        : null;
                    final stepText = selectedMeal.steps[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 25.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (stepTitle != null) ...[
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  color: AppTheme.ocuBurgundy,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    stepTitle.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Church',
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ocuBurgundy,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.sp),
                          ],
                          Text(
                            stepText,
                            style: TextStyle(
                              fontFamily: 'Church',
                              fontSize: 18.sp,
                              color: AppTheme.textMain,
                              height: 1.6,
                            ),
                          ),
                          if (index < selectedMeal.steps.length - 1)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.sp),
                              child: Center(
                                child: OrthodoxCrossWidget(
                                  size: 20.sp,
                                  color: AppTheme.goldAccent.withOpacity(0.3),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: selectedMeal.steps.length,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // РОЗШИРЕНА КНОПКА СЛУХАТИ
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: _toggleAudio,
          backgroundColor: _isPlaying ? AppTheme.surfaceLight : AppTheme.ocuBurgundy,
          foregroundColor: _isPlaying ? AppTheme.ocuBurgundy : Colors.white,
          elevation: _isPlaying ? 2 : 6,
          icon: Icon(
            _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, 
            size: 22.sp
          ),
          label: Text(
            _isPlaying ? 'ЗУПИНИТИ ЧИТАННЯ' : 'СЛУХАТИ КАПЕЛАНА',
            style: TextStyle(
              fontFamily: 'Church',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
