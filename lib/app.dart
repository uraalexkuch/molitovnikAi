import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/prayerbook/prayerbook_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/security/panic_wipe_service.dart';
import 'services/ai/model_management_service.dart';
import 'features/onboarding/model_selection_dialog.dart';

class MolitovnikApp extends StatelessWidget {
  const MolitovnikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'Молитовник & Капелан',
        theme: AppTheme.darkTheme,
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
      
      // Перевірка наявності ШІ моделі
      final modelService = ModelManagementService();
      if (!await modelService.isAnyModelDownloaded()) {
        if (mounted) {
          ModelSelectionDialog.show(context);
        }
      }
    });
  }

  static const _tabs = [
    HomeScreen(),
    PrayerbookScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 8,
        indicatorColor: AppTheme.liturgicalRed.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.home, color: AppTheme.liturgicalRed),
            label: 'Головна',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.liturgicalRed),
            label: 'Молитовник',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white54),
            selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.liturgicalRed),
            label: 'Капелан',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.settings, color: AppTheme.liturgicalRed),
            label: 'Налаштування',
          ),
        ],
      ),
    );
  }
}
