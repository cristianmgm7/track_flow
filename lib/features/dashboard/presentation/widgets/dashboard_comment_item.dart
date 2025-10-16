import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:intl/intl.dart';

class DashboardCommentItem extends StatelessWidget {
  final AudioComment comment;

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
                    '${_formatTimestamp(comment.createdAt)} • at ${_formatPosition(comment.timestamp)}',
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
    final isAudio = comment.commentType == CommentType.audio ||
        comment.commentType == CommentType.hybrid;

    return Container(
      padding: EdgeInsets.all(Dimensions.space8),
      decoration: BoxDecoration(
        color: isAudio ? AppColors.primary.withValues(alpha: 0.1) : AppColors.grey700,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        isAudio ? Icons.mic : Icons.comment,
        size: 20,
        color: isAudio ? AppColors.primary : AppColors.grey400,
      ),
    );
  }

  String _getCommentPreview() {
    if (comment.commentType == CommentType.audio) {
      return '🔊 Audio comment';
    } else if (comment.commentType == CommentType.hybrid) {
      return comment.content.isNotEmpty ? comment.content : '🔊 Audio comment';
    } else {
      return comment.content;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatPosition(Duration position) {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

