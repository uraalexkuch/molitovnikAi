import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/prayerbook/prayerbook_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/calendar/orthodox_calendar_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/security/panic_wipe_service.dart';
import 'services/ai/model_management_service.dart';
import 'features/onboarding/model_selection_dialog.dart';
import 'core/widgets/orthodox_cross_widget.dart';
import 'services/ai/offline_tts_service.dart';


class MolitovnikApp extends StatelessWidget {
  const MolitovnikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'Молитовник & Капелан',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ініціалізація Panic Wipe при старті додатку
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PanicWipeService().initialize(context);
      
      // Ініціалізація TTS (Sherpa-ONNX)
      OfflineTtsService.instance.initialize();
      
      // ПОКРАЩЕНО: Показуємо діалог ТІЛЬКИ якщо жодна модель не завантажена
      final modelService = ModelManagementService();
      final hasModel = await modelService.isAnyModelDownloaded();
      if (!hasModel && mounted) {
        ModelSelectionDialog.show(context, isMandatory: true);
      }
    });
  }

  // ЗМІНЕНО порядок: Капелан тепер другий
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = _navigatorKeys[_currentIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          // Якщо ми в корні таба і це не перший таб — переходимо на перший
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          } else {
            // Вихід з додатку (тут можна додати діалог підтвердження)
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const ChatScreen(),
            _buildTabNavigator(2, const OrthodoxCalendarScreen()),
            _buildTabNavigator(3, const PrayerbookScreen()),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppTheme.backgroundDark,
          elevation: 8,
          indicatorColor: AppTheme.ocuBurgundy.withOpacity(0.25),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppTheme.ocuBurgundy),
              label: 'Головна',
            ),
            NavigationDestination(
              icon: OrthodoxCrossWidget(size: 24, color: Colors.white38),
              selectedIcon: OrthodoxCrossWidget(size: 24, color: AppTheme.goldAccent),
              label: 'Капелан',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: AppTheme.ocuBurgundy),
              label: 'Молитовник',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: AppTheme.ocuBurgundy),
              label: 'Календар',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppTheme.ocuBurgundy),
              label: 'Налаштування',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => rootPage,
        );
      },
    );
  }
}
