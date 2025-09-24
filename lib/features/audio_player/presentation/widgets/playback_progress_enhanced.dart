import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import '../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../audio_context/presentation/bloc/audio_context_state.dart';

/// Enhanced playback progress slider that gets duration from AudioContext
/// and position from AudioPlayer for accurate progress tracking
class PlaybackProgressEnhanced extends StatefulWidget {
  const PlaybackProgressEnhanced({
    super.key,
    this.height = 4.0,
    this.thumbRadius = 8.0,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.showTimeLabels = true,
    this.timeTextStyle,
  });

  final double height;
  final double thumbRadius;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final bool showTimeLabels;
  final TextStyle? timeTextStyle;

  @override
  State<PlaybackProgressEnhanced> createState() =>
      _PlaybackProgressEnhancedState();
}

class _PlaybackProgressEnhancedState extends State<PlaybackProgressEnhanced> {
  bool _isDragging = false;
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        // Get position from AudioPlayer
        Duration position = Duration.zero;

        if (playerState is AudioPlayerSessionState) {
          final session = playerState.session;
          position =
              _isDragging
                  ? Duration
                      .zero // We'll calculate this below
                  : session.position;
        }

        // Get duration from AudioContext
        return BlocBuilder<AudioContextBloc, AudioContextState>(
          builder: (context, contextState) {
            Duration duration = Duration.zero;

            if (contextState is AudioContextLoaded) {
              duration =
                  contextState.context.activeVersionDuration ?? Duration.zero;
            }

            // Calculate drag position if dragging
            if (_isDragging && duration.inMilliseconds > 0) {
              position = Duration(
                milliseconds: (_dragPosition * duration.inMilliseconds).round(),
              );
            }

            // Calculate progress
            double progress = 0.0;
            if (duration.inMilliseconds > 0) {
              progress =
                  _isDragging
                      ? _dragPosition
                      : position.inMilliseconds / duration.inMilliseconds;
            }

            // Only show slider if we have valid duration
            final bool hasValidDuration = duration.inMilliseconds > 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: widget.height,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: widget.thumbRadius,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: widget.thumbRadius * 1.5,
                    ),
                    activeTrackColor: widget.activeColor ?? theme.primaryColor,
                    inactiveTrackColor:
                        widget.inactiveColor ??
                        theme.primaryColor.withValues(alpha: 0.3),
                    thumbColor: widget.thumbColor ?? theme.primaryColor,
                    overlayColor: (widget.thumbColor ?? theme.primaryColor)
                        .withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged:
                        hasValidDuration
                            ? (value) {
                              setState(() {
                                _isDragging = true;
                                _dragPosition = value;
                              });
                            }
                            : null,
                    onChangeEnd:
                        hasValidDuration
                            ? (value) {
                              final newPosition = Duration(
                                milliseconds:
                                    (value * duration.inMilliseconds).round(),
                              );

                              context.read<AudioPlayerBloc>().add(
                                SeekToPositionRequested(newPosition),
                              );

                              setState(() {
                                _isDragging = false;
                                _dragPosition = 0.0;
                              });
                            }
                            : null,
                  ),
                ),

                // Time labels
                if (widget.showTimeLabels)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style:
                              widget.timeTextStyle ??
                              theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style:
                              widget.timeTextStyle ??
                              theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }
}
