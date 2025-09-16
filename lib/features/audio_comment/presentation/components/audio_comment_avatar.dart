import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Dedicated widget for displaying audio comment user avatars
class AudioCommentAvatar extends StatelessWidget {
  final UserProfile collaborator;
  final UserId createdBy;

  const AudioCommentAvatar({
    super.key,
    required this.collaborator,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ImageUtils.createAdaptiveImageWidget(
        imagePath: collaborator.avatarUrl,
        width: Dimensions.avatarMedium,
        height: Dimensions.avatarMedium,
        fit: BoxFit.cover,
        fallbackWidget: Container(
          width: Dimensions.avatarMedium,
          height: Dimensions.avatarMedium,
          color: AppColors.primary.withValues(alpha: 0.1),
          alignment: Alignment.center,
          child: Text(
            collaborator.name.isNotEmpty
                ? collaborator.name.substring(0, 1).toUpperCase()
                : createdBy.value.substring(0, 1).toUpperCase(),
            style: AppTextStyle.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
