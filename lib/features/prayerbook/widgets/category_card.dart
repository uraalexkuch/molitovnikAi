import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/core/theme/app_theme.dart';
import 'package:molitovnik/core/widgets/orthodox_cross_widget.dart';
import 'package:molitovnik/features/prayerbook/prayer_list_screen.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String imgPath;
  final String name;

  const CategoryCard({
    super.key,
    required this.id,
    required this.imgPath,
    required this.name,
  });

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => PrayerListScreen(
          categoryId: id,
          categoryTitle: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      borderRadius: BorderRadius.circular(18.sp),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20.sp),
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
          borderRadius: BorderRadius.circular(20.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Великий центральний хрест замість картинки
              OrthodoxCrossWidget(
                size: 48.sp,
                color: AppTheme.goldAccent.withOpacity(0.15),
              ),
              const Spacer(),
              
              // Назва категорії
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 16.sp,
                  horizontal: 12.sp,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.ocuBurgundy,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.goldAccent.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Church',
                    fontSize: 22.sp,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
