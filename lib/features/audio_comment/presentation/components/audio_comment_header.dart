// Rename this file to audio_comment_header.dart and the class to AudioCommentHeader
// This widget is only responsible for arranging the header layout (Stack: back button, waveform, play button)
// The waveform widget should be passed as a child (AudioCommentWaveformDisplay from waveform.dart)

import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'waveform.dart';

/// Header widget for the audio comment feature.
/// Complete header section with container styling, waveform, play controls, and time display.
/// Handles navigation, play logic, and visual presentation internally.
class AudioCommentHeader extends StatelessWidget {
  final AudioTrack track;

  const AudioCommentHeader({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final bgColor = generateTrackCoverColor(track, context);
    return Container(
      color: bgColor,
      child: SafeArea(
        child: SizedBox(
          height: 350, // Increased height for a more prominent waveform
          child: Stack(
            children: [
              // Waveform fills the header
              Positioned.fill(
                child: AudioCommentWaveformDisplay(trackId: track.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
