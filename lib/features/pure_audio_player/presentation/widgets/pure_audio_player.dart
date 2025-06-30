import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import 'audio_controls.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';

/// Pure audio player widget with full controls
/// NO business logic - only audio playback features
/// NO context dependency - works standalone
/// Includes: volume, speed, repeat modes, shuffle, etc.
class PureAudioPlayer extends StatelessWidget {
  const PureAudioPlayer({
    super.key,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.showVolumeControl = true,
    this.showSpeedControl = true,
    this.showTrackInfo = true,
  });

  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showVolumeControl;
  final bool showSpeedControl;
  final bool showTrackInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track info section
                if (showTrackInfo) ...[
                  _buildTrackInfo(context, state, theme),
                  const SizedBox(height: 16),
                ],

                // Progress bar
                const PlaybackProgress(
                  height: 4.0,
                  thumbRadius: 8.0,
                  showTimeLabels: true,
                ),
                const SizedBox(height: 20),

                // Main controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Queue controls
                    const QueueControls(
                      size: 28.0,
                      spacing: 12.0,
                      showRepeatMode: true,
                      showShuffleMode: true,
                    ),
                    const SizedBox(width: 20),

                    // Main audio controls
                    const AudioControls(
                      size: 32.0,
                      showStop: true,
                      spacing: 12.0,
                    ),
                  ],
                ),

                // Additional controls
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Volume control
                    if (showVolumeControl)
                      Expanded(
                        child: _buildVolumeControl(context, state, theme),
                      ),

                    if (showVolumeControl && showSpeedControl)
                      const SizedBox(width: 20),

                    // Speed control
                    if (showSpeedControl)
                      Expanded(
                        child: _buildSpeedControl(context, state, theme),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
  ) {
    String title = 'No track selected';
    String artist = '';
    String? albumArt;

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        artist = session.currentTrack!.artist;
        albumArt = session.currentTrack!.coverUrl;
      }
    } else if (state is AudioPlayerReady) {
      title = 'Ready to play';
      artist = 'Select a track to begin';
    } else if (state is AudioPlayerLoading) {
      title = 'Loading...';
      artist = 'Preparing audio player';
    } else if (state is AudioPlayerError) {
      title = 'Playback Error';
      artist = 'Please try again';
    }

    return Row(
      children: [
        // Album art or placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.primaryColor.withValues(alpha: 0.1),
          ),
          child: albumArt != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    albumArt,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.music_note,
                      color: theme.primaryColor,
                      size: 30,
                    ),
                  ),
                )
              : Icon(
                  Icons.music_note,
                  color: theme.primaryColor,
                  size: 30,
                ),
        ),
        const SizedBox(width: 16),

        // Track details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (artist.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeControl(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
  ) {
    double volume = 1.0;

    if (state is AudioPlayerSessionState) {
      volume = state.session.volume;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          volume == 0 ? Icons.volume_off : Icons.volume_up,
          size: 20,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: volume,
              onChanged: (value) {
                context.read<AudioPlayerBloc>().add(
                  SetVolumeRequested(value),
                );
              },
            ),
          ),
        ),
        Text(
          '${(volume * 100).round()}%',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSpeedControl(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
  ) {
    double speed = 1.0;

    if (state is AudioPlayerSessionState) {
      speed = state.session.playbackSpeed;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.speed,
          size: 20,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: speed,
              min: 0.5,
              max: 2.0,
              divisions: 6, // 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
              onChanged: (value) {
                context.read<AudioPlayerBloc>().add(
                  SetPlaybackSpeedRequested(value),
                );
              },
            ),
          ),
        ),
        Text(
          '${speed.toStringAsFixed(1)}x',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}