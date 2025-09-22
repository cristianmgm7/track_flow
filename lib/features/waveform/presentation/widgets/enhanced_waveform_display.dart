import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_painter.dart'
    as static_wave;
import 'package:trackflow/features/waveform/presentation/widgets/waveform_overlay.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_gestures.dart';

class EnhancedWaveformDisplay extends StatefulWidget {
  final AudioTrack track;
  final TrackVersionId? versionId;
  final double height;
  final Duration? trackDuration;

  const EnhancedWaveformDisplay({
    super.key,
    required this.track,
    this.versionId,
    this.height = 80.0,
    this.trackDuration,
  });

  @override
  State<EnhancedWaveformDisplay> createState() =>
      _EnhancedWaveformDisplayState();
}

class _EnhancedWaveformDisplayState extends State<EnhancedWaveformDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.versionId != null) {
        context.read<WaveformBloc>().add(LoadWaveform(widget.versionId!));
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedWaveformDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.versionId != widget.versionId && widget.versionId != null) {
      context.read<WaveformBloc>().add(LoadWaveform(widget.versionId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveformBloc, WaveformState>(
      builder: (context, state) {
        switch (state.status) {
          case WaveformStatus.loading:
            return _buildLoadingState();
          case WaveformStatus.error:
            // Fallback to old system when error occurs
            return _buildFallbackWaveform();
          case WaveformStatus.ready:
            if (state.waveform != null) {
              return _buildGeneratedWaveform(state);
            } else {
              return _buildFallbackWaveform();
            }
          default:
            return _buildInitialState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: widget.height,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Generating waveform...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SizedBox(
      height: widget.height,
      child: const Center(
        child: Text(
          'Initializing...',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildFallbackWaveform() {
    // Minimal empty state when waveform isn't ready
    return SizedBox(height: widget.height);
  }

  Widget _buildGeneratedWaveform(WaveformState state) {
    final AudioWaveform waveform = state.waveform!;
    final duration = waveform.data.duration;

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static waveform bars
          CustomPaint(
            size: Size.fromHeight(widget.height),
            painter: static_wave.WaveformPainter(
              amplitudes: waveform.data.normalizedAmplitudes,
              waveColor: Colors.grey[400]!,
            ),
          ),
          // Overlay with playhead and preview head
          WaveformOverlay(
            duration: duration,
            playbackPosition: state.currentPosition,
            previewPosition: state.previewPosition,
            isScrubbing: state.isScrubbing,
            progressColor: AppColors.primary,
            baselineColor: Colors.white,
          ),
          // Gesture layer
          WaveformGestures(
            positionFromX: (x, width) {
              final ratio = (x / width).clamp(0.0, 1.0);
              final ms = (duration.inMilliseconds * ratio).round();
              return Duration(milliseconds: ms);
            },
            onScrubStarted: () {
              context.read<WaveformBloc>().add(const WaveformScrubStarted());
            },
            onScrubUpdated: (pos) {
              context.read<WaveformBloc>().add(WaveformScrubUpdated(pos));
            },
            onScrubCancelled: () {
              context.read<WaveformBloc>().add(const WaveformScrubCancelled());
            },
            onScrubCommitted: (pos) {
              context.read<WaveformBloc>().add(WaveformScrubCommitted(pos));
            },
          ),
        ],
      ),
    );
  }

  // Note: No internal drag state; gestures are handled in WaveformGestures
}

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration currentPosition;
  final Duration duration;
  final Color waveColor;
  final Color progressColor;

  WaveformPainter({
    required this.amplitudes,
    required this.currentPosition,
    required this.duration,
    required this.waveColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty || duration.inMilliseconds == 0) return;

    final barWidth = size.width / amplitudes.length;
    // Draw from bottom baseline upwards (positive-only rendering)
    const double paddingTop = 2.0;
    const double paddingBottom = 2.0;
    final double baselineY = size.height - paddingBottom;
    final double maxHeight = size.height - paddingTop - paddingBottom;
    final progressX =
        duration.inMilliseconds > 0
            ? (currentPosition.inMilliseconds / duration.inMilliseconds) *
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
            ..color = x <= progressX ? progressColor : waveColor
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      // Draw amplitude bar from baseline upwards only
      canvas.drawLine(
        Offset(x, baselineY),
        Offset(x, baselineY - barHeight),
        paint,
      );
    }

    // Draw progress baseline and knob (circle) at bottom
    final basePaint =
        Paint()
          ..color = waveColor.withOpacity(0.35)
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
          ..color = progressColor
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

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
        currentPosition != oldDelegate.currentPosition ||
        duration != oldDelegate.duration ||
        waveColor != oldDelegate.waveColor ||
        progressColor != oldDelegate.progressColor;
  }
}
