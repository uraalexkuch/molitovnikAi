
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../screens/meal_detail_screen.dart';

class MealItem extends StatelessWidget {
  final String id;
  final String title;
  final String imgPath;
  final int duration;

  MealItem({
    required this.id,
    required this.title,
    required this.imgPath,
    required this.duration,
  });

  void selectMeal(BuildContext context) {
    Navigator.of(context).pushNamed(MealDetailScreen.routeName, arguments: id);
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>selectMeal(context),
      child:
          Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
        ),
        elevation: 4,
        margin: EdgeInsets.all(10.sp),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.sp),
                    child: Image.asset(
                      imgPath,
                      height: 34.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      width: MediaQuery.of(context).size.width*0.8,
                      color: Colors.black54,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "Church",
                          fontSize: 24,
                          color: Colors.white,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  )
                ],
              ),

            ],
          ),
        ),
      )

    );
  }
}
