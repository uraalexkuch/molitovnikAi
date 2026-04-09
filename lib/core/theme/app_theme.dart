import 'package:flutter/material.dart';

class AppTheme {
  // ── Православна палітра ───────────────────────────────────
  static const Color backgroundDark  = Color(0xFF1A1008); // Темно-коричневий
  static const Color surfaceDark     = Color(0xFF2A1F10); // Дерево
  static const Color goldAccent      = Color(0xFFD4A843); // Церковне золото
  static const Color goldLight       = Color(0xFFF0C060); // Світле золото
  static const Color liturgicalRed   = Color(0xFFB71C1C); // Глибокий літургійний червоний
  static const Color iconsBlue       = Color(0xFF3B5998); // Синь ікон
  static const Color parchment       = Color(0xFFF5E6C8); // Пергамент (текст)
  static const Color errorRed        = Color(0xFFD32F2F);

  // ── User bubble / AI bubble (Modernized) ──────────────────
  static const Color userBubble = Color(0xFF3E2723); // Теплий темно-коричневий
  static const Color aiBubble   = Color(0xFF263238); // Глибокий асфальтовий (Modern AI feel)

  // Гібридний градієнт (Традиція + Цифра)
  static const Gradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, Color(0xFF3E2723)],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: liturgicalRed,
      secondary: goldAccent,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: backgroundDark,
      onSurface: parchment,
      error: errorRed,
    ),
    fontFamily: 'Church',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: goldAccent, fontSize: 28, fontWeight: FontWeight.bold,
        fontFamily: 'Church',
      ),
      headlineMedium: TextStyle(
        color: goldLight, fontSize: 22, fontFamily: 'Church',
      ),
      bodyLarge: TextStyle(color: parchment, fontSize: 17, height: 1.5),
      bodyMedium: TextStyle(color: parchment, fontSize: 15),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 13),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Для використання градієнта
      foregroundColor: goldAccent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: goldAccent,
        fontSize: 20,
        fontFamily: 'Church',
        fontWeight: FontWeight.bold,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: backgroundDark,
      indicatorColor: liturgicalRed.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: goldAccent, fontSize: 12, fontFamily: 'Church');
        }
        return const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Church');
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: liturgicalRed);
        }
        return const IconThemeData(color: Colors.white54);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: liturgicalRed, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: liturgicalRed,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
