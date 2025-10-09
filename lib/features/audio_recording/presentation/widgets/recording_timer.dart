import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Reusable timer display during recording
class RecordingTimer extends StatelessWidget {
  final Duration elapsed;
  final TextStyle? style;

  const RecordingTimer({
    super.key,
    required this.elapsed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(elapsed),
      style: style ??
          AppTextStyle.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
