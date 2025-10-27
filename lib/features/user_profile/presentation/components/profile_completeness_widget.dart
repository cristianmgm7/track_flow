import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ProfileCompletenessWidget extends StatelessWidget {
  final String? description;
  final String? location;
  final List<SocialLink>? socialLinks;
  final List<String>? roles;
  final List<String>? genres;
  final List<String>? skills;

  const ProfileCompletenessWidget({
    super.key,
    this.description,
    this.location,
    this.socialLinks,
    this.roles,
    this.genres,
    this.skills,
  });

  /// Calculate profile completion percentage
  /// - Basic (Name, Email, Avatar) = 30% (always present in edit screen)
  /// - + Bio OR Location = +30% (60% total)
  /// - + Social Links (at least 1) = +20% (80% total)
  /// - + Roles OR Genres OR Skills (at least 1 of any) = +20% (100% total)
  int _calculateCompleteness() {
    int percentage = 30; // Base: Name, Email, Avatar

    // +30% for Bio or Location
    if ((description != null && description!.trim().isNotEmpty) ||
        (location != null && location!.trim().isNotEmpty)) {
      percentage += 30;
    }

    // +20% for Social Links
    if (socialLinks != null && socialLinks!.isNotEmpty) {
      percentage += 20;
    }

    // +20% for Roles, Genres, or Skills
    if ((roles != null && roles!.isNotEmpty) ||
        (genres != null && genres!.isNotEmpty) ||
        (skills != null && skills!.isNotEmpty)) {
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
      return 'Your profile is complete!';
    } else if (percentage >= 80) {
      return 'Almost there! Add more details to complete your profile.';
    } else if (percentage >= 60) {
      return 'Good progress! Keep adding more information.';
    } else {
      return 'Start by adding your bio and location.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completeness = _calculateCompleteness();
    
    // Hide widget if profile is 100% complete
    if (completeness >= 100) {
      return const SizedBox.shrink();
    }
    
    final progressColor = _getProgressColor(completeness);
    final message = _getCompletionMessage(completeness);

    return Container(
      padding: EdgeInsets.all(Dimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              Text(
                'Profile Completeness',
                style: AppTextStyle.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completeness%',
                style: AppTextStyle.titleMedium.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.space12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: LinearProgressIndicator(
              value: completeness / 100,
              minHeight: 8,
              backgroundColor: AppColors.grey600.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          SizedBox(height: Dimensions.space8),

          // Message
          Text(
            message,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // Completion Checklist
          if (completeness < 100) ...[
            SizedBox(height: Dimensions.space12),
            _buildChecklistItems(),
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChecklistItem(
          label: 'Basic info',
          isComplete: true,
          icon: Icons.check_circle,
        ),
        if (description == null || description!.trim().isEmpty)
          _buildChecklistItem(
            label: 'Add a bio',
            isComplete: false,
            icon: Icons.radio_button_unchecked,
          ),
        if (location == null || location!.trim().isEmpty)
          _buildChecklistItem(
            label: 'Add your location',
            isComplete: false,
            icon: Icons.radio_button_unchecked,
          ),
        if (socialLinks == null || socialLinks!.isEmpty)
          _buildChecklistItem(
            label: 'Add social links',
            isComplete: false,
            icon: Icons.radio_button_unchecked,
          ),
        if ((roles == null || roles!.isEmpty) &&
            (genres == null || genres!.isEmpty) &&
            (skills == null || skills!.isEmpty))
          _buildChecklistItem(
            label: 'Add roles, genres, or skills',
            isComplete: false,
            icon: Icons.radio_button_unchecked,
          ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isComplete,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.space8),
      child: Row(
        children: [
          Icon(
            icon,
            size: Dimensions.iconSmall,
            color: isComplete ? AppColors.success : AppColors.textSecondary,
          ),
          SizedBox(width: Dimensions.space8),
          Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              color: isComplete ? AppColors.success : AppColors.textSecondary,
              decoration:
                  isComplete ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

