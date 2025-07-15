import 'package:flutter/material.dart';

/// Utility class responsible only for duration formatting and display
class TrackDurationFormatter {
  const TrackDurationFormatter._();

  /// Format duration to MM:SS format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Format duration with hours if needed (HH:MM:SS)
  static String formatDurationLong(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }
    
    return formatDuration(duration);
  }
}

/// Configuration for duration text display
class TrackDurationConfig {
  final double width;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final bool showLongFormat;

  const TrackDurationConfig({
    this.width = 48.0,
    this.textStyle,
    this.textAlign = TextAlign.right,
    this.showLongFormat = false,
  });
}

/// Widget responsible only for displaying formatted track duration
class TrackDurationText extends StatelessWidget {
  final Duration duration;
  final TrackDurationConfig config;

  const TrackDurationText({
    super.key,
    required this.duration,
    this.config = const TrackDurationConfig(),
  });

  @override
  Widget build(BuildContext context) {
    final durationStr = config.showLongFormat
        ? TrackDurationFormatter.formatDurationLong(duration)
        : TrackDurationFormatter.formatDuration(duration);

    final defaultStyle = TextStyle(
      color: Colors.grey[700],
      fontSize: 13,
    );

    return SizedBox(
      width: config.width,
      child: Text(
        durationStr,
        style: config.textStyle ?? defaultStyle,
        overflow: TextOverflow.ellipsis,
        textAlign: config.textAlign,
      ),
    );
  }
}