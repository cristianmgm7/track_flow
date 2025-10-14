import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_header.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_player.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_timestamp_badge.dart';
import 'package:trackflow/features/audio_comment/presentation/components/comment_hybrid_content.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Dedicated widget for displaying audio comment content including
/// user name, creation date, comment text, and timestamp badge
class AudioCommentContent extends StatelessWidget {
  final AudioComment comment;
  final UserProfile collaborator;

  const AudioCommentContent({
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

  Widget _buildTextContent() {
    return Text(comment.content, style: AppTextStyle.bodyMedium);
  }

  Widget _buildAudioContent() {
    return AudioCommentPlayer(comment: comment);
  }


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAtStr = dateFormat.format(comment.createdAt);
    final displayName = collaborator.name.isNotEmpty
        ? collaborator.name
        : comment.createdBy.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with name and date
        AudioCommentHeader(
          displayName: displayName,
          formattedDate: createdAtStr,
        ),

        SizedBox(height: Dimensions.space8),

        // Content based on type
        if (comment.commentType == CommentType.text)
          _buildTextContent()
        else if (comment.commentType == CommentType.audio)
          _buildAudioContent()
        else
          CommentHybridContent(comment: comment),

        SizedBox(height: Dimensions.space8),

        // Timestamp badge (tappable to seek)
        AudioCommentTimestampBadge(
          formattedTimestamp: 'at ${_formatDuration(comment.timestamp)}',
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
