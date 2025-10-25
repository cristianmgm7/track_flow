import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_header.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_player.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_timestamp_badge.dart';
import 'package:trackflow/features/audio_comment/presentation/components/comment_hybrid_content.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

/// Dedicated widget for displaying audio comment content including
/// user name, creation date, comment text, and timestamp badge
class AudioCommentContent extends StatelessWidget {
  final AudioCommentUiModel comment;
  final UserProfileUiModel collaborator;

  const AudioCommentContent({
    super.key,
    required this.comment,
    required this.collaborator,
  });

  Widget _buildTextContent() {
    return Text(comment.content, style: AppTextStyle.bodyMedium);
  }

  Widget _buildAudioContent() {
    return AudioCommentPlayer(comment: comment);
  }


  @override
  Widget build(BuildContext context) {
    final displayName = collaborator.displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with name and date
        AudioCommentHeader(
          displayName: displayName,
          formattedDate: comment.formattedCreatedAt,
        ),

        SizedBox(height: Dimensions.space8),

        // Content based on type
        if (comment.commentType.contains('text'))
          _buildTextContent()
        else if (comment.commentType.contains('audio'))
          _buildAudioContent()
        else
          CommentHybridContent(comment: comment),

        SizedBox(height: Dimensions.space8),

        // Timestamp badge (tappable to seek)
        AudioCommentTimestampBadge(
          formattedTimestamp: 'at ${comment.formattedTimestamp}',
          onTap: () {
            context.read<AudioPlayerBloc>().add(
              SeekToPositionRequested(comment.timestamp),
            );
            context.read<AudioPlayerBloc>().add(const ResumeAudioRequested());
          },
        ),
      ],
    );
  }
}
