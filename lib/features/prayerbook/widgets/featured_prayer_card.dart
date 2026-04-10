import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/orthodox_cross_widget.dart';

class FeaturedPrayerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPlay;

  const FeaturedPrayerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.sp),
      height: 200.sp,
      decoration: BoxDecoration(
        color: AppTheme.parchmentWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Фоновий хрест (напівпрозорий)
            Positioned(
              right: -20.sp,
              bottom: -20.sp,
              child: OrthodoxCrossWidget(
                size: 150.sp,
                color: AppTheme.goldAccent.withOpacity(0.05),
              ),
            ),
            
            // Текстура паперу (якщо є) - можна додати як Image.asset
            
            Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
                    decoration: BoxDecoration(
                      color: AppTheme.ocuBurgundy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "МОЛИТВА ДНЯ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Church',
                      fontSize: 22.sp,
                      color: AppTheme.ocuBurgundy,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  // Нижня панель з кнопкою аудіо
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: AppTheme.textDim, size: 14.sp),
                          SizedBox(width: 4.sp),
                          Text(
                            "~ 5 хв",
                            style: TextStyle(color: AppTheme.textDim, fontSize: 13.sp),
                          ),
                        ],
                      ),
                      FloatingActionButton.small(
                        onPressed: onPlay,
                        backgroundColor: AppTheme.ocuBurgundy,
                        child: const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
