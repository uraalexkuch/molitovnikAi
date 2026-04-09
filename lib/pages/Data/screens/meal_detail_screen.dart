import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../dummy_data.dart';

class MealDetailScreen extends StatelessWidget {
  static const routeName = '/meal-detail';

  final String imgPath;

  MealDetailScreen({
    required this.imgPath,
  });

  Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,

      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        height: 200,
        width: 300,
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context)!.settings.arguments as String;
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == mealId);

    return  ResponsiveSizer(
        builder: (context, orientation, deviceType) {
          return SafeArea(
              left: true,
              top: true,
              right: true,
              bottom: true,
              child: Scaffold(
                body: Center(
                  child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context,
                        bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight:25.h,
                          floating: false,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                              centerTitle: true,
                              title: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.sp,
                                  horizontal: 20.sp,
                                ),
                                width: 50.w,
                                height: 5.h,
                                color: Colors.black54,
                                child: Center(
                                  child: Text(
                                    "Молитви",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Church",
                                      fontSize: 20.sp,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                              background: Image.asset(
                                "images/pcu.jpg",
                                fit: BoxFit.fill,
                              )),
                        ),
                      ];
                    },
                    body: (ListView.builder(
                      itemBuilder: (ctx, index) =>
                          Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage("images/paperold.jpg"),
                                        fit: BoxFit.fill)),
                                child: ListTile(

                                  title: Center(
                                    child: Text(
                                      selectedMeal.titlestep[index],
                                      style: TextStyle(
                                        fontFamily: "Church",
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  subtitle:Text(
                                    selectedMeal.steps[index],
                                    style: TextStyle(
                                      wordSpacing: 4,
                                      fontFamily: "Church",
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              Divider(),
                              Image(
                                image: AssetImage("images/b.png"),
                                height: 6.h,
                                width:  30.w,
                              ),
                              Divider(),
                            ],
                          ),
                      itemCount: selectedMeal.steps.length,
                    )),
                  ),
                ),
              )
          );
        }
        );
  }
}
