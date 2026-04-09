import 'package:flutter/material.dart';
import 'package:molitovnik/pages/Play/player.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AudioItem extends StatelessWidget {
  final String id;
  final String imgPath;
  final String name;

  AudioItem(this.id, this.imgPath, this.name);

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(Player.routeName, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => selectCategory(context),
        child: ResponsiveSizer(builder: (context, orientation, deviceType) {
          return Container(
            margin: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/paperold.jpg"), fit: BoxFit.fill),
              border: Border.all(color: Colors.black, width: 8.sp),
              borderRadius: BorderRadius.circular(15.sp),
            ),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.sp),
                    topRight: Radius.circular(15.sp),
                  ),
                  child: Image.asset(
                    imgPath,
                    height: 100.h,
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
                    width: 80.w,
                    height: 30.h,
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
          );
        }));
  }
}
