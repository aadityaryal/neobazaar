import 'package:flutter/material.dart';

ThemeData appTheme() {
  const seedColor = Color(0xFFFF9933); // Saffron
  const backgroundColor = Color(0xFF0F172A); // Midnight

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
    primary: seedColor,
    secondary: const Color(0xFF0055A4),
    surface: const Color(0xFF1E293B),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,

    // ✅ Material 3 compliant
    scaffoldBackgroundColor: backgroundColor,

    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: seedColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
      bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
    ),

    cardColor: colorScheme.surface,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedColor,
        foregroundColor: Colors.black,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: seedColor,
      unselectedItemColor: Colors.grey,
    ),

    fontFamily: 'Inter',
  );
}
