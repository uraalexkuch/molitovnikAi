import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';
import 'package:molitovnik/features/prayerbook/widgets/category_card.dart';

class PrayerbookScreen extends StatelessWidget {
  const PrayerbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: GridView.builder(
              padding: EdgeInsets.all(15.sp),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.1,
                mainAxisSpacing: 10.sp,
              ),
              itemCount: DUMMY_CATEGORIES.length,
              itemBuilder: (ctx, index) {
                final category = DUMMY_CATEGORIES[index];
                return CategoryCard(
                  id: category.id,
                  imgPath: category.imgPath,
                  name: category.name,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
