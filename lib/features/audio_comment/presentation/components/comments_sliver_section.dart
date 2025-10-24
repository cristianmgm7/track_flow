import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../core/theme/app_text_style.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_state.dart';
import '../bloc/audio_comment_event.dart';
import 'audio_comment_card.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_state.dart';
import '../../../user_profile/domain/entities/user_profile.dart';

class CommentsSliverSection extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final TrackVersionId versionId;

  const CommentsSliverSection({
    super.key,
    required this.projectId,
    required this.trackId,
    required this.versionId,
  });

  @override
  State<CommentsSliverSection> createState() => _CommentsSliverSectionState();
}

class _CommentsSliverSectionState extends State<CommentsSliverSection> {
  TrackVersionId? _currentlyWatchingVersionId;

  void _watchComments() {
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
  void didUpdateWidget(covariant CommentsSliverSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.versionId != widget.versionId ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.trackId != widget.trackId) {
      _watchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCommentBloc, AudioCommentState>(
      builder: (context, state) {
        if (state is AudioCommentInitial || state is AudioCommentLoading) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is AudioCommentError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Error: ${state.message}',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is AudioCommentsLoaded) {
          final userState = context.watch<CurrentUserBloc>().state;
          final String? currentUserId =
              userState is CurrentUserLoaded ? userState.profile.id.value : null;

          if (state.comments.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No comments yet.',
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final comment = state.comments[index];
                final collaborator = state.collaborators.firstWhere(
                  (u) => u.id == comment.createdBy,
                  orElse: () => UserProfile(
                    id: comment.createdBy,
                    name: '',
                    email: '',
                    avatarUrl: '',
                    createdAt: DateTime.now(),
                  ),
                );
                final bool isMine =
                    currentUserId != null && comment.createdBy.value == currentUserId;

                return AudioCommentComponent(
                  comment: comment,
                  collaborator: collaborator,
                  projectId: widget.projectId,
                  versionId: widget.versionId,
                  isMine: isMine,
                );
              },
              childCount: state.comments.length,
            ),
          );
        }

        return SliverToBoxAdapter(
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}


