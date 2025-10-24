import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import 'audio_controls.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_state.dart';
import 'package:trackflow/core/theme/app_colors.dart';


/// Pure audio player widget with full controls
/// NO business logic - only audio playback features
/// NO context dependency - works standalone
/// Includes: volume, repeat modes, shuffle, etc.
class PureAudioPlayer extends StatelessWidget {
  const PureAudioPlayer({
    super.key,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.showVolumeControl = true,
    this.showTrackInfo = true,
  });

  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showVolumeControl;
  final bool showTrackInfo;

  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            String? title;
            String? coverUrl;

            if (state is AudioPlayerSessionState) {
              final current = state.session.currentTrack;
              if (current != null) {
                title = current.title;
                coverUrl = current.coverUrl;
              }
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showTrackInfo) ...[
                  TrackCoverArtSizes.large(
                    metadata: null,
                    imageUrl: coverUrl,
                    showShadow: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title ?? 'No track selected',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<AudioContextBloc, AudioContextState>(
                    builder: (context, contextState) {
                      String uploaderName = '';
                      if (contextState is AudioContextLoaded && contextState.collaborator != null) {
                        uploaderName = contextState.collaborator!.name;
                      }
                      if (uploaderName.isEmpty) return const SizedBox.shrink();
                      return Text(
                        uploaderName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                const AudioControls(
                  size: 48.0,
                  showStop: false,
                  spacing: 20.0,
                ),
                const SizedBox(height: 12),
                const QueueControls(
                  size: 32.0,
                  spacing: 16.0,
                  showRepeatMode: true,
                  showShuffleMode: true,
                ),
                const SizedBox(height: 12),
                const PlaybackProgress(
                  height: 4.0,
                  thumbRadius: 10.0,
                  showTimeLabels: true,
                ),
              ],
            );
          },
        ),
      );
    }
  }