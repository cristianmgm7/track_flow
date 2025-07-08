import 'package:flutter/material.dart';
import 'miniplayer_components/mini_audio_player.dart';

/// Pure mini audio player widget
/// Uses the refactored SOLID-compliant implementation
class PureMiniAudioPlayer extends StatelessWidget {
  const PureMiniAudioPlayer({
    super.key,
    this.height = 80.0,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    this.showQueueControls = true,
    this.showProgress = true,
    this.showTrackInfo = true,
  });

  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showQueueControls;
  final bool showProgress;
  final bool showTrackInfo;

  @override
  Widget build(BuildContext context) {
    return MiniAudioPlayer(
      config: MiniAudioPlayerConfig(
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
        showQueueControls: showQueueControls,
        showProgress: showProgress,
        showTrackInfo: showTrackInfo,
      ),
    );
  }
}
