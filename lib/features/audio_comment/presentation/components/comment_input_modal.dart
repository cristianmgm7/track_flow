import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../domain/entities/audio_comment.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_event.dart';
import 'input_bar/audio_comment_input_bar.dart';
import 'comment_input_header.dart';

/// Complete comment input modal component that handles everything:
/// - Modal container and styling
/// - Animation and positioning
/// - Focus handling and timestamp capture
/// - WhatsApp-style input bar (text + hold-to-record)
/// - Input field and submission with auto-send on release
/// - Timestamp header display
class CommentInputModal extends StatefulWidget {
  final ProjectId projectId;
  final TrackVersionId versionId;

  const CommentInputModal({
    super.key,
    required this.projectId,
    required this.versionId,
  });

  @override
  State<CommentInputModal> createState() => _CommentInputModalState();
}

class _CommentInputModalState extends State<CommentInputModal>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Duration? _capturedTimestamp;
  bool _isInputFocused = false;
  late AnimationController _animationController;

  // Audio recording flow control
  bool _autoSendOnComplete = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _focusNode.addListener(_handleInputFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleInputFocus);
    _focusNode.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleInputFocus() {
    if (_focusNode.hasFocus) {
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      final state = audioPlayerBloc.state;
      if (state is AudioPlayerSessionState) {
        setState(() {
          _capturedTimestamp = state.session.position;
          _isInputFocused = true;
        });
        audioPlayerBloc.add(const PauseAudioRequested());
        _animationController.forward();
      }
    } else {
      setState(() {
        _isInputFocused = false;
        _capturedTimestamp = null;
      });
      _animationController.reverse();
    }
  }

  void _onCaptureTimestamp(Duration position) {
    setState(() {
      _capturedTimestamp = position;
      _isInputFocused = true;
    });
    _animationController.forward();
  }

  void _handleSendTextComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AudioCommentBloc>().add(
        AddAudioCommentEvent(
          widget.projectId,
          widget.versionId,
          text,
          _capturedTimestamp ?? Duration.zero,
          commentType: CommentType.text,
        ),
      );
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      audioPlayerBloc.add(const ResumeAudioRequested());
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _onSendAudioRequested() {
    // Input bar already requested StopRecording; we mark to auto-send on completion.
    _autoSendOnComplete = true;
  }

  void _onCancelAudioRequested() {
    setState(() {
      _autoSendOnComplete = false;
      _isInputFocused = false;
      _capturedTimestamp = null;
    });
    _animationController.reverse();
  }

  void _sendAudioComment(AudioRecording recording) {
    final text = _controller.text.trim();
    final commentType = text.isEmpty ? CommentType.audio : CommentType.hybrid;

    context.read<AudioCommentBloc>().add(
      AddAudioCommentEvent(
        widget.projectId,
        widget.versionId,
        text,
        _capturedTimestamp ?? Duration.zero,
        localAudioPath: recording.localPath,
        audioDuration: recording.duration,
        commentType: commentType,
      ),
    );

    setState(() {
      _autoSendOnComplete = false;
      _isInputFocused = false;
      _capturedTimestamp = null;
    });
    _controller.clear();
    _animationController.reverse();
  }

  void _handleClose() {
    _controller.clear();
    _focusNode.unfocus();

    // Cancel any active recording
    final recordingBloc = context.read<RecordingBloc>();
    if (recordingBloc.state is! RecordingInitial) {
      recordingBloc.add(const CancelRecordingRequested());
    }

    setState(() {
      _isInputFocused = false;
      _capturedTimestamp = null;
    });
    _animationController.reverse();

    // Resume audio when modal is closed
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    audioPlayerBloc.add(const ResumeAudioRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is RecordingCompleted) {
          if (_autoSendOnComplete) {
            _sendAudioComment(state.recording);
          }
        } else if (state is RecordingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusLarge),
              topRight: Radius.circular(Dimensions.radiusLarge),
            ),
            boxShadow: AppShadows.medium,
            border: Border(top: AppBorders.subtleSide(context)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimensions.space16,
                right: Dimensions.space16,
                top: Dimensions.space16,
                bottom: Dimensions.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with X button and timestamp (if focused)
                  if (_isInputFocused && _capturedTimestamp != null) ...[
                    CommentInputHeader(
                      timestamp: _capturedTimestamp,
                      onClose: _handleClose,
                    ),
                    Divider(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      height: Dimensions.space8,
                    ),
                  ],

                  AudioCommentInputBar(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSendText: _handleSendTextComment,
                    onSendAudio: _onSendAudioRequested,
                    onCancelAudio: _onCancelAudioRequested,
                    onCaptureTimestamp: _onCaptureTimestamp,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }


  // Recording error UI handled by SnackBar listener
}
