import 'package:flutter/material.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
      ),
      label: Text(isPlaying ? 'Pause' : 'Play All'),
      onPressed: onPressed,
    );
  }
}