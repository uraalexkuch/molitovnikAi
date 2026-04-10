import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';
import 'package:molitovnik/core/theme/app_theme.dart';
import 'package:molitovnik/core/widgets/orthodox_cross_widget.dart';

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
                  expandedHeight: 22.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.ocuBurgundy),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 3.sp,
                        horizontal: 12.sp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.ocuBurgundy.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OrthodoxCrossWidget(
                            size: 14,
                            color: AppTheme.goldAccent.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Молитви',
                            style: TextStyle(
                              color: AppTheme.ocuBurgundy,
                              fontFamily: 'Church',
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    background: Container(
                      color: AppTheme.ocuBurgundy,
                      child: Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: OrthodoxCrossWidget(
                            size: 100.sp,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ),
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
                  // Блок тексту молитви
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.fromLTRB(18.sp, 16.sp, 18.sp, 12.sp),
                    child: Column(
                      children: [
                        // ПРАЦЮЄМО: Заголовок кроку — бордовим кольором ПЦУ з хрестами по боках
                        if (selectedMeal.titlestep.length > index)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const OrthodoxCrossWidget(
                                  size: 14,
                                  color: AppTheme.ocuBurgundy,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    selectedMeal.titlestep[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Church',
                                      fontSize: 18.2.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ocuBurgundy,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const OrthodoxCrossWidget(
                                  size: 14,
                                  color: AppTheme.ocuBurgundy,
                                ),
                              ],
                            ),
                          ),

                        // Текст молитви — пергаментний на темному фоні
                        Text(
                          selectedMeal.steps[index],
                          style: TextStyle(
                            wordSpacing: 3,
                            fontFamily: 'Church',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.textMain,
                            height: 1.55,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),

                  // Розподільник — хрест ПЦУ замість зображення b.png
                  const PrayerDividerCross(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
