import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../presentation/models/audio_comment_ui_model.dart';
import 'audio_comment_player.dart';

/// Widget for displaying hybrid audio comments that contain both
/// audio content and text transcription
class CommentHybridContent extends StatelessWidget {
  final AudioCommentUiModel comment;

  const CommentHybridContent({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AudioCommentPlayer(comment: comment),
        SizedBox(height: Dimensions.space8),
        Text(
          comment.content,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
