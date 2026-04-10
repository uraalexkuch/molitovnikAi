import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/theme/app_theme.dart';
import 'church_day_model.dart';
import 'calendar_service.dart';
import 'widgets/calendar_header.dart';
import 'widgets/month_selector.dart';
import 'widgets/church_day_card.dart';

class OrthodoxCalendarScreen extends StatefulWidget {
  const OrthodoxCalendarScreen({super.key});

  @override
  State<OrthodoxCalendarScreen> createState() => _OrthodoxCalendarScreenState();
}

class _OrthodoxCalendarScreenState extends State<OrthodoxCalendarScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<ChurchDay> _allDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final days = await CalendarService.loadCalendarData(_selectedYear);
    if (mounted) {
      setState(() {
        _allDays = days;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDays = CalendarService.filterByMonth(_allDays, _selectedMonth);

    return Scaffold(
      backgroundColor: AppTheme.parchmentWhite,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/old_paper3.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Column(
          children: [
            const CalendarHeader(title: "Календар ПЦУ"),
            
            MonthSelector(
              selectedMonth: _selectedMonth,
              onSelected: (month) => setState(() => _selectedMonth = month),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.ocuBurgundy))
                  : filteredDays.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 5.sp),
                          itemCount: filteredDays.length,
                          itemBuilder: (context, index) {
                            return ChurchDayCard(day: filteredDays[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 40.sp, color: AppTheme.textDim.withOpacity(0.5)),
          SizedBox(height: 10.sp),
          Text(
            "На цей місяць подій не знайдено",
            style: TextStyle(color: AppTheme.textDim, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}
