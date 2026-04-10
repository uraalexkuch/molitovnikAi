import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/theme/app_theme.dart';

class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 8.sp),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: EdgeInsets.only(right: 8.sp),
          child: ChoiceChip(
            label: Text(cat),
            selected: selectedCategory == cat,
            onSelected: (_) => onSelected(cat),
            backgroundColor: Colors.white,
            selectedColor: AppTheme.ocuBurgundy,
            labelStyle: TextStyle(
              color: selectedCategory == cat ? Colors.white : AppTheme.textDim,
              fontWeight: selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selectedCategory == cat ? AppTheme.ocuBurgundy : AppTheme.goldAccent.withOpacity(0.3),
              ),
            ),
            showCheckmark: false,
          ),
        )).toList(),
      ),
    );
  }
}
