import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';

/// Pure audio control buttons (Play/Pause/Stop)
/// NO business logic - only audio operations
/// NO context dependency - works standalone
class AudioControls extends StatelessWidget {
  const AudioControls({
    super.key,
    this.size = 24.0,
    this.color,
    this.showStop = true,
    this.spacing = 8.0,
  });

  final double size;
  final Color? color;
  final bool showStop;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.primaryColor;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stop button (optional)
            if (showStop) ...[
              _buildStopButton(context, state, iconColor),
              SizedBox(width: spacing),
            ],

            // Main play/pause button
            _buildPlayPauseButton(context, state, iconColor),
          ],
        );
      },
    );
  }

  Widget _buildPlayPauseButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    IconData icon;
    VoidCallback? onPressed;
    bool isLoading = false;

    if (state is AudioPlayerPlaying) {
      icon = Icons.pause;
      onPressed = () => context.read<AudioPlayerBloc>().add(
        const PauseAudioRequested(),
      );
    } else if (state is AudioPlayerPaused || 
               state is AudioPlayerStopped || 
               state is AudioPlayerCompleted) {
      icon = Icons.play_arrow;
      onPressed = () => context.read<AudioPlayerBloc>().add(
        const ResumeAudioRequested(),
      );
    } else if (state is AudioPlayerBuffering) {
      icon = Icons.play_arrow;
      isLoading = true;
      onPressed = null; // Disable while loading
    } else if (state is AudioPlayerReady) {
      icon = Icons.play_arrow;
      onPressed = null; // No track to play
    } else if (state is AudioPlayerError) {
      icon = Icons.refresh;
      onPressed = () {
        // Could add retry logic here
        // For now, just show the icon
      };
    } else {
      icon = Icons.play_arrow;
      onPressed = null;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: size, color: iconColor),
          tooltip: _getTooltip(icon),
        ),
        if (isLoading)
          SizedBox(
            width: size + 8,
            height: size + 8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: iconColor.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildStopButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    final canStop = state is AudioPlayerSessionState &&
        (state is AudioPlayerPlaying || 
         state is AudioPlayerPaused || 
         state is AudioPlayerBuffering);

    return IconButton(
      onPressed: canStop
          ? () => context.read<AudioPlayerBloc>().add(
                const StopAudioRequested(),
              )
          : null,
      icon: Icon(
        Icons.stop,
        size: size,
        color: canStop ? iconColor : iconColor.withValues(alpha: 0.3),
      ),
      tooltip: 'Stop',
    );
  }

  String _getTooltip(IconData icon) {
    switch (icon) {
      case Icons.play_arrow:
        return 'Play';
      case Icons.pause:
        return 'Pause';
      case Icons.refresh:
        return 'Retry';
      default:
        return '';
    }
  }
}