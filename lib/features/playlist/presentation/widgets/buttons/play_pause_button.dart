import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPressed;
  final double size;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    this.isBuffering = false,
    required this.onPressed,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return AudioPlayPauseButton(
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      onPressed: onPressed,
      size: size,
    );
  }
}
