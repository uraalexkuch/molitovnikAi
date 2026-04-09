import 'package:flutter/material.dart';
import '../dummy_data.dart';
import '../widgets/category_item.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  ResponsiveSizer(
        builder: (context, orientation, deviceType) {
          return SafeArea(
              left: true,
              top: true,
              right: true,
              bottom: true,
              child:
              GridView(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.1,
                ),
                children: DUMMY_CATEGORIES
                    .map((catData) =>
                    CategoryItem(catData.id, catData.imgPath, catData.name))
                    .toList(),
              )
          );
        }
        );
        }
  }

