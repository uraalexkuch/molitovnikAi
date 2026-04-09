import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';
import 'package:molitovnik/features/prayerbook/widgets/prayer_card.dart';

class PrayerListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const PrayerListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final categoryMeals = DUMMY_MEALS.where((meal) {
      return meal.categories.contains(categoryId);
    }).toList();

    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
             leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              categoryTitle,
              style: TextStyle(
                fontFamily: "Church",
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/paperold.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: GridView.builder(
              padding: EdgeInsets.all(15.sp),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.3,
                mainAxisSpacing: 10.sp,
              ),
              itemCount: categoryMeals.length,
              itemBuilder: (ctx, index) {
                final meal = categoryMeals[index];
                return PrayerCard(
                  id: meal.id,
                  title: meal.title,
                  imgPath: meal.imgPath,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
