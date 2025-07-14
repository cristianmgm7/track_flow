import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app_dimensions.dart';
import '../../app_colors.dart';
import '../../app_animations.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_event.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_state.dart';

/// Audio control buttons component following TrackFlow design system
/// Replaces hardcoded values with design system constants
class AppAudioControls extends StatelessWidget {
  const AppAudioControls({
    super.key,
    this.size,
    this.color,
    this.showStop = true,
    this.spacing,
  });

  final double? size;
  final Color? color;
  final bool showStop;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = size ?? Dimensions.iconMedium;
    final iconColor = color ?? theme.colorScheme.primary;
    final buttonSpacing = spacing ?? Dimensions.space8;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stop button (optional)
            if (showStop) ...[
              _buildStopButton(context, state, iconColor, iconSize),
              SizedBox(width: buttonSpacing),
            ],

            // Main play/pause button
            _buildPlayPauseButton(context, state, iconColor, iconSize),
          ],
        );
      },
    );
  }

  Widget _buildPlayPauseButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
    double iconSize,
  ) {
    IconData icon;
    VoidCallback? onPressed;
    bool isLoading = false;

    if (state is AudioPlayerPlaying) {
      icon = Icons.pause_rounded;
      onPressed = () => context.read<AudioPlayerBloc>().add(
        const PauseAudioRequested(),
      );
    } else if (state is AudioPlayerPaused || 
               state is AudioPlayerStopped || 
               state is AudioPlayerCompleted) {
      icon = Icons.play_arrow_rounded;
      onPressed = () => context.read<AudioPlayerBloc>().add(
        const ResumeAudioRequested(),
      );
    } else if (state is AudioPlayerBuffering) {
      icon = Icons.play_arrow_rounded;
      isLoading = true;
      onPressed = null; // Disable while loading
    } else if (state is AudioPlayerReady) {
      icon = Icons.play_arrow_rounded;
      onPressed = null; // No track to play
    } else if (state is AudioPlayerError) {
      icon = Icons.refresh_rounded;
      onPressed = () {
        // Could add retry logic here
        // For now, just show the icon
      };
    } else {
      icon = Icons.play_arrow_rounded;
      onPressed = null;
    }

    return AnimatedScale(
      scale: onPressed != null ? 1.0 : 0.9,
      duration: AppAnimations.fast,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: iconSize + Dimensions.space16,
            height: iconSize + Dimensions.space16,
            decoration: BoxDecoration(
              color: onPressed != null 
                  ? iconColor.withValues(alpha: 0.1)
                  : AppColors.disabled.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusRound),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon, 
                size: iconSize, 
                color: onPressed != null ? iconColor : AppColors.disabled,
              ),
              tooltip: _getTooltip(icon),
              splashRadius: iconSize,
            ),
          ),
          if (isLoading)
            SizedBox(
              width: iconSize + Dimensions.space8,
              height: iconSize + Dimensions.space8,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: iconColor.withValues(alpha: 0.6),
                backgroundColor: iconColor.withValues(alpha: 0.1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
    double iconSize,
  ) {
    final canStop = state is AudioPlayerSessionState &&
        (state is AudioPlayerPlaying || 
         state is AudioPlayerPaused || 
         state is AudioPlayerBuffering);

    return AnimatedScale(
      scale: canStop ? 1.0 : 0.9,
      duration: AppAnimations.fast,
      child: Container(
        width: iconSize + Dimensions.space12,
        height: iconSize + Dimensions.space12,
        decoration: BoxDecoration(
          color: canStop 
              ? iconColor.withValues(alpha: 0.1)
              : AppColors.disabled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        ),
        child: IconButton(
          onPressed: canStop
              ? () => context.read<AudioPlayerBloc>().add(
                    const StopAudioRequested(),
                  )
              : null,
          icon: Icon(
            Icons.stop_rounded,
            size: iconSize * 0.8,
            color: canStop ? iconColor : AppColors.disabled,
          ),
          tooltip: 'Stop',
          splashRadius: iconSize * 0.6,
        ),
      ),
    );
  }

  String _getTooltip(IconData icon) {
    switch (icon) {
      case Icons.play_arrow_rounded:
        return 'Play';
      case Icons.pause_rounded:
        return 'Pause';
      case Icons.refresh_rounded:
        return 'Retry';
      default:
        return '';
    }
  }
}