import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/entities/unique_id.dart';
import 'audio_comment_card.dart';
import '../../domain/entities/audio_comment.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_state.dart';

/// Widget that displays a list of audio comments with proper error handling
/// for missing collaborators
class CommentsListView extends StatelessWidget {
  final List<AudioComment> comments;
  final List<UserProfile> collaborators;
  final ProjectId projectId;
  final TrackVersionId versionId;

  const CommentsListView({
    super.key,
    required this.comments,
    required this.collaborators,
    required this.projectId,
    required this.versionId,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet.',
          style: AppTextStyle.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, userState) {
        final String? currentUserId =
            userState is CurrentUserLoaded ? userState.profile.id.value : null;
        return ListView.builder(
          reverse: false,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final collaborator = collaborators.firstWhere(
              (u) => u.id == comment.createdBy,
              orElse: () => UserProfile(
                id: comment.createdBy,
                name: '',
                email: '',
                avatarUrl: '',
                createdAt: DateTime.now(),
              ),
            );
            final bool isMine = currentUserId != null && comment.createdBy.value == currentUserId;
            return AudioCommentComponent(
              comment: comment,
              collaborator: collaborator,
              projectId: projectId,
              versionId: versionId,
              isMine: isMine,
            );
          },
        );
      },
    );
  }
}
