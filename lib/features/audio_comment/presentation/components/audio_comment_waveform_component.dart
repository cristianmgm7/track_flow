import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/waveform/audio_waveform_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioCommentWaveform extends StatelessWidget {
  const AudioCommentWaveform({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        if (playerState is! AudioPlayerSessionState ||
            (playerState is! AudioPlayerPlaying &&
                playerState is! AudioPlayerPaused)) {
          return const SizedBox.shrink();
        }

        final track = playerState.session.currentTrack;
        if (track == null) {
          return const SizedBox.shrink();
        }

        return BlocProvider(
          create:
              (context) => sl<AudioWaveformBloc>()..add(LoadWaveform(track.id)),
          child: BlocBuilder<AudioWaveformBloc, AudioWaveformState>(
            builder: (context, waveformState) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildWaveformBody(context, waveformState),
                    const SizedBox(height: 12),
                    _buildControls(context, playerState),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWaveformBody(
    BuildContext context,
    AudioWaveformState waveformState,
  ) {
    switch (waveformState.status) {
      case WaveformStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WaveformStatus.error:
        return Center(
          child: Text('Error: ${waveformState.errorMessage ?? "Unknown"}'),
        );
      case WaveformStatus.ready:
        if (waveformState.playerController != null) {
          return GestureDetector(
            onTapDown:
                (details) => _handleWaveformTap(
                  context,
                  details,
                  waveformState.playerController!,
                ),
            child: AudioFileWaveforms(
              size: const Size(double.infinity, 60),
              playerController: waveformState.playerController!,
              enableSeekGesture: false, // Disabled to handle manually
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: PlayerWaveStyle(
                fixedWaveColor: Colors.blueAccent[100]!,
                liveWaveColor: const Color.fromARGB(255, 104, 14, 177),
                spacing: 4,
                waveThickness: 2,
                showSeekLine: true,
                seekLineColor: const Color.fromARGB(255, 211, 99, 51),
              ),
            ),
          );
        }
        return const Center(child: Text('Preparing waveform...'));
      default:
        return const Center(child: Text('Preparing waveform...'));
    }
  }

  Widget _buildControls(BuildContext context, AudioPlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            playerState is AudioPlayerPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            size: 48,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            final audioPlayerBloc = context.read<AudioPlayerBloc>();
            if (playerState is AudioPlayerPlaying) {
              audioPlayerBloc.add(const PauseAudioRequested());
            } else {
              audioPlayerBloc.add(const ResumeAudioRequested());
            }
          },
        ),
      ],
    );
  }

  void _handleWaveformTap(
    BuildContext context,
    TapDownDetails details,
    PlayerController controller,
  ) async {
    try {
      // Get the render box to calculate the actual width before async call
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final waveformWidth =
          renderBox.size.width - 48; // Subtract container padding (24*2)
      final tapPosition = details.localPosition.dx;
      final seekRatio = (tapPosition / waveformWidth).clamp(0.0, 1.0);

      // Get the total duration of the track
      final totalDuration = await controller.getDuration(DurationType.max);
      if (totalDuration == 0) return;

      final seekPosition = Duration(
        milliseconds: (totalDuration * seekRatio).round(),
      );

      // Send seek event to AudioPlayerBloc
      if (context.mounted) {
        context.read<AudioPlayerBloc>().add(
          SeekToPositionRequested(seekPosition),
        );
      }
    } catch (e) {
      // Error handling - could be logged properly in production
    }
  }
}
