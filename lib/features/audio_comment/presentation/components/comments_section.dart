import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/entities/unique_id.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_state.dart';
import '../bloc/audio_comment_event.dart';
import 'comments_list_view.dart';

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
  // Track the last version we subscribed to
  TrackVersionId? _currentlyWatchingVersionId;

  void _watchComments() {
    // Only dispatch if we're not already watching this version
    if (_currentlyWatchingVersionId != widget.versionId) {
      _currentlyWatchingVersionId = widget.versionId;
      context.read<AudioCommentBloc>().add(
        WatchAudioCommentsBundleEvent(
          widget.projectId,
          widget.trackId,
          widget.versionId,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _watchComments();
  }

  @override
  void didUpdateWidget(covariant CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.versionId != widget.versionId ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.trackId != widget.trackId) {
      // Re-subscribe for the new version
      _watchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCommentBloc, AudioCommentState>(
      builder: (context, state) {
        // Handle initial state - show loading indicator
        if (state is AudioCommentInitial || state is AudioCommentLoading) {
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
          return CommentsListView(
            comments: state.comments,
            collaborators: state.collaborators,
            projectId: widget.projectId,
            versionId: widget.versionId,
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
        // Fallback for unknown states
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

}
