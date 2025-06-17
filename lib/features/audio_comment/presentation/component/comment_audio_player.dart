import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';

class CommentAudioPlayer extends StatelessWidget {
  final AudioPlayerState state;
  const CommentAudioPlayer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
      if (state.visualContext == PlayerVisualContext.commentPlayer) {
        //final trackName = state.track.name;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: 60,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("Waveform placeholder"),
                  ),
                  Positioned(
                    right: 8,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: 'add-comment',
                      child: const Icon(Icons.add),
                      onPressed: () {
                        // Trigger custom logic to add a comment at current audio position
                        final bloc = context.read<AudioPlayerBloc>();
                        final currentState = bloc.state;
                        if (currentState is AudioPlayerPlaying ||
                            currentState is AudioPlayerPaused) {
                          final currentPosition = getCurrentPosition(bloc);
                          // dispatch an event or show a comment input dialog
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      state is AudioPlayerPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (state is AudioPlayerPlaying) {
                        context.read<AudioPlayerBloc>().add(
                          PauseAudioRequested(),
                        );
                      } else {
                        context.read<AudioPlayerBloc>().add(
                          ResumeAudioRequested(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
