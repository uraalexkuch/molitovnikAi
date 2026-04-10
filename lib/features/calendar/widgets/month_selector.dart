import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final Function(int) onSelected;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.sp,
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthIndex = index + 1;
          final isSelected = selectedMonth == monthIndex;
          
          // Отримуємо назву місяця українською
          final monthName = DateFormat('MMMM', 'uk_UA').format(DateTime(2026, monthIndex));

          return Padding(
            padding: EdgeInsets.only(right: 8.sp),
            child: ChoiceChip(
              label: Text(monthName),
              selected: isSelected,
              onSelected: (_) => onSelected(monthIndex),
              backgroundColor: Colors.white.withOpacity(0.5),
              selectedColor: AppTheme.ocuBurgundy,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDim,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.ocuBurgundy : AppTheme.goldAccent.withOpacity(0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
