import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/features/prayerbook/prayer_detail_screen.dart';

class PrayerCard extends StatelessWidget {
  final String id;
  final String title;
  final String imgPath;

  const PrayerCard({
    super.key,
    required this.id,
    required this.title,
    required this.imgPath,
  });

  void selectPrayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerDetailScreen(prayerId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectPrayer(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
        ),
        elevation: 4,
        margin: EdgeInsets.all(10.sp),
        child: Container(
           decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/paperold.jpg"),
              fit: BoxFit.fill,
            ),
             borderRadius: BorderRadius.circular(15.sp),
          ),
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.sp),
                    child: Image.asset(
                      imgPath,
                      height: 32.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 15.sp,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.sp,
                        horizontal: 15.sp,
                      ),
                      width: 80.w,
                      color: Colors.black54,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "Church",
                          fontSize: 22.sp,
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
      ),
    );
  }
}
