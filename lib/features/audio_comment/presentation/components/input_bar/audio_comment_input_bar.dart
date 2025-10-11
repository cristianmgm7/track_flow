import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_event.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_state.dart';
import 'package:trackflow/features/audio_recording/presentation/widgets/recording_timer.dart';
import 'package:trackflow/features/audio_comment/presentation/components/recording/recording_live_waveform.dart';

/// WhatsApp-style input bar:
/// - Text input with dynamic mic/send action
/// - Hold-to-record gesture (press to start, release to send, slide left to cancel)
/// - Swipe-up to lock hands-free
class AudioCommentInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() onSendText;
  final void Function() onSendAudio;
  final void Function() onCancelAudio;
  final void Function(Duration timestamp) onCaptureTimestamp;

  const AudioCommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendText,
    required this.onSendAudio,
    required this.onCancelAudio,
    required this.onCaptureTimestamp,
  });

  @override
  State<AudioCommentInputBar> createState() => _AudioCommentInputBarState();
}

class _AudioCommentInputBarState extends State<AudioCommentInputBar> {
  bool _isLocked = false;
  bool _isDraggingToCancel = false;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.controller.text.trim().isNotEmpty;

    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, recordingState) {
        final bool isRecording = recordingState is RecordingInProgress ||
            recordingState is RecordingPaused;

        if (isRecording || _isLocked) {
          return _buildLockedRecordingBar(context, recordingState);
        }

        return Row(
          children: [
            // Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: AppBorders.widthThin,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    hintStyle: AppTextStyle.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimensions.space16,
                      vertical: Dimensions.space12,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            SizedBox(width: Dimensions.space8),
            // Action: send or mic
            _buildActionButton(context, hasText),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, bool hasText) {
    final theme = Theme.of(context);
    if (hasText) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.send_rounded,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: widget.onSendText,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) {
        _dragStart = details.globalPosition;
        _beginRecording(context);
      },
      onLongPressMoveUpdate: (details) {
        if (_dragStart == null) return;
        final delta = details.globalPosition - _dragStart!;
        // Slide left to cancel
        if (delta.dx < -60) {
          setState(() => _isDraggingToCancel = true);
        } else {
          setState(() => _isDraggingToCancel = false);
        }
        // Swipe up to lock
        if (delta.dy < -80) {
          setState(() => _isLocked = true);
        }
      },
      onLongPressEnd: (details) {
        if (_isLocked) return; // Still recording locked
        if (_isDraggingToCancel) {
          _cancelRecording(context);
        } else {
          _stopAndSendRecording(context);
        }
        _resetGestures();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(Dimensions.space8),
        child: Icon(
          Icons.mic,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildLockedRecordingBar(BuildContext context, RecordingState state) {
    final theme = Theme.of(context);
    final elapsed = (state is RecordingInProgress || state is RecordingPaused)
        ? (state as dynamic).session.elapsed as Duration
        : Duration.zero;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.mic, color: theme.colorScheme.primary),
          SizedBox(width: Dimensions.space8),
          RecordingTimer(elapsed: elapsed),
          SizedBox(width: Dimensions.space12),
          Expanded(child: RecordingLiveWaveform(height: 36)),
          SizedBox(width: Dimensions.space12),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _cancelRecording(context);
              _resetGestures();
            },
          ),
          // Send
          IconButton(
            icon: const Icon(Icons.send_rounded),
            onPressed: () {
              _stopAndSendRecording(context);
              _resetGestures();
            },
          ),
        ],
      ),
    );
  }

  void _beginRecording(BuildContext context) {
    // Capture timestamp and pause playback
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final state = audioPlayerBloc.state;
    if (state is AudioPlayerSessionState) {
      widget.onCaptureTimestamp(state.session.position);
      audioPlayerBloc.add(const PauseAudioRequested());
    }
    context.read<RecordingBloc>().add(const StartRecordingRequested());
  }

  void _stopAndSendRecording(BuildContext context) {
    context.read<RecordingBloc>().add(const StopRecordingRequested());
    widget.onSendAudio();
    _resumePlayback(context);
  }

  void _cancelRecording(BuildContext context) {
    context.read<RecordingBloc>().add(const CancelRecordingRequested());
    widget.onCancelAudio();
    _resumePlayback(context);
  }

  void _resumePlayback(BuildContext context) {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    audioPlayerBloc.add(const ResumeAudioRequested());
  }

  void _resetGestures() {
    setState(() {
      _isLocked = false;
      _isDraggingToCancel = false;
      _dragStart = null;
    });
  }
}


