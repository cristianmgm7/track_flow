import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_state.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';

/// Compact controls for the audio comment player: current time, total duration, play/pause.
class AudioCommentControls extends StatelessWidget {
  final AudioTrack track;
  final TrackVersionId? versionId;
  final double buttonSize;

  const AudioCommentControls({
    super.key,
    required this.track,
    required this.versionId,
    this.buttonSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Derive duration from the loaded versions when available
    final Duration displayedDuration = context
        .select<TrackVersionsBloc, Duration>((bloc) {
          final state = bloc.state;
          if (state is TrackVersionsLoaded && versionId != null) {
            if (state.versions.isNotEmpty) {
              final v = state.versions.firstWhere(
                (vv) => vv.id == versionId,
                orElse: () => state.versions.first,
              );
              if (v.durationMs != null) {
                return Duration(milliseconds: v.durationMs!);
              }
            }
          }
          return track.duration;
        });

    return Row(
      children: [
        // Current time
        BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, playerState) {
            // Show preview position while scrubbing, otherwise live playback position
            final waveformState = context.watch<WaveformBloc>().state;
            Duration position;
            if (waveformState.isScrubbing &&
                waveformState.previewPosition != null) {
              position = waveformState.previewPosition!;
            } else {
              position = Duration.zero;
              if (playerState is AudioPlayerSessionState &&
                  playerState.session.currentTrack?.id == track.id) {
                position = playerState.session.position;
              }
            }
            return Text(
              _format(position),
              style: AppTextStyle.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            );
          },
        ),
        const Spacer(),
        Text(
          _format(displayedDuration),
          style: AppTextStyle.caption.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            final session =
                state is AudioPlayerSessionState ? state.session : null;
            final isPlaying =
                state is AudioPlayerPlaying &&
                session?.currentTrack?.id == track.id;
            final isBuffering = state is AudioPlayerBuffering;
            final isDifferentTrack = session?.currentTrack?.id != track.id;

            return AudioPlayPauseButton(
              isPlaying: isPlaying,
              isBuffering: isBuffering && !isDifferentTrack,
              size: buttonSize,
              onPressed: () {
                final audioPlayerBloc = context.read<AudioPlayerBloc>();
                if (isDifferentTrack) {
                  // Safe-guard: versionId should be provided by parent using effective active version
                  if (versionId != null) {
                    audioPlayerBloc.add(PlayVersionRequested(versionId!));
                  }
                  return;
                }
                if (isPlaying) {
                  audioPlayerBloc.add(const PauseAudioRequested());
                } else {
                  audioPlayerBloc.add(const ResumeAudioRequested());
                }
              },
            );
          },
        ),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
