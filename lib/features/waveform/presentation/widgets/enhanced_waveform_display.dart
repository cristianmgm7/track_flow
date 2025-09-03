import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';

class EnhancedWaveformDisplay extends StatefulWidget {
  final AudioTrack track;
  final double height;
  final Duration? trackDuration;

  const EnhancedWaveformDisplay({
    super.key,
    required this.track,
    this.height = 80.0,
    this.trackDuration,
  });

  @override
  State<EnhancedWaveformDisplay> createState() =>
      _EnhancedWaveformDisplayState();
}

class _EnhancedWaveformDisplayState extends State<EnhancedWaveformDisplay> {
  Duration _lastCurrentPosition = Duration.zero;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.track.url != null) {
        final hash = _quickHash(widget.track.url!, widget.trackDuration);
        context.read<WaveformBloc>().add(
          LoadWaveform(
            widget.track.id,
            audioFilePath: widget.track.url,
            audioSourceHash: hash,
          ),
        );
      } else {
        context.read<WaveformBloc>().add(LoadWaveform(widget.track.id));
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedWaveformDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      if (widget.track.url != null) {
        final hash = _quickHash(widget.track.url!, widget.trackDuration);
        context.read<WaveformBloc>().add(
          LoadWaveform(
            widget.track.id,
            audioFilePath: widget.track.url,
            audioSourceHash: hash,
          ),
        );
      } else {
        context.read<WaveformBloc>().add(LoadWaveform(widget.track.id));
      }
    }
  }

  String _quickHash(String pathOrUrl, Duration? duration) {
    final input = '$pathOrUrl|${duration?.inMilliseconds ?? 0}';
    return crypto.sha1.convert(utf8.encode(input)).toString();
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
              return _buildGeneratedWaveform(
                state.waveform!,
                state.currentPosition,
              );
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

  Widget _buildGeneratedWaveform(
    AudioWaveform waveform,
    Duration currentPosition,
  ) {
    _lastCurrentPosition = currentPosition;
    return GestureDetector(
      onTapUp: (details) => _handleTap(details, waveform),
      onPanStart: (details) => _handlePanStart(details, waveform),
      onPanUpdate: (details) => _handlePanUpdate(details, waveform),
      onPanEnd: (details) => _handlePanEnd(),
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          size: Size.fromHeight(widget.height),
          painter: WaveformPainter(
            amplitudes: waveform.data.normalizedAmplitudes,
            currentPosition: currentPosition,
            duration: waveform.data.duration,
            waveColor: Colors.grey[400]!,
            progressColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  bool _isDragging = false;

  void _handleTap(TapUpDetails details, AudioWaveform waveform) {
    if (!_isDragging && _isNearKnob(details.localPosition, waveform)) {
      final position = _calculatePositionFromTap(
        details.localPosition.dx,
        waveform,
      );
      context.read<WaveformBloc>().add(WaveformSeekRequested(position));
    }
  }

  void _handlePanStart(DragStartDetails details, AudioWaveform waveform) {
    _isDragging = _isNearKnob(details.localPosition, waveform);
  }

  void _handlePanUpdate(DragUpdateDetails details, AudioWaveform waveform) {
    if (_isDragging) {
      final position = _calculatePositionFromTap(
        details.localPosition.dx,
        waveform,
      );
      context.read<WaveformBloc>().add(WaveformSeekRequested(position));
    }
  }

  void _handlePanEnd() {
    _isDragging = false;
  }

  Duration _calculatePositionFromTap(double tapX, AudioWaveform waveform) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Duration.zero;

    final width = renderBox.size.width;
    final ratio = (tapX / width).clamp(0.0, 1.0);
    final positionMs = (waveform.data.duration.inMilliseconds * ratio).round();

    return Duration(milliseconds: positionMs);
  }

  bool _isNearKnob(Offset localPosition, AudioWaveform waveform) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final width = renderBox.size.width;
    final height = renderBox.size.height;
    final durationMs = waveform.data.duration.inMilliseconds;
    if (durationMs == 0) return false;
    final ratio = (_lastCurrentPosition.inMilliseconds / durationMs).clamp(
      0.0,
      1.0,
    );
    final knobX = ratio * width;
    final knobY = height - 2.0;
    const double hitRadius = 20.0;
    final dx = localPosition.dx - knobX;
    final dy = localPosition.dy - knobY;
    return dx * dx + dy * dy <= hitRadius * hitRadius;
  }
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
