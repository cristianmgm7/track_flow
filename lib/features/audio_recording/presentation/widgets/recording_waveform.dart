import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';

/// Reusable waveform visualization during recording
class RecordingWaveform extends StatelessWidget {
  final double amplitude;
  final Color? color;
  final double height;

  const RecordingWaveform({
    super.key,
    required this.amplitude,
    this.color,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: WaveformPainter(
          amplitude: amplitude,
          color: color ?? AppColors.primary,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double amplitude;
  final Color color;

  WaveformPainter({required this.amplitude, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final barHeight = amplitude * size.height;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 6,
      height: barHeight.clamp(10.0, size.height),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude;
  }
}
