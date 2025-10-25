import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class DashboardCommentItem extends StatelessWidget {
  final AudioCommentUiModel comment;

  const DashboardCommentItem({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to track detail screen once we can load track from minimal info
        // For now, navigation is disabled for comments
        // We need to either:
        // 1. Make TrackDetailScreenArgs.track optional
        // 2. Or fetch the track before navigating
        // 3. Or navigate to a different screen that can handle minimal info
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.space8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment type indicator
            _buildTypeIndicator(context),
            SizedBox(width: Dimensions.space12),
            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment preview or audio label
                  Text(
                    _getCommentPreview(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Dimensions.space4),
                  // Author and timestamp
                  Text(
                    '${comment.formattedCreatedAt} • at ${comment.formattedTimestamp}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.space8),
      decoration: BoxDecoration(
        color: comment.hasAudio ? AppColors.primary.withValues(alpha: 0.1) : AppColors.grey700,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        comment.hasAudio ? Icons.mic : Icons.comment,
        size: 20,
        color: comment.hasAudio ? AppColors.primary : AppColors.grey400,
      ),
    );
  }

  String _getCommentPreview() {
    final type = comment.commentType;
    if (type == 'CommentType.audio') {
      return '🔊 Audio comment';
    } else if (type == 'CommentType.hybrid') {
      return comment.content.isNotEmpty ? comment.content : '🔊 Audio comment';
    } else {
      return comment.content;
    }
  }
}

