import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'package:trackflow/features/ui/auth/glassmorphism_card.dart';

class AudioCommentMiniPlayer extends StatelessWidget {
  final AudioTrack track;

  const AudioCommentMiniPlayer({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final bgColor = generateTrackCoverColor(track, context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 64,
      child: GlassmorphismCard(
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: bgColor.withValues(alpha: 0.22),
        child: Row(
          children: [
            // Title + timer + progress on the left
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          track.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Timer
                      BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                        builder: (context, state) {
                          Duration position = Duration.zero;
                          if (state is AudioPlayerSessionState &&
                              state.session.currentTrack?.id == track.id) {
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
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress line
                  BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                    builder: (context, state) {
                      double progress = 0;
                      if (state is AudioPlayerSessionState &&
                          state.session.currentTrack?.id == track.id) {
                        final totalMs = track.duration.inMilliseconds;
                        final posMs = state.session.position.inMilliseconds
                            .clamp(0, totalMs);
                        progress = totalMs == 0 ? 0 : posMs / totalMs;
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Play/Pause button on the right
            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                final isPlaying = state is AudioPlayerPlaying;
                final isBuffering = state is AudioPlayerBuffering;
                final session =
                    state is AudioPlayerSessionState ? state.session : null;
                final isDifferentTrack = session?.currentTrack?.id != track.id;
                return AudioPlayPauseButton(
                  isPlaying: isPlaying && !isDifferentTrack,
                  isBuffering: isBuffering,
                  size: 40,
                  iconSize: 22,
                  backgroundColor: Colors.white,
                  iconColor: Colors.black,
                  onPressed:
                      isBuffering
                          ? null
                          : () {
                            final audioPlayerBloc =
                                context.read<AudioPlayerBloc>();
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
