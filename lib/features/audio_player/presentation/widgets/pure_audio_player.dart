import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import '../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../audio_context/presentation/bloc/audio_context_state.dart';
import 'audio_controls.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_borders.dart';

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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Check if this is being used inside a modal (transparent background)
    final isInModal = backgroundColor == Colors.transparent;

    if (isInModal) {
      // When used inside a modal, don't apply glass effect
      return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              children: [
                // Track info section - expanded to be more prominent
                if (showTrackInfo) ...[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildExpandedTrackInfo(
                        context,
                        state,
                        theme,
                        screenSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  const Spacer(flex: 3),
                ],

                // Progress bar section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const PlaybackProgress(
                    height: 4.0,
                    thumbRadius: 10.0,
                    showTimeLabels: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Main controls section - larger and more prominent
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Queue controls
                      const QueueControls(
                        size: 32.0,
                        spacing: 16.0,
                        showRepeatMode: true,
                        showShuffleMode: true,
                      ),

                      // Main audio controls - even larger for full screen
                      const AudioControls(
                        size: 48.0,
                        showStop: false,
                        spacing: 20.0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Additional controls section
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Volume control
                        if (showVolumeControl) ...[
                          _buildVolumeControl(context, state, theme),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      );
    }

    // When used standalone, apply glass effect
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.surface).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey900.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Track info section - expanded to be more prominent
                  if (showTrackInfo) ...[
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildExpandedTrackInfo(
                          context,
                          state,
                          theme,
                          screenSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    const Spacer(flex: 3),
                  ],

                  // Progress bar section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: const PlaybackProgress(
                      height: 4.0,
                      thumbRadius: 10.0,
                      showTimeLabels: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main controls section - larger and more prominent
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Queue controls
                        const QueueControls(
                          size: 32.0,
                          spacing: 16.0,
                          showRepeatMode: true,
                          showShuffleMode: true,
                        ),

                        // Main audio controls - even larger for full screen
                        const AudioControls(
                          size: 48.0,
                          showStop: false,
                          spacing: 20.0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Additional controls section
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          // Volume control
                          if (showVolumeControl) ...[
                            _buildVolumeControl(context, state, theme),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedTrackInfo(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
    Size screenSize,
  ) {
    String title = 'No track selected';
    String artist = '';
    String? albumArt;

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        artist = session.currentTrack!.artist; // Fallback to metadata artist
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

    final albumArtSize = screenSize.width * 0.6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large album art
        Container(
          width: albumArtSize,
          height: albumArtSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.primaryColor.withValues(alpha: 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              albumArt != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      albumArt,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.music_note,
                            color: AppColors.primary,
                            size: albumArtSize * 0.3,
                          ),
                    ),
                  )
                  : Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                    size: albumArtSize * 0.3,
                  ),
        ),

        const SizedBox(height: 32),

        // Track title - larger and centered
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        if (artist.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Use both audio context and audio player state for artist info
          BlocBuilder<AudioContextBloc, AudioContextState>(
            builder: (context, contextState) {
              String displayArtist = artist; // Fallback from audio metadata

              // Override with context if available (more accurate user name)
              if (contextState is AudioContextLoaded &&
                  contextState.collaborator != null) {
                displayArtist = contextState.collaborator!.name;
              }

              return Text(
                displayArtist,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
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
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: volume,
              onChanged: (value) {
                context.read<AudioPlayerBloc>().add(SetVolumeRequested(value));
              },
            ),
          ),
        ),
        Text(
          '${(volume * 100).round()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
