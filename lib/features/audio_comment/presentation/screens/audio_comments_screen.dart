import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_waveform_component.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_comments_component.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_input_comment_component.dart';

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
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
    context.read<AudioPlayerBloc>().add(
      ChangeVisualContext(PlayerVisualContext.commentPlayer),
    );
    final collaborator =
        widget.collaborators.isNotEmpty
            ? widget.collaborators.first
            : UserProfile(
              id: widget.track.uploadedBy,
              name: '',
              email: '',
              avatarUrl: '',
              createdAt: DateTime.now(),
            );
    context.read<AudioPlayerBloc>().add(
      PlayAudioRequested(
        source: PlaybackSource(type: PlaybackSourceType.track),
        visualContext: PlayerVisualContext.commentPlayer,
        track: widget.track,
        collaborator: collaborator,
      ),
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
            const AudioCommentWaveform(),
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
                    return AudioCommentCommentsList(
                      comments: state.comments,
                      collaborators: widget.collaborators,
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
            AudioCommentInputComment(
              onSend: (text) {
                context.read<AudioCommentBloc>().add(
                  AddAudioCommentEvent(widget.projectId, widget.track.id, text),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
