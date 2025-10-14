import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/menus/app_popup_menu.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import '../bloc/audio_comment_event.dart';
import '../bloc/audio_comment_bloc.dart';
import 'audio_comment_avatar.dart';
import 'audio_comment_content.dart';

/// Audio comment card component using the design system
class AudioCommentComponent extends StatelessWidget {
  final AudioComment comment;
  final UserProfile collaborator;
  final ProjectId projectId;
  final TrackVersionId versionId;

  const AudioCommentComponent({
    super.key,
    required this.comment,
    required this.collaborator,
    required this.projectId,
    required this.versionId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart:
          (details) => _showCommentMenu(context, details.globalPosition),
      child: BaseCard(
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
            AudioCommentAvatar(
              collaborator: collaborator,
              createdBy: comment.createdBy,
            ),

            SizedBox(width: Dimensions.space16),

            // Comment content
            Expanded(
              child: AudioCommentContent(
                comment: comment,
                collaborator: collaborator,
              ), 
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentMenu(BuildContext context, Offset tapPosition) {
    showAppMenu<String>(
      context: context,
      positionOffset: tapPosition,
      items: [
        AppMenuItem<String>(
          value: 'delete',
          label: 'Delete Comment',
          icon: Icons.delete,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _deleteComment(context);
            break;
        }
      },
    );
  }

  void _deleteComment(BuildContext context) {
    context.read<AudioCommentBloc>().add(
      DeleteAudioCommentEvent(comment.id, projectId, versionId),
    );
  }
}
