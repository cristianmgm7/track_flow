import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/presentation/component/audio_comment_component.dart';

class CommentsForAudioPlayer extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;

  const CommentsForAudioPlayer({
    super.key,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });

  @override
  State<CommentsForAudioPlayer> createState() => _CommentsForAudioPlayerState();
}

class _CommentsForAudioPlayerState extends State<CommentsForAudioPlayer> {
  @override
  void initState() {
    super.initState();
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCommentBloc, AudioCommentState>(
      builder: (context, state) {
        if (state is AudioCommentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AudioCommentError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is AudioCommentsLoaded) {
          if (state.comments.isEmpty) {
            return const Center(child: Text('No comments yet.'));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.comments.length,
            itemBuilder: (context, index) {
              final comment = state.comments[index];
              final collaborator = widget.collaborators.firstWhere(
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
              return CommentComponent(
                comment: comment,
                collaborator: collaborator,
              );
            },
          );
        }
        if (state is AudioCommentOperationSuccess) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Unable to load comments.'));
      },
    );
  }
}
