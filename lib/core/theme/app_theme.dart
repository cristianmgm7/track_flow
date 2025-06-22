import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppTextStyle.titleMedium,
    ),
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
    ),
    dividerColor: AppColors.border,
    textTheme: const TextTheme(
      bodyLarge: AppTextStyle.bodyLarge,
      bodyMedium: AppTextStyle.bodyMedium,
      bodySmall: AppTextStyle.bodySmall,
      titleLarge: AppTextStyle.titleLarge,
      titleMedium: AppTextStyle.titleMedium,
      titleSmall: AppTextStyle.titleSmall,
      labelLarge: AppTextStyle.labelLarge,
    ),
    cardColor: AppColors.surface,
    useMaterial3: true,
  );
}
