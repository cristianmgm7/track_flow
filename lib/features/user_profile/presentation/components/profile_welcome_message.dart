import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class ProfileWelcomeMessage extends StatelessWidget {
  final bool isGoogleUser;

  const ProfileWelcomeMessage({super.key, required this.isGoogleUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isGoogleUser ? 'Welcome to TrackFlow!' : 'Complete Your Profile',
          style: AppTextStyle.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          isGoogleUser
              ? 'We\'ve pre-filled your profile with your Google information. Please review and complete any missing details.'
              : 'Tell us a bit about yourself to get started',
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
