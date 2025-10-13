import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import 'audio_controls.dart';
import 'expanded_track_info.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';
import 'volume_control.dart';
import '../../../../core/theme/app_colors.dart';


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
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ExpandedTrackInfo(state: state),
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
                          VolumeControl(state: state),
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
                        child: ExpandedTrackInfo(state: state),
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
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          // Volume control
                          if (showVolumeControl) ...[
                            VolumeControl(state: state),
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


}
