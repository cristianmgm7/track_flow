import 'package:flutter/material.dart';

/// Header widget that arranges a waveform, a back button (top-left), and a play button (center-right) in a Stack layout.
class AudioWaveformHeader extends StatelessWidget {
  final Widget waveform;
  final VoidCallback onBack;
  final VoidCallback onPlay;

  const AudioWaveformHeader({
    super.key,
    required this.waveform,
    required this.onBack,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600, // Adjust as needed for your design
      child: Stack(
        children: [
          // Centered waveform
          Center(child: waveform),

          // Back button (top-left)
          Positioned(
            top: 24,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          ),

          // Play button (center-right)
          Positioned(
            right: 32,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 48,
                onPressed: onPlay,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
