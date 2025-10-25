import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/widgets/user_avatar.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

/// Dedicated widget for displaying audio comment user avatars
class AudioCommentAvatar extends StatelessWidget {
  final UserProfileUiModel collaborator;
  final String createdBy;

  const AudioCommentAvatar({
    super.key,
    required this.collaborator,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      imageUrl: collaborator.avatarUrl,
      size: Dimensions.avatarMedium,
      fallback: Container(
        width: Dimensions.avatarMedium,
        height: Dimensions.avatarMedium,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          collaborator.initials,
          style: AppTextStyle.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
