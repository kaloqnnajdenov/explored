import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.emerald700,
    brightness: Brightness.light,
    primary: AppColors.emerald900,
    secondary: AppColors.emerald600,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.slate50,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.slate900),
      bodyMedium: TextStyle(color: AppColors.slate900),
      bodySmall: TextStyle(color: AppColors.slate500),
      titleLarge: TextStyle(
        color: AppColors.slate900,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.slate900,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.slate900,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(
        color: AppColors.slate500,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        color: AppColors.slate400,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.slate50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald600, width: 1.4),
      ),
    ),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
      shape: StadiumBorder(),
    ),
  );
}
