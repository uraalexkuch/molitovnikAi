import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../dummy_data.dart';
import '../widgets/meal_item.dart';

class CategoriesMealsScreen extends StatelessWidget {
  static const routeName = '/category-meals';

  // final String categoryId;
  // final String categoryTitle;

  // CategoriesMealsScreen(this.categoryId, this.categoryTitle);
  @override
  Widget build(BuildContext context) {
    final routeArgs =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, String>;
    final categoryTitle = routeArgs['title'];
    final categoryId = routeArgs['id'];

    final categoryMeals = DUMMY_MEALS.where((meal) {
      return meal.categories.contains(categoryId);
    }).toList();

    return ResponsiveSizer(builder: (context, orientation, deviceType) {
      return SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: true,
          child:Scaffold(
          appBar: AppBar(
          title: Text(categoryTitle!,
          style: TextStyle(
          fontFamily: "Church",
          fontSize: 20,
          color: Colors.white,
      ),
      )),
      body:
      Container(
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage("images/paperold.jpg"),
      fit: BoxFit.fill)),
      child:
      GridView(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.3,
        ),
        children: categoryMeals
            .map((catData) =>
            MealItem(id: catData.id,
      title: catData.title,
      imgPath: catData.imgPath,
      duration: catData.duration,))
            .toList(),
      )
      )
          )
      );

    }
    );
  }
}
