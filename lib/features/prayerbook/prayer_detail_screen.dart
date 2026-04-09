import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';

class PrayerDetailScreen extends StatelessWidget {
  final String prayerId;

  const PrayerDetailScreen({
    super.key,
    required this.prayerId,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == prayerId);

    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 25.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.black87,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.sp,
                        horizontal: 10.sp,
                      ),
                      color: Colors.black54,
                      child: Text(
                        "Молитви",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Church",
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    background: Image.asset(
                      "assets/images/pcu.jpg",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ];
            },
            body: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: selectedMeal.steps.length,
              itemBuilder: (ctx, index) => Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/paperold.jpg"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      children: [
                         if (selectedMeal.titlestep.length > index)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.sp),
                            child: Text(
                              selectedMeal.titlestep[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Church",
                                fontSize: 19.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB71C1C), // Deep Red
                              ),
                            ),
                          ),
                        Text(
                          selectedMeal.steps[index],
                          style: TextStyle(
                            wordSpacing: 4,
                            fontFamily: "Church",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.sp),
                    child: Image.asset(
                      "assets/images/b.png",
                      height: 6.h,
                      width: 30.w,
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
