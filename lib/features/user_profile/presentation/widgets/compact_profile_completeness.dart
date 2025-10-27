import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Compact version of profile completeness indicator for settings screen
class CompactProfileCompleteness extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onTap;

  const CompactProfileCompleteness({
    super.key,
    required this.profile,
    this.onTap,
  });

  /// Calculate profile completion percentage
  int _calculateCompleteness() {
    int percentage = 30; // Base: Name, Email, Avatar

    // +30% for Bio or Location
    if ((profile.description != null && profile.description!.trim().isNotEmpty) ||
        (profile.location != null && profile.location!.trim().isNotEmpty)) {
      percentage += 30;
    }

    // +20% for Social Links
    if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) {
      percentage += 20;
    }

    // +20% for Roles, Genres, or Skills
    if ((profile.roles != null && profile.roles!.isNotEmpty) ||
        (profile.genres != null && profile.genres!.isNotEmpty) ||
        (profile.skills != null && profile.skills!.isNotEmpty)) {
      percentage += 20;
    }

    return percentage;
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 100) {
      return AppColors.success;
    } else if (percentage >= 80) {
      return AppColors.primary;
    } else if (percentage >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getCompletionMessage(int percentage) {
    if (percentage >= 100) {
      return 'Profile complete';
    } else if (percentage >= 80) {
      return 'Almost complete';
    } else if (percentage >= 60) {
      return 'Good progress';
    } else {
      return 'Complete your profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completeness = _calculateCompleteness();
    final progressColor = _getProgressColor(completeness);
    final message = _getCompletionMessage(completeness);

    // Don't show if profile is 100% complete
    if (completeness >= 100) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(Dimensions.space12),
        decoration: BoxDecoration(
          color: progressColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          border: Border.all(
            color: progressColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        completeness >= 80
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        size: Dimensions.iconSmall,
                        color: progressColor,
                      ),
                      SizedBox(width: Dimensions.space8),
                      Expanded(
                        child: Text(
                          message,
                          style: AppTextStyle.labelMedium.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$completeness%',
                      style: AppTextStyle.labelLarge.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: Dimensions.space4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: Dimensions.iconSmall,
                      color: progressColor,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Dimensions.space8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: LinearProgressIndicator(
                value: completeness / 100,
                minHeight: 6,
                backgroundColor: AppColors.grey600.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

