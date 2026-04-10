import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/orthodox_cross_widget.dart';

class PrayerHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const PrayerHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.sp,
        bottom: 20.sp,
        left: 20.sp,
        right: 20.sp,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.chestnutHeader,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                      onPressed: onBack,
                    )
                  : const OrthodoxCrossWidget(size: 24, color: AppTheme.goldAccent),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Church',
                  fontSize: 20.sp,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.search, color: Colors.white70),
            ],
          ),
          SizedBox(height: 15.sp),
          // Підзаголовок або іконки категорій
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HeaderIconButton(icon: Icons.wb_sunny_outlined, label: "Ранок", color: AppTheme.morningStripe),
              _HeaderIconButton(icon: Icons.shield_outlined, label: "Бій", color: AppTheme.battleStripe),
              _HeaderIconButton(icon: Icons.nightlight_outlined, label: "Вечір", color: AppTheme.eveningStripe),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderIconButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 4.sp),
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
