import 'package:flutter/material.dart';

/// Draws overlay UI on top of the waveform: playhead, preview head while scrubbing,
/// baseline and knob. No gesture logic here.
class WaveformOverlay extends StatelessWidget {
  final Duration duration;
  final Duration playbackPosition;
  final Duration? previewPosition;
  final bool isScrubbing;
  final Color progressColor;
  final Color baselineColor;
  final double paddingTop;
  final double paddingBottom;

  const WaveformOverlay({
    super.key,
    required this.duration,
    required this.playbackPosition,
    required this.previewPosition,
    required this.isScrubbing,
    required this.progressColor,
    required this.baselineColor,
    this.paddingTop = 2.0,
    this.paddingBottom = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double baselineY = height - paddingBottom;
        final double progressX = _xFor(playbackPosition, duration, width);
        final double? previewX =
            previewPosition == null
                ? null
                : _xFor(previewPosition!, duration, width);

        return CustomPaint(
          size: Size(width, height),
          painter: _OverlayPainter(
            baselineY: baselineY,
            paddingTop: paddingTop,
            progressX: progressX,
            previewX: previewX,
            showPreview: isScrubbing && previewX != null,
            progressColor: progressColor,
            baselineColor: baselineColor,
          ),
        );
      },
    );
  }

  double _xFor(Duration pos, Duration dur, double width) {
    if (dur.inMilliseconds <= 0) return 0;
    final ratio = (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
    return ratio * width;
  }
}

class _OverlayPainter extends CustomPainter {
  final double baselineY;
  final double paddingTop;
  final double progressX;
  final double? previewX;
  final bool showPreview;
  final Color progressColor;
  final Color baselineColor;

  _OverlayPainter({
    required this.baselineY,
    required this.paddingTop,
    required this.progressX,
    required this.previewX,
    required this.showPreview,
    required this.progressColor,
    required this.baselineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Baseline
    final basePaint =
        Paint()
          ..color = baselineColor.withValues(alpha: 0.35)
          ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, baselineY + 0.5),
      Offset(size.width, baselineY + 0.5),
      basePaint,
    );

    // Current playhead (dim if also previewing)
    final positionLine =
        Paint()
          ..color = showPreview ? Colors.white.withValues(alpha: 0.55) : Colors.white
          ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(progressX, paddingTop),
      Offset(progressX, baselineY - 1),
      positionLine,
    );

    final knobOuter =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
    final knobInner =
        Paint()
          ..color = showPreview ? progressColor.withValues(alpha: 0.7) : progressColor
          ..style = PaintingStyle.fill;
    final knobCenter = Offset(progressX, baselineY + 0.5);
    canvas.drawCircle(knobCenter, 8, knobOuter);
    canvas.drawCircle(knobCenter, 5, knobInner);

    // Preview head during scrubbing
    if (showPreview && previewX != null) {
      final previewLine =
          Paint()
            ..color = Colors.amber
            ..strokeWidth = 3.0;
      canvas.drawLine(
        Offset(previewX!, paddingTop),
        Offset(previewX!, baselineY - 1),
        previewLine,
      );

      final previewKnobOuter =
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;
      final previewKnobInner =
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.fill;
      final previewCenter = Offset(previewX!, baselineY + 0.5);
      canvas.drawCircle(previewCenter, 8, previewKnobOuter);
      canvas.drawCircle(previewCenter, 5, previewKnobInner);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return baselineY != oldDelegate.baselineY ||
        paddingTop != oldDelegate.paddingTop ||
        progressX != oldDelegate.progressX ||
        previewX != oldDelegate.previewX ||
        showPreview != oldDelegate.showPreview ||
        progressColor != oldDelegate.progressColor ||
        baselineColor != oldDelegate.baselineColor;
  }
}
