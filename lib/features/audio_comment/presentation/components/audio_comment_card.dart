import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Audio comment card component using the design system
class AudioCommentComponent extends StatelessWidget {
  final AudioComment comment;
  final UserProfile collaborator;

  const AudioCommentComponent({
    super.key,
    required this.comment,
    required this.collaborator,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = comment.createdAt;
    final createdAtStr = dateFormat.format(createdAt);

    return BaseCard(
      onTap: () {
        context.read<AudioPlayerBloc>().add(
          SeekToPositionRequested(comment.timestamp),
        );
      },
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space8,
      ),
      backgroundColor: AppColors.grey700,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          _buildAvatar(context),

          SizedBox(width: Dimensions.space16),

          // Comment content
          Expanded(child: _buildCommentContent(context, createdAtStr)),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
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
                : comment.createdBy.value.substring(0, 1).toUpperCase(),
            style: AppTextStyle.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentContent(BuildContext context, String createdAtStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with name and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                collaborator.name.isNotEmpty
                    ? collaborator.name
                    : comment.createdBy.value,
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: Dimensions.space8),
            Text(
              createdAtStr,
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ],
        ),

        SizedBox(height: Dimensions.space8),

        // Comment text
        Text(comment.content, style: AppTextStyle.bodyMedium),

        SizedBox(height: Dimensions.space8),

        // Timestamp badge
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.space8,
              vertical: Dimensions.space4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(
              'at ${_formatDuration(comment.timestamp)}',
              style: AppTextStyle.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
