import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/components/waveform.dart';

class EnhancedWaveformDisplay extends StatefulWidget {
  final AudioTrackId trackId;
  final double height;

  const EnhancedWaveformDisplay({
    super.key,
    required this.trackId,
    this.height = 80.0,
  });

  @override
  State<EnhancedWaveformDisplay> createState() => _EnhancedWaveformDisplayState();
}

class _EnhancedWaveformDisplayState extends State<EnhancedWaveformDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaveformBloc>().add(LoadWaveform(widget.trackId));
    });
  }

  @override
  void didUpdateWidget(EnhancedWaveformDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      context.read<WaveformBloc>().add(LoadWaveform(widget.trackId));
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
              return _buildGeneratedWaveform(state.waveform!, state.currentPosition);
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
    // Use legacy AudioCommentWaveformDisplay as fallback
    return AudioCommentWaveformDisplay(trackId: widget.trackId);
  }

  Widget _buildGeneratedWaveform(AudioWaveform waveform, Duration currentPosition) {
    return GestureDetector(
      onTapUp: (details) => _handleTap(details, waveform),
      onPanStart: (details) => _handlePanStart(),
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
    if (!_isDragging) {
      final position = _calculatePositionFromTap(details.localPosition.dx, waveform);
      context.read<WaveformBloc>().add(WaveformSeekRequested(position));
    }
  }

  void _handlePanStart() {
    _isDragging = true;
  }

  void _handlePanUpdate(DragUpdateDetails details, AudioWaveform waveform) {
    if (_isDragging) {
      final position = _calculatePositionFromTap(details.localPosition.dx, waveform);
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
    final centerY = size.height / 2;
    final progressX = duration.inMilliseconds > 0
        ? (currentPosition.inMilliseconds / duration.inMilliseconds) * size.width
        : 0.0;

    // Draw waveform bars
    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final barHeight = (amplitudes[i] * centerY * 0.8).clamp(2.0, centerY);

      // Choose paint based on playback progress
      final paint = Paint()
        ..color = x <= progressX ? progressColor : waveColor
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Draw amplitude bar
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }

    // Draw progress line
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      progressPaint,
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