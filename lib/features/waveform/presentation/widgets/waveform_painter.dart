import 'package:flutter/material.dart';

/// Renders the static waveform bars only. No playheads or UI chrome here.
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final double paddingTop;
  final double paddingBottom;

  WaveformPainter({
    required this.amplitudes,
    required this.waveColor,
    this.paddingTop = 2.0,
    this.paddingBottom = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final double barWidth = size.width / amplitudes.length;
    final double baselineY = size.height - paddingBottom;
    final double maxHeight = size.height - paddingTop - paddingBottom;

    for (int i = 0; i < amplitudes.length; i++) {
      final double x = i * barWidth;
      final double barHeight =
          (amplitudes[i] * maxHeight).clamp(1.0, maxHeight).toDouble();

      final paint =
          Paint()
            ..color = waveColor
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, baselineY),
        Offset(x, baselineY - barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
        waveColor != oldDelegate.waveColor ||
        paddingTop != oldDelegate.paddingTop ||
        paddingBottom != oldDelegate.paddingBottom;
  }
}
