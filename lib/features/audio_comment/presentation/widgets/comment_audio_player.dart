import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';

class CommentAudioPlayer extends StatelessWidget {
  const CommentAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
          if (state.visualContext == PlayerVisualContext.commentPlayer) {
            final trackName = state.source.track.name;
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
                  Text(
                    trackName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
      },
    );
  }
}
