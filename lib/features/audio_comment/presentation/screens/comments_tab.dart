import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/audio_comment/presentation/widgets/comment_audio_player.dart';

class CommentsTab extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  const CommentsTab(this.projectId, this.track, {super.key});
  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  @override
  void initState() {
    super.initState();
    // Start watching comments for this track
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            if (state.visualContext == PlayerVisualContext.commentPlayer) {
              return CommentAudioPlayer(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
        // Comments list
        Expanded(
          child: BlocBuilder<AudioCommentBloc, AudioCommentState>(
            builder: (context, state) {
              if (state is AudioCommentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AudioCommentError) {
                return Center(child: Text('Error: \\${state.message}'));
              }
              if (state is AudioCommentsLoaded) {
                if (state.comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }
                return ListView.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(comment.content),
                      subtitle: Text('By: \\${comment.createdBy.value}'),
                    );
                  },
                );
              }
              if (state is AudioCommentOperationSuccess) {
                // Optionally show a success message, or just reload comments
                return Center(child: Text(state.message));
              }
              // Covers AudioCommentInitial and any unknown state
              return const Center(child: Text('Unable to load comments.'));
            },
          ),
        ),
        // Add Comment Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Add Comment'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
