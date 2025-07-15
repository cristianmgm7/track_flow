import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/repeat_mode.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';

/// Pure audio queue controls (next/previous/shuffle/repeat)
/// NO business logic - only audio queue operations
/// NO context dependency - works standalone
class QueueControls extends StatelessWidget {
  const QueueControls({
    super.key,
    this.size = 24.0,
    this.color,
    this.spacing = 8.0,
    this.showRepeatMode = true,
    this.showShuffleMode = true,
  });

  final double size;
  final Color? color;
  final double spacing;
  final bool showRepeatMode;
  final bool showShuffleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.primaryColor;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shuffle button
            if (showShuffleMode) ...[
              _buildShuffleButton(context, state, iconColor),
              SizedBox(width: spacing),
            ],

            // Previous button
            _buildPreviousButton(context, state, iconColor),
            SizedBox(width: spacing),

            // Next button
            _buildNextButton(context, state, iconColor),

            // Repeat mode button
            if (showRepeatMode) ...[
              SizedBox(width: spacing),
              _buildRepeatButton(context, state, iconColor),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPreviousButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    bool canGoToPrevious = false;

    if (state is AudioPlayerSessionState) {
      canGoToPrevious = state.session.hasPrevious;
    }

    return IconButton(
      onPressed:
          canGoToPrevious
              ? () => context.read<AudioPlayerBloc>().add(
                const SkipToPreviousRequested(),
              )
              : null,
      icon: Icon(
        Icons.skip_previous,
        size: size,
        color: canGoToPrevious ? iconColor : iconColor.withValues(alpha: 0.3),
      ),
      tooltip: 'Previous track',
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    bool canGoToNext = false;

    if (state is AudioPlayerSessionState) {
      canGoToNext = state.session.hasNext;
    }

    return IconButton(
      onPressed:
          canGoToNext
              ? () => context.read<AudioPlayerBloc>().add(
                const SkipToNextRequested(),
              )
              : null,
      icon: Icon(
        Icons.skip_next,
        size: size,
        color: canGoToNext ? iconColor : iconColor.withValues(alpha: 0.3),
      ),
      tooltip: 'Next track',
    );
  }

  Widget _buildShuffleButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    bool isShuffleEnabled = false;
    bool hasQueue = false;

    if (state is AudioPlayerSessionState) {
      isShuffleEnabled = state.session.shuffleEnabled;
      hasQueue = state.session.queue.length > 1;
    }

    return IconButton(
      onPressed:
          hasQueue
              ? () => context.read<AudioPlayerBloc>().add(
                const ToggleShuffleRequested(),
              )
              : null,
      icon: Icon(
        Icons.shuffle,
        size: size,
        color:
            hasQueue
                ? (isShuffleEnabled
                    ? iconColor
                    : iconColor.withValues(alpha: 0.5))
                : iconColor.withValues(alpha: 0.3),
      ),
      tooltip: isShuffleEnabled ? 'Disable shuffle' : 'Enable shuffle',
    );
  }

  Widget _buildRepeatButton(
    BuildContext context,
    AudioPlayerState state,
    Color iconColor,
  ) {
    RepeatMode repeatMode = RepeatMode.none;
    bool hasQueue = false;

    if (state is AudioPlayerSessionState) {
      repeatMode = state.session.repeatMode;
      hasQueue = state.session.queue.isNotEmpty;
    }

    IconData icon;
    String tooltip;
    Color buttonColor;

    switch (repeatMode) {
      case RepeatMode.none:
        icon = Icons.repeat;
        tooltip = 'Enable repeat';
        buttonColor =
            hasQueue
                ? iconColor.withValues(alpha: 0.5)
                : iconColor.withValues(alpha: 0.3);
        break;
      case RepeatMode.single:
        icon = Icons.repeat_one;
        tooltip = 'Repeat current track';
        buttonColor = iconColor;
        break;
      case RepeatMode.queue:
        icon = Icons.repeat;
        tooltip = 'Repeat queue';
        buttonColor = iconColor;
        break;
    }

    return IconButton(
      onPressed:
          hasQueue
              ? () => context.read<AudioPlayerBloc>().add(
                const ToggleRepeatModeRequested(),
              )
              : null,
      icon: Icon(icon, size: size, color: buttonColor),
      tooltip: tooltip,
    );
  }
}
