import 'package:flutter/material.dart';

/// Draws only the progressed part of the waveform bars (left of playhead)
/// using the provided progress color. This should be painted above the base
/// static waveform to visually differentiate played vs remaining.
class WaveformProgressPainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration duration;
  final Duration progress;
  final Color progressColor;
  final double paddingTop;
  final double paddingBottom;

  WaveformProgressPainter({
    required this.amplitudes,
    required this.duration,
    required this.progress,
    required this.progressColor,
    this.paddingTop = 2.0,
    this.paddingBottom = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty || duration.inMilliseconds <= 0) return;

    final double barWidth = size.width / amplitudes.length;
    final double baselineY = size.height - paddingBottom;
    final double maxHeight = size.height - paddingTop - paddingBottom;
    final double progressX =
        (progress.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0) *
        size.width;

    final paint =
        Paint()
          ..color = progressColor
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    // Draw only bars whose x lies left of progressX
    for (int i = 0; i < amplitudes.length; i++) {
      final double x = i * barWidth;
      if (x > progressX) break;
      final double barHeight =
          (amplitudes[i] * maxHeight).clamp(1.0, maxHeight).toDouble();
      canvas.drawLine(
        Offset(x, baselineY),
        Offset(x, baselineY - barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformProgressPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
        duration != oldDelegate.duration ||
        progress != oldDelegate.progress ||
        progressColor != oldDelegate.progressColor ||
        paddingTop != oldDelegate.paddingTop ||
        paddingBottom != oldDelegate.paddingBottom;
  }
}
