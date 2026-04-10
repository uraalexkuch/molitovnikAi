import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/orthodox_cross_widget.dart';

class CalendarHeader extends StatelessWidget {
  final String title;

  const CalendarHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.sp,
        bottom: 15.sp,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const OrthodoxCrossWidget(size: 24, color: AppTheme.goldAccent),
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
          const Icon(Icons.calendar_month, color: Colors.white70),
        ],
      ),
    );
  }
}
