import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/features/prayerbook/prayer_list_screen.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String imgPath;
  final String name;

  const CategoryCard({
    super.key,
    required this.id,
    required this.imgPath,
    required this.name,
  });

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => PrayerListScreen(
          categoryId: id,
          categoryTitle: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      child: Container(
        margin: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/paperold.jpg"),
            fit: BoxFit.fill,
          ),
          border: Border.all(color: Colors.black, width: 4.sp),
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
                height: 18.h,
                color: Colors.black54,
                child: Center(
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Church",
                      fontSize: 22.sp,
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
      ),
    );
  }
}
