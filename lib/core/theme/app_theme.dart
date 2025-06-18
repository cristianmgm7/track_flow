import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
    ),
    dividerColor: AppColors.border,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 20),
      titleSmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
    ),
    cardColor: AppColors.surface,
    useMaterial3: true,
  );
}
