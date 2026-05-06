import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_styles.dart';

class AppThemes {
  AppThemes._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryAction,
      secondary: AppColors.secondaryAction,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryAction,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyles.heading,
      titleLarge: TextStyles.title,
      bodyMedium: TextStyles.body,
      labelLarge: TextStyles.label,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondaryAction,
      secondary: AppColors.accent,
      surface: Color(0xFF1F2937),
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF041029),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondaryAction,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF111827),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyles.heading,
      titleLarge: TextStyles.title,
      bodyMedium: TextStyles.body,
      labelLarge: TextStyles.label,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData carbonTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.highContrastDark(
      primary: AppColors.highContrast,
      secondary: AppColors.accent,
      surface: Color(0xFF111111),
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF040404),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.highContrast,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF141414),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyles.heading,
      titleLarge: TextStyles.title,
      bodyMedium: TextStyles.body,
      labelLarge: TextStyles.label,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );
}
