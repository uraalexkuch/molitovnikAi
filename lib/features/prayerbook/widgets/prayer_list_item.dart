import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/theme/app_theme.dart';

enum PrayerSectionType { morning, battle, evening, other }

class PrayerListItem extends StatelessWidget {
  final String title;
  final String description;
  final int durationMinutes;
  final bool hasAudio;
  final PrayerSectionType type;
  final VoidCallback onTap;

  const PrayerListItem({
    super.key,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.hasAudio,
    required this.type,
    required this.onTap,
  });

  Color _getStripeColor() {
    switch (type) {
      case PrayerSectionType.morning: return AppTheme.morningStripe;
      case PrayerSectionType.battle:  return AppTheme.battleStripe;
      case PrayerSectionType.evening: return AppTheme.eveningStripe;
      default:                        return AppTheme.goldAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: AppTheme.parchmentWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Кольорова смужка зліва
              Container(
                width: 6.sp,
                color: _getStripeColor(),
              ),
              
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(12.sp),
                    child: Row(
                      children: [
                        // Текстова частина
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Church',
                                  fontSize: 17.sp,
                                  color: AppTheme.ocuBurgundy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.sp),
                              Text(
                                description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.textDim,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Мета-дані (аудіо + час)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasAudio)
                              Icon(Icons.volume_up, color: AppTheme.goldAccent, size: 16.sp),
                            SizedBox(height: 4.sp),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "$durationMinutes хв",
                                style: TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.sp),
                        Icon(Icons.chevron_right, color: AppTheme.goldAccent.withOpacity(0.5)),
                      ],
                    ),
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
