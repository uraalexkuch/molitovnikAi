import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../church_day_model.dart';
import '../../../core/widgets/orthodox_cross_widget.dart';

class ChurchDayCard extends StatelessWidget {
  final ChurchDay day;

  const ChurchDayCard({
    super.key,
    required this.day,
  });

  IconData _getFastingIcon() {
    switch (day.fastingType) {
      case FastingType.strict:      return Icons.close_rounded;
      case FastingType.fishAllowed:  return Icons.set_meal_outlined;
      case FastingType.oilAllowed:   return Icons.opacity_rounded;
      default:                      return Icons.eco_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPast = day.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: AppTheme.parchmentWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: day.isGreatFeast 
              ? AppTheme.goldAccent.withOpacity(0.8) 
              : AppTheme.goldAccent.withOpacity(0.2),
          width: day.isGreatFeast ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: day.isGreatFeast 
                ? AppTheme.goldAccent.withOpacity(0.15) 
                : Colors.black.withOpacity(0.04),
            blurRadius: day.isGreatFeast ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isPast ? 0.7 : 1.0,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Ліва колонка з датою
              Container(
                width: 60.sp,
                padding: EdgeInsets.symmetric(vertical: 12.sp),
                decoration: BoxDecoration(
                  color: day.isGreatFeast 
                      ? AppTheme.goldAccent.withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(day.date),
                      style: TextStyle(
                        fontFamily: 'Church',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: day.isGreatFeast ? AppTheme.ocuBurgundy : AppTheme.textMain,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'uk_UA').format(day.date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDim,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Вертикальний розподільник
              Container(
                width: 0.5,
                color: AppTheme.goldAccent.withOpacity(0.3),
              ),
              
              // Права частина з описом
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (day.isGreatFeast)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.sp),
                          child: Row(
                            children: [
                              const OrthodoxCrossWidget(size: 12, color: AppTheme.goldAccent),
                              SizedBox(width: 4.sp),
                              Text(
                                "ВЕЛИКЕ СВЯТО",
                                style: TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        day.title,
                        style: TextStyle(
                          fontFamily: 'Church',
                          fontSize: 16.sp,
                          fontWeight: day.isGreatFeast ? FontWeight.bold : FontWeight.w500,
                          color: AppTheme.ocuBurgundy,
                          height: 1.2,
                        ),
                      ),
                      if (day.fastingType != FastingType.none) ...[
                        SizedBox(height: 6.sp),
                        Row(
                          children: [
                            Icon(_getFastingIcon(), size: 14.sp, color: Colors.green[800]),
                            SizedBox(width: 4.sp),
                            Text(
                              day.fastingText,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (day.description != null && day.description!.isNotEmpty) ...[
                        SizedBox(height: 6.sp),
                        Text(
                          day.description!,
                          style: TextStyle(
                            color: AppTheme.textDim,
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
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
