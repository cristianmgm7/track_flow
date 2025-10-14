import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/voice_memos/domain/entities/voice_memo.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_painter.dart'
    as static_wave;
import 'package:trackflow/features/waveform/presentation/widgets/waveform_progress_painter.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_overlay.dart';

class VoiceMemoWaveformDisplay extends StatelessWidget {
  final VoiceMemo memo;
  final double height;
  final Function(Duration)? onSeek;

  const VoiceMemoWaveformDisplay({
    super.key,
    required this.memo,
    this.height = 80,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    // If no waveform data, show empty placeholder
    if (memo.waveformData == null) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No waveform data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final waveformData = memo.waveformData!;
    final amplitudes = waveformData.normalizedAmplitudes;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        // Determine if this memo is currently playing
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final currentPosition = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        return GestureDetector(
          onTapDown: (details) => _handleTap(context, details),
          onPanUpdate: (details) => _handlePan(context, details),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static waveform bars (gray)
                CustomPaint(
                  size: Size.fromHeight(height),
                  painter: static_wave.WaveformPainter(
                    amplitudes: amplitudes,
                    duration: memo.duration,
                    waveColor: Colors.grey[400]!,
                    progressColor: Colors.grey[400]!,
                  ),
                ),
                // Progress bars (colored up to current position)
                CustomPaint(
                  size: Size.fromHeight(height),
                  painter: WaveformProgressPainter(
                    amplitudes: amplitudes,
                    duration: memo.duration,
                    progress: currentPosition,
                    progressColor: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                // Playhead overlay
                WaveformOverlay(
                  duration: memo.duration,
                  playbackPosition: currentPosition,
                  previewPosition: null,
                  isScrubbing: false,
                  progressColor: AppColors.primary,
                  baselineColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    final position = _calculatePositionFromX(
      details.localPosition.dx,
      context.size!.width,
    );
    onSeek?.call(position);
  }

  void _handlePan(BuildContext context, DragUpdateDetails details) {
    final position = _calculatePositionFromX(
      details.localPosition.dx,
      context.size!.width,
    );
    onSeek?.call(position);
  }

  Duration _calculatePositionFromX(double x, double width) {
    final ratio = (x / width).clamp(0.0, 1.0);
    final ms = (memo.duration.inMilliseconds * ratio).round();
    return Duration(milliseconds: ms);
  }
}
