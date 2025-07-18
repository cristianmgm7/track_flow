// Rename this file to audio_comment_header.dart and the class to AudioCommentHeader
// This widget is only responsible for arranging the header layout (Stack: back button, waveform, play button)
// The waveform widget should be passed as a child (AudioCommentWaveformDisplay from waveform.dart)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'waveform.dart';

/// Header widget for the audio comment feature.
/// Complete header section with container styling, waveform, play controls, and time display.
/// Handles navigation, play logic, and visual presentation internally.
class AudioCommentHeader extends StatelessWidget {
  final AudioTrack track;

  const AudioCommentHeader({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final bgColor = generateTrackCoverColor(track, context);
    return Container(
      color: bgColor,
      child: SafeArea(
        child: SizedBox(
          height: 350, // Increased height for a more prominent waveform
          child: Stack(
            children: [
              // Waveform fills the header
              Positioned.fill(
                child: AudioCommentWaveformDisplay(trackId: track.id),
              ),
              // Play/Pause button (bottom-right)
              Positioned(
                right: 32,
                bottom: 24,
                child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    final isPlaying = state is AudioPlayerPlaying;
                    final isBuffering = state is AudioPlayerBuffering;
                    return AudioPlayPauseButton(
                      isPlaying: isPlaying,
                      isBuffering: isBuffering,
                      size: 60,
                      iconSize: 36,
                      backgroundColor: Colors.white,
                      iconColor: Colors.black,
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
              // Playback time (bottom-left)
              Positioned(
                left: 16,
                bottom: 24,
                child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    Duration position = Duration.zero;
                    if (state is AudioPlayerSessionState) {
                      position = state.session.position;
                    }
                    final minutes = position.inMinutes
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = (position.inSeconds % 60)
                        .toString()
                        .padLeft(2, '0');
                    return Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
