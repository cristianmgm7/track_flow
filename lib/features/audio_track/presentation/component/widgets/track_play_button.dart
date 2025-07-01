import 'package:flutter/material.dart';

/// Configuration for the track play button appearance and behavior
class TrackPlayButtonConfig {
  final double size;
  final Color enabledColor;
  final Color disabledColor;
  final double borderRadius;
  final Duration animationDuration;

  const TrackPlayButtonConfig({
    this.size = 44.0,
    this.enabledColor = Colors.blueAccent,
    this.disabledColor = Colors.grey,
    this.borderRadius = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });
}

/// Specialized widget responsible only for displaying and handling track play/pause button
class TrackPlayButton extends StatelessWidget {
  final bool isCurrentTrack;
  final bool isPlaying;
  final bool isEnabled;
  final VoidCallback? onTap;
  final TrackPlayButtonConfig config;

  const TrackPlayButton({
    super.key,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.isEnabled,
    this.onTap,
    this.config = const TrackPlayButtonConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: config.size,
      height: config.size,
      child: Material(
        color: isEnabled ? config.enabledColor : config.disabledColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(config.borderRadius),
          onTap: isEnabled ? onTap : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: config.animationDuration,
              child: _buildIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isCurrentTrack) {
      return isPlaying
          ? const Icon(
              Icons.pause,
              color: Colors.white,
              size: 28,
              key: ValueKey('pause'),
            )
          : const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
              key: ValueKey('play_current'),
            );
    }

    return const Icon(
      Icons.play_arrow,
      color: Colors.white,
      size: 28,
      key: ValueKey('play'),
    );
  }
}