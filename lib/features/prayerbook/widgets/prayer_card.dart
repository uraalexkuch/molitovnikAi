import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/core/theme/app_theme.dart';
import 'package:molitovnik/core/widgets/orthodox_cross_widget.dart';
import 'package:molitovnik/features/prayerbook/prayer_detail_screen.dart';

class PrayerCard extends StatelessWidget {
  final String id;
  final String title;
  final String imgPath;

  const PrayerCard({
    super.key,
    required this.id,
    required this.title,
    required this.imgPath,
  });

  void selectPrayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerDetailScreen(prayerId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectPrayer(context),
      borderRadius: BorderRadius.circular(16.sp),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          color: AppTheme.surfaceLight,
          border: Border.all(
            color: AppTheme.goldAccent.withOpacity(0.2),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.sp),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.goldAccent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OrthodoxCrossWidget(
                        size: 32.sp,
                        color: AppTheme.goldAccent.withOpacity(0.2),
                      ),
                      SizedBox(height: 12.sp),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Church',
                          fontSize: 20.sp,
                          color: AppTheme.textMain,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Нижня інформаційна смужка
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                color: AppTheme.ocuBurgundy.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ЧИТАТИ МОЛИТВУ',
                      style: TextStyle(
                        fontFamily: 'Church',
                        fontSize: 14.sp,
                        color: AppTheme.ocuBurgundy,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppTheme.ocuBurgundy.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
