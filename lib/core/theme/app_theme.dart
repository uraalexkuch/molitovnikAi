import 'package:flutter/material.dart';

class AppTheme {
  // ── Палітра ПЦУ (Світла, тепла та спокійна) ─────────────────
  // Офіційні кольори ПЦУ залишаємо як благородні акценти
  static const Color ocuBurgundy   = Color(0xFF6B0F1A); // Основний бордовий ПЦУ
  static const Color ocuCrimson    = Color(0xFF8B1A2A); // М'якший бордовий
  static const Color ocuBlue       = Color(0xFF4A89DC); // Небесно-блакитний (опціонально для надії)

  // Нові світлі, "добрі" фони (колір теплого пергаменту, ранкового світла)
  static const Color backgroundLight = Color(0xFFFDFBF7); // М'який теплий білий (як стіни храму)
  static const Color surfaceLight    = Color(0xFFFFFFFF); // Чистий білий для карток
  static const Color surfaceMid      = Color(0xFFF4EFE6); // Злегка піщаний для виділення (поле вводу)

  // Золото (залишається для святості та тепла)
  static const Color goldAccent   = Color(0xFFD4A843);
  static const Color goldLight    = Color(0xFFF0C060);
  
  // Текст (відмова від різкого чорного на користь м'якого темно-коричневого)
  static const Color textMain     = Color(0xFF2C251F); // Колір старого чорнила
  static const Color textDim      = Color(0xFF736555); // Приглушений текст для підзаголовків

  // Бульбашки чату
  static const Color userBubble = Color(0xFFF4EFE6); // Теплий піщаний (користувач)
  static const Color aiBubble   = Color(0xFFFFFFFF); // Чистий білий з легкою бордовою рамкою (капелан)

  static const Color errorRed = Color(0xFFD32F2F);

  // Світлий градієнт для AppBar
  static const Gradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceLight, surfaceMid],
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light, 
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: ocuBurgundy,
      secondary: goldAccent,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: textMain,
      onSurface: textMain,
      error: errorRed,
    ),
    fontFamily: 'Church',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: ocuBurgundy, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Church'),
      headlineMedium: TextStyle(color: textMain, fontSize: 22, fontFamily: 'Church'),
      bodyLarge: TextStyle(color: textMain, fontSize: 17, height: 1.5),
      bodyMedium: TextStyle(color: textMain, fontSize: 15),
      bodySmall: TextStyle(color: textDim, fontSize: 13),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: ocuBurgundy,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: ocuBurgundy, fontSize: 20, fontFamily: 'Church', fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: ocuBurgundy),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      indicatorColor: ocuBurgundy.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: ocuBurgundy, fontSize: 11, fontFamily: 'Church', fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: textDim, fontSize: 11, fontFamily: 'Church');
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ocuBurgundy);
        }
        return const IconThemeData(color: textDim);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceMid,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: ocuBurgundy, width: 1.5)),
      hintStyle: const TextStyle(color: textDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ocuBurgundy,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // ── Кольори для Молитовника ───────────────────────────────
  static const Color chestnutHeader = Color(0xFF4A2C2A); // Темно-каштановий для шапки
  static const Color morningStripe  = Color(0xFFFFD700); // Теплий жовтий (Ранок)
  static const Color battleStripe   = Color(0xFFB22222); // Червоний (Бойові)
  static const Color eveningStripe  = Color(0xFF1E90FF); // Синій (Вечір)
  static const Color parchmentWhite = Color(0xFFF9F7F2); // Колір основи пергаменту

  // Для сумісності з попередніми викликами, якщо вони ще не рефакторені
  static const Color backgroundDark = backgroundLight;
  static const Color surfaceDark    = surfaceLight;
  static const Color surfaceMidOld  = Color(0xFFF4EFE6);
  static const Color parchment      = textMain;
  static const Color parchmentDim   = textDim;
}

