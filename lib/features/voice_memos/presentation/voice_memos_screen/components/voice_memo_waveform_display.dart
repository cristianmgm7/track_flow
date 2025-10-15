import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/voice_memos/domain/entities/voice_memo.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_painter.dart' as static_wave;
import 'package:trackflow/features/waveform/presentation/widgets/waveform_progress_painter.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_overlay.dart';

class VoiceMemoWaveformDisplay extends StatefulWidget {
  final VoiceMemo memo;
  final double height;
  final bool fileExists;

  const VoiceMemoWaveformDisplay({
    super.key,
    required this.memo,
    this.height = 80,
    this.fileExists = true,
  });

  @override
  State<VoiceMemoWaveformDisplay> createState() => _VoiceMemoWaveformDisplayState();
}

class _VoiceMemoWaveformDisplayState extends State<VoiceMemoWaveformDisplay> {
  bool _isScrubbing = false;
  Duration? _previewPosition;
  bool _wasPlayingBeforeScrub = false;

  @override
  Widget build(BuildContext context) {
    // If file is missing, show error indicator
    if (!widget.fileExists) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Audio file not found',
                style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If no waveform data, show empty placeholder
    if (widget.memo.waveformData == null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No waveform data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final waveformData = widget.memo.waveformData!;
    final amplitudes = waveformData.normalizedAmplitudes;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        // Determine if this memo is currently playing
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == widget.memo.id.value;

        final currentPosition = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        final progressPosition =
            _isScrubbing && _previewPosition != null
                ? _previewPosition!
                : currentPosition;

        return GestureDetector(
          onTapDown: (details) => _handleTap(context, details),
          onPanStart: (_) => _handlePanStart(context, isCurrentMemo, audioState),
          onPanUpdate: (details) => _handlePanUpdate(context, details),
          onPanEnd: (_) => _handlePanEnd(context),
          onPanCancel: () => _handlePanCancel(context),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static waveform bars (gray)
                CustomPaint(
                  size: Size.fromHeight(widget.height),
                  painter: static_wave.WaveformPainter(
                    amplitudes: amplitudes,
                    duration: widget.memo.duration,
                    waveColor: AppColors.onPrimary,
                    progressColor: Colors.grey[400]!,
                  ),
                ),
                // Progress bars (colored up to current position)
                CustomPaint(
                  size: Size.fromHeight(widget.height),
                  painter: WaveformProgressPainter(
                    amplitudes: amplitudes,
                    duration: widget.memo.duration,
                    progress: progressPosition,
                    progressColor: AppColors.warning,
                  ),
                ),
                // Playhead overlay
                WaveformOverlay(
                  duration: widget.memo.duration,
                  playbackPosition: currentPosition,
                  previewPosition: _previewPosition,
                  isScrubbing: _isScrubbing,
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
    context.read<AudioPlayerBloc>().add(SeekToPositionRequested(position));
  }

  void _handlePanStart(BuildContext context, bool isCurrentMemo, AudioPlayerState audioState) {
    final isPlaying = isCurrentMemo && audioState is AudioPlayerPlaying;
    _wasPlayingBeforeScrub = isPlaying;
    if (isPlaying) {
      context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
    }
    setState(() {
      _isScrubbing = true;
      _previewPosition = null;
    });
  }

  void _handlePanUpdate(BuildContext context, DragUpdateDetails details) {
    final position = _calculatePositionFromX(
      details.localPosition.dx,
      context.size!.width,
    );
    setState(() {
      _previewPosition = position;
    });
  }

  void _handlePanEnd(BuildContext context) {
    final commit = _previewPosition;
    setState(() {
      _isScrubbing = false;
    });
    if (commit != null) {
      context.read<AudioPlayerBloc>().add(SeekToPositionRequested(commit));
    }
    if (_wasPlayingBeforeScrub) {
      context.read<AudioPlayerBloc>().add(const ResumeAudioRequested());
    }
    _wasPlayingBeforeScrub = false;
    _previewPosition = null;
  }

  void _handlePanCancel(BuildContext context) {
    setState(() {
      _isScrubbing = false;
      _previewPosition = null;
    });
    if (_wasPlayingBeforeScrub) {
      context.read<AudioPlayerBloc>().add(const ResumeAudioRequested());
    }
    _wasPlayingBeforeScrub = false;
  }

  Duration _calculatePositionFromX(double x, double width) {
    final ratio = (x / width).clamp(0.0, 1.0);
    final ms = (widget.memo.duration.inMilliseconds * ratio).round();
    return Duration(milliseconds: ms);
  }
}
