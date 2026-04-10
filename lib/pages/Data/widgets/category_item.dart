import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../screens/categories_meals_screen.dart';

class CategoryItem extends StatelessWidget {
  final String id;
  final String imgPath;
  final String name;

  const CategoryItem(this.id, this.imgPath, this.name, {super.key});

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(CategoriesMealsScreen.routeName, arguments: {
      'id': id,
      'title': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, deviceType) {
      return InkWell(
        onTap: () => selectCategory(context),
        child:  Container(
          margin: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage("images/paperold.jpg"), fit: BoxFit.fill),
            border: Border.all(color: Colors.black, width: 8.sp),
            borderRadius: BorderRadius.circular(15.sp),
          ),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.sp),
                child: Image.asset(
                  imgPath,
                  height: 75.h,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                bottom: 10.sp,
                right: 5.sp,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.sp,
                    horizontal: 10.sp,
                  ),
                  width: 100.w,
                  height: 20.h,
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontFamily: "Church",
                        fontSize: 26.sp,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              )
            ],
          ),
        )

      );
    });
  }
}
