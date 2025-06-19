import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/features/audio_comment/presentation/component/comment_audio_player.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/presentation/component/audio_comment_component.dart';

class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;
  AudioCommentsScreenArgs({
    required this.projectId,
    required this.track,
    required this.collaborators,
  });
}

class AudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;
  const AudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });
  @override
  State<AudioCommentsScreen> createState() => _AudioCommentsScreenState();
}

class _AudioCommentsScreenState extends State<AudioCommentsScreen> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Comentarios'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Onda de audio o reproductor de comentario
            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                if (state.visualContext == PlayerVisualContext.commentPlayer) {
                  return CommentAudioPlayer(state: state);
                }
                return const SizedBox.shrink();
              },
            ),
            // Lista de comentarios
            Expanded(
              child: BlocBuilder<AudioCommentBloc, AudioCommentState>(
                builder: (context, state) {
                  if (state is AudioCommentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AudioCommentError) {
                    return Center(
                      child: Text(
                        'Error: \\${state.message}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (state is AudioCommentsLoaded) {
                    if (state.comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
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
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'Unable to load comments.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            // Input para nuevo comentario (sticky abajo)
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      // TODO: enviar comentario
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
