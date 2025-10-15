import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_state.dart';

/// Displays a rolling waveform built from the live recording amplitude stream.
class RecordingLiveWaveform extends StatefulWidget {
  final double height;
  final int bufferLength; // Number of bars kept in the buffer
  final Color color;

  const RecordingLiveWaveform({
    super.key,
    this.height = 48,
    this.bufferLength = 60,
    this.color = AppColors.error,
  });

  @override
  State<RecordingLiveWaveform> createState() => _RecordingLiveWaveformState();
}

class _RecordingLiveWaveformState extends State<RecordingLiveWaveform> {
  final List<double> _amplitudes = <double>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: BlocBuilder<RecordingBloc, RecordingState>(
        buildWhen: (prev, curr) => true,
        builder: (context, state) {
          if (state is RecordingInProgress) {
            final amp = (state.session.currentAmplitude ?? 0.0).clamp(0.0, 1.0);
            _pushAmplitude(amp.toDouble());
          } else if (state is RecordingPaused) {
            // Slow decay visual while paused
            if (_amplitudes.isNotEmpty) {
              _pushAmplitude(math.max(0.0, _amplitudes.last * 0.9));
            }
          } else if (state is RecordingInitial || state is RecordingCompleted) {
            // Keep the last buffer on screen
          }

          return CustomPaint(
            painter: _LiveWaveformPainter(
              amplitudes: _amplitudes,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  void _pushAmplitude(double value) {
    _amplitudes.add(value);
    if (_amplitudes.length > widget.bufferLength) {
      _amplitudes.removeAt(0);
    }
  }
}

class _LiveWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  _LiveWaveformPainter({required this.amplitudes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barCount = amplitudes.length;
    final barWidth = math.max(2.0, size.width / (barCount * 1.2));
    final gap = barWidth * 0.2;
    final maxHeight = size.height;
    final baselineY = size.height / 2;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + gap);
      if (x > size.width) break;
      final amp = amplitudes[i].clamp(0.0, 1.0);
      final halfHeight = (amp * maxHeight * 0.9) / 2;
      canvas.drawLine(
        Offset(x, baselineY - halfHeight),
        Offset(x, baselineY + halfHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiveWaveformPainter oldDelegate) {
    return !identical(oldDelegate.amplitudes, amplitudes) ||
        oldDelegate.color != color;
  }
}



