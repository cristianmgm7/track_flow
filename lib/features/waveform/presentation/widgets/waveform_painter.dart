import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration? currentPosition;
  final Duration? duration;
  final Color waveColor;
  final Color? progressColor;

  WaveformPainter({
    required this.amplitudes,
    this.currentPosition,
    this.duration,
    required this.waveColor,
    this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty || (duration?.inMilliseconds ?? 0) == 0) return;

    final barWidth = size.width / amplitudes.length;
    // Draw from bottom baseline upwards (positive-only rendering)
    const double paddingTop = 2.0;
    const double paddingBottom = 2.0;
    final double baselineY = size.height - paddingBottom;
    final double maxHeight = size.height - paddingTop - paddingBottom;
    final progressX =
        (duration?.inMilliseconds ?? 0) > 0
            ? ((currentPosition?.inMilliseconds ?? 0) /
                    (duration!.inMilliseconds)) *
                size.width
            : 0.0;

    // Draw waveform bars
    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final double barHeight =
          (amplitudes[i] * maxHeight).clamp(1.0, maxHeight).toDouble();

      // Choose paint based on playback progress
      final paint =
          Paint()
            ..color = (progressColor != null && x <= progressX) ? progressColor! : waveColor
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round;

      // Draw amplitude bar from baseline upwards only
      canvas.drawLine(
        Offset(x, baselineY),
        Offset(x, baselineY - barHeight),
        paint,
      );
    }

    // Draw progress baseline and knob (circle) at bottom only if we have progress info
    if (currentPosition != null && duration != null) {
      final basePaint =
          Paint()
            ..color = waveColor.withValues(alpha: 0.35)
            ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(0, baselineY + 0.5),
        Offset(size.width, baselineY + 0.5),
        basePaint,
      );

      final knobOuter =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;
      final knobInner =
          Paint()
            ..color = progressColor ?? waveColor
            ..style = PaintingStyle.fill;

      final knobCenter = Offset(progressX, baselineY + 0.5);
      canvas.drawCircle(knobCenter, 8, knobOuter);
      canvas.drawCircle(knobCenter, 5, knobInner);

      // Vertical position line above the knob for clarity
      final positionLine =
          Paint()
            ..color = Colors.white
            ..strokeWidth = 3.0;
      canvas.drawLine(
        Offset(progressX, paddingTop),
        Offset(progressX, baselineY - 1),
        positionLine,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
        currentPosition != oldDelegate.currentPosition ||
        duration != oldDelegate.duration ||
        waveColor != oldDelegate.waveColor ||
        progressColor != oldDelegate.progressColor;
  }
}