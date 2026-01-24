import 'package:flutter/material.dart';

enum AppThemeVariant { light, dark, festival }

ThemeData appTheme() {
  return appLightTheme();
}

ThemeData appLightTheme() {
  return appThemeForVariant(AppThemeVariant.light);
}

ThemeData appDarkTheme() {
  return appThemeForVariant(AppThemeVariant.dark);
}

ThemeData appThemeForVariant(AppThemeVariant variant) {
  switch (variant) {
    case AppThemeVariant.light:
      return _buildTheme(
        brightness: Brightness.light,
        seedColor: const Color(0xFF0055A4),
        secondary: const Color(0xFFFF9933),
        surface: const Color(0xFFF8FAFC),
        backgroundColor: const Color(0xFFFFFFFF),
        bodyColor: const Color(0xFF0F172A),
        captionColor: const Color(0xFF334155),
      );
    case AppThemeVariant.dark:
      return _buildTheme(
        brightness: Brightness.dark,
        seedColor: const Color(0xFFFF9933),
        secondary: const Color(0xFF0055A4),
        surface: const Color(0xFF1E293B),
        backgroundColor: const Color(0xFF0F172A),
        bodyColor: const Color(0xFFFFFFFF),
        captionColor: const Color(0xFF94A3B8),
      );
    case AppThemeVariant.festival:
      return _buildTheme(
        brightness: Brightness.dark,
        seedColor: const Color(0xFFFF6B00),
        secondary: const Color(0xFF2ECC71),
        surface: const Color(0xFF2A1E3A),
        backgroundColor: const Color(0xFF140F22),
        bodyColor: const Color(0xFFFFFFFF),
        captionColor: const Color(0xFFE2E8F0),
      );
  }
}

ThemeData _buildTheme({
  required Brightness brightness,
  required Color seedColor,
  required Color secondary,
  required Color surface,
  required Color backgroundColor,
  required Color bodyColor,
  required Color captionColor,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    primary: seedColor,
    secondary: secondary,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    scaffoldBackgroundColor: backgroundColor,

    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      foregroundColor: bodyColor,
    ),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: seedColor,
        fontSize: 24,
        fontFamily: 'Inter Bold',
      ),
      bodyMedium: TextStyle(
        color: bodyColor,
        fontSize: 16,
        fontFamily: 'Inter Regular',
      ),
      bodySmall: TextStyle(
        color: captionColor,
        fontSize: 12,
        fontFamily: 'Inter Regular',
      ),
    ),

    cardColor: colorScheme.surface,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedColor,
        foregroundColor: brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: seedColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
