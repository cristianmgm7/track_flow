// Rename this file to audio_comment_header.dart and the class to AudioCommentHeader
// This widget is only responsible for arranging the header layout (Stack: back button, waveform, play button)
// The waveform widget should be passed as a child (AudioCommentWaveformDisplay from waveform.dart)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Header widget for the audio comment feature.
/// Arranges a waveform, a back button (top-left), and a play button (center-right) in a Stack layout.
/// Handles its own navigation and play logic internally.
class AudioCommentHeader extends StatelessWidget {
  final Widget waveform;
  final AudioTrackId trackId;

  const AudioCommentHeader({
    super.key,
    required this.waveform,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 350, // Increased height for a more prominent waveform
        child: Stack(
          children: [
            // Waveform fills the header
            Positioned.fill(child: waveform),

            // Back button (top-left)
            Positioned(
              top: 24,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Play/Pause button (bottom-right)
            Positioned(
              right: 32,
              bottom: 24,
              child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  bool isPlaying = state is AudioPlayerPlaying;
                  bool isBuffering = state is AudioPlayerBuffering;
                  IconData icon = isPlaying ? Icons.pause : Icons.play_arrow;
                  return IconButton(
                    icon: Icon(icon, size: 32, color: Colors.black),
                    onPressed:
                        isBuffering
                            ? null
                            : () {
                              final audioPlayerBloc =
                                  context.read<AudioPlayerBloc>();
                              if (isPlaying) {
                                audioPlayerBloc.add(
                                  const PauseAudioRequested(),
                                );
                              } else {
                                audioPlayerBloc.add(
                                  const ResumeAudioRequested(),
                                );
                              }
                            },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
