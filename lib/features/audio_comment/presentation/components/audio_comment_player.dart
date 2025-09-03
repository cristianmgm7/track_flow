import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/waveform/presentation/widgets/enhanced_waveform_display.dart';

class AudioCommentPlayer extends StatelessWidget {
  final AudioTrack track;

  const AudioCommentPlayer({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        color: theme.colorScheme.surface,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.screenMarginSmall,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 96,
              child: EnhancedWaveformDisplay(track: track, height: 96),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Current time
                BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    Duration position = Duration.zero;
                    if (state is AudioPlayerSessionState &&
                        state.session.currentTrack?.id == track.id) {
                      position = state.session.position;
                    }
                    return Text(
                      _format(position),
                      style: AppTextStyle.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                Text(
                  _format(track.duration),
                  style: AppTextStyle.caption.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 12),
                _PlayPause(track: track),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlayPause extends StatelessWidget {
  final AudioTrack track;
  const _PlayPause({required this.track});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final session = state is AudioPlayerSessionState ? state.session : null;
        final isPlaying =
            state is AudioPlayerPlaying &&
            session?.currentTrack?.id == track.id;
        final isBuffering = state is AudioPlayerBuffering;
        final isDifferentTrack = session?.currentTrack?.id != track.id;

        return IconButton(
          onPressed:
              isBuffering
                  ? null
                  : () {
                    final audioPlayerBloc = context.read<AudioPlayerBloc>();
                    if (isDifferentTrack) {
                      audioPlayerBloc.add(PlayAudioRequested(track.id));
                      return;
                    }
                    if (isPlaying) {
                      audioPlayerBloc.add(const PauseAudioRequested());
                    } else {
                      audioPlayerBloc.add(const ResumeAudioRequested());
                    }
                  },
          iconSize: 28,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: AppColors.onPrimary,
            shape: const CircleBorder(),
          ),
          icon: Icon(
            isPlaying && !isDifferentTrack ? Icons.pause : Icons.play_arrow,
          ),
        );
      },
    );
  }
}
