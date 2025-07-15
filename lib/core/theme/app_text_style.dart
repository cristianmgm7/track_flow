import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';

class AppTextStyle {
  static const TextStyle titleLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleSmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium weight for list titles
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.normal, // Normal weight for subtitles
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelLarge = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
