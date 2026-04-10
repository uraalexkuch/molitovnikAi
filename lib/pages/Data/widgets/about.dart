import 'package:flutter/material.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class About extends StatelessWidget {
  static const routeName = '/category-about';

  const About({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, deviceType) {
      return SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child: Column(
          children: [
            SizedBox(
              height: 8.h,),

            Image.asset(
              'images/pcu.jpg',
              height: 30.h,
              width: 100.w,
              fit: BoxFit.cover,
            ),
            const Divider(),
            Container(
                height: 55.h,
                width: 100.w,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/paperold.jpg"),

                      fit: BoxFit.fill)),

              child: const Padding(
                padding: EdgeInsets.only(left:8.0),
                child: Center(
                  child: Text(
                    '   Додаток створенний по Божій благодаті та з благословення ігумена Макарія,  настоятеля Собору Волинських Святих у Волновасі, ПЦУ.\n,За сонову взято  "Молитовник Захисника Вітчизни" від  Свято-Юрівського храму м. Вишневе, \n Аудіо версії з вільного доступу YouTube\n  Пропозиції надсилfти  на адресу mag_ura@ukr.net',
                    style: TextStyle(
                      fontFamily: "Church",
                      fontSize: 20,
                      color: Colors.indigo,
                    ),
                    softWrap: true,
                    //overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),

          ],
        ),
      );
    });
  }
}
