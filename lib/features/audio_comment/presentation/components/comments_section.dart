import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/entities/unique_id.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_state.dart';
import '../bloc/audio_comment_event.dart';
import 'audio_comment_card.dart';
import '../../domain/entities/audio_comment.dart';
import '../../../user_profile/domain/entities/user_profile.dart';

/// Comments section component that handles displaying the list of comments
/// with proper state management and error handling
class CommentsSection extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final TrackVersionId versionId;

  const CommentsSection({
    super.key,
    required this.projectId,
    required this.trackId,
    required this.versionId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AudioCommentBloc>().add(
          WatchAudioCommentsBundleEvent(
            widget.projectId,
            widget.trackId,
            widget.versionId,
          ),
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.versionId != widget.versionId ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.trackId != widget.trackId) {
      // Re-subscribe for the new track
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AudioCommentBloc>().add(
          WatchAudioCommentsBundleEvent(
            widget.projectId,
            widget.trackId,
            widget.versionId,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCommentBloc, AudioCommentState>(
      builder: (context, state) {
        if (state is AudioCommentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AudioCommentError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: AppTextStyle.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }
        if (state is AudioCommentsLoaded) {
          return _buildCommentsListView(
            context,
            state.comments,
            state.collaborators,
          );
        }
        if (state is AudioCommentOperationSuccess) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyle.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        return Center(
          child: Text(
            'Unable to load comments.',
            style: AppTextStyle.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsListView(
    BuildContext context,
    List<AudioComment> comments,
    List<UserProfile> collaborators,
  ) {
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

    return ListView.builder(
      reverse: false,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final collaborator = collaborators.firstWhere(
          (u) => u.id == comment.createdBy,
          orElse:
              () => UserProfile(
                id: comment.createdBy,
                name: '',
                email: '',
                avatarUrl: '',
                createdAt: DateTime.now(),
              ),
        );
        return AudioCommentComponent(
          comment: comment,
          collaborator: collaborator,
          projectId: widget.projectId,
          versionId: widget.versionId,
        );
      },
    );
  }
}
