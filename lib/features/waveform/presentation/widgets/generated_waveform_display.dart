import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_painter.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_progress_painter.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_overlay.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_gestures.dart';

class GeneratedWaveformDisplay extends StatelessWidget {
  final AudioWaveform waveform;
  final WaveformState state;
  final double height;

  const GeneratedWaveformDisplay({
    super.key,
    required this.waveform,
    required this.state,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final duration = waveform.data.duration;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static waveform bars
          CustomPaint(
            size: Size.fromHeight(height),
            painter: WaveformPainter(
              amplitudes: waveform.data.normalizedAmplitudes,
              duration: duration,
              waveColor: AppColors.onPrimary,
              progressColor: AppColors.onPrimary,
            ),
          ),
          // Progress bars (left of playhead or preview while scrubbing)
          CustomPaint(
            size: Size.fromHeight(height),
            painter: WaveformProgressPainter(
              amplitudes: waveform.data.normalizedAmplitudes,
              duration: duration,
              progress:
                  state.isScrubbing && state.previewPosition != null
                      ? state.previewPosition!
                      : state.currentPosition,
              progressColor: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          // Overlay with playhead and preview head
          WaveformOverlay(
            duration: duration,
            playbackPosition: state.currentPosition,
            previewPosition: state.previewPosition,
            isScrubbing: state.isScrubbing,
            progressColor: AppColors.primary,
            baselineColor: AppColors.onPrimary,
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
}
