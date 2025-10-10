import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import '../../../audio_recording/presentation/widgets/recording_waveform.dart';
import '../../../audio_recording/presentation/widgets/recording_timer.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../domain/entities/audio_comment.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_event.dart';

/// Comment input modes
enum CommentInputMode { text, audio }

/// Complete comment input modal component that handles everything:
/// - Modal container and styling
/// - Animation and positioning
/// - Focus handling and timestamp capture
/// - Text and audio input modes
/// - Input field and submission
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

  // Audio recording state
  CommentInputMode _inputMode = CommentInputMode.text;
  AudioRecording? _completedRecording;

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

  void _handleStartRecording() {
    // Capture timestamp and pause playback
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

    // Start recording
    context.read<RecordingBloc>().add(const StartRecordingRequested());
  }

  void _handleStopRecording() {
    context.read<RecordingBloc>().add(const StopRecordingRequested());
  }

  void _handleCancelRecording() {
    context.read<RecordingBloc>().add(const CancelRecordingRequested());
    setState(() {
      _completedRecording = null;
      _isInputFocused = false;
      _capturedTimestamp = null;
    });
    _animationController.reverse();

    // Resume playback
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    audioPlayerBloc.add(const ResumeAudioRequested());
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

  void _handleSendAudioComment() {
    if (_completedRecording != null) {
      final text = _controller.text.trim();
      final commentType = text.isEmpty ? CommentType.audio : CommentType.hybrid;

      context.read<AudioCommentBloc>().add(
        AddAudioCommentEvent(
          widget.projectId,
          widget.versionId,
          text,
          _capturedTimestamp ?? Duration.zero,
          localAudioPath: _completedRecording!.localPath,
          audioDuration: _completedRecording!.duration,
          commentType: commentType,
        ),
      );

      // Clean up and resume playback
      setState(() {
        _completedRecording = null;
        _isInputFocused = false;
        _capturedTimestamp = null;
      });
      _controller.clear();
      _animationController.reverse();

      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      audioPlayerBloc.add(const ResumeAudioRequested());

      // Reset recording state
      context.read<RecordingBloc>().add(const CancelRecordingRequested());
    }
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
      _completedRecording = null;
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
    return BlocProvider(
      create: (_) => di.sl<RecordingBloc>(),
      child: BlocListener<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingCompleted) {
            setState(() {
              _completedRecording = state.recording;
            });
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
                    _buildHeader(),
                    Divider(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      height: Dimensions.space8,
                    ),
                  ],

                  // Mode toggle
                  _buildModeToggle(),

                  SizedBox(height: Dimensions.space12),

                  // Input area based on mode
                  if (_inputMode == CommentInputMode.text)
                    _buildTextInputField()
                  else
                    _buildRecordingInterface(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_capturedTimestamp == null) return const SizedBox.shrink();

    final timestamp = _capturedTimestamp!;
    final minutes = timestamp.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = (timestamp.inSeconds % 60).toString().padLeft(2, '0');

    return SizedBox(
      height: Dimensions.space40,
      child: Row(
        children: [
          // X button to close
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: Dimensions.space40,
              minHeight: Dimensions.space40,
            ),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: Dimensions.iconMedium,
            ),
            onPressed: _handleClose,
          ),

          // Centered timestamp
          Expanded(
            child: Center(
              child: Text(
                'Comment at $minutes:$seconds',
                style: AppTextStyle.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Spacer for symmetry
          SizedBox(width: Dimensions.space40),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return SegmentedButton<CommentInputMode>(
      segments: const [
        ButtonSegment<CommentInputMode>(
          value: CommentInputMode.text,
          label: Text('Text'),
          icon: Icon(Icons.text_fields),
        ),
        ButtonSegment<CommentInputMode>(
          value: CommentInputMode.audio,
          label: Text('Audio'),
          icon: Icon(Icons.mic),
        ),
      ],
      selected: {_inputMode},
      onSelectionChanged: (Set<CommentInputMode> newSelection) {
        setState(() {
          _inputMode = newSelection.first;
          // Reset states when switching modes
          if (_inputMode == CommentInputMode.text) {
            // Cancel any recording in progress
            final recordingBloc = context.read<RecordingBloc>();
            if (recordingBloc.state is! RecordingInitial) {
              recordingBloc.add(const CancelRecordingRequested());
            }
            _completedRecording = null;
          } else {
            _focusNode.unfocus();
          }
        });
      },
    );
  }

  Widget _buildTextInputField() {
    return Row(
      children: [
        // Text input field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                width: AppBorders.widthThin,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTextStyle.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment',
                hintStyle: AppTextStyle.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.space16,
                  vertical: Dimensions.space12,
                ),
              ),
              onSubmitted: (_) => _handleSendTextComment(),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ),

        SizedBox(width: Dimensions.space8),

        // Send button
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: Dimensions.iconSmall,
            ),
            onPressed: _handleSendTextComment,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInterface() {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        if (state is RecordingInitial) {
          return _buildRecordingInitial();
        } else if (state is RecordingInProgress) {
          return _buildRecordingInProgress(state);
        } else if (state is RecordingPaused) {
          return _buildRecordingPaused(state);
        } else if (state is RecordingCompleted && _completedRecording != null) {
          return _buildRecordingCompleted();
        } else if (state is RecordingError) {
          return _buildRecordingError(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecordingInitial() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: Dimensions.space24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: Dimensions.space48,
              icon: Icon(
                Icons.mic_none,
                color: AppColors.error,
              ),
              onPressed: _handleStartRecording,
            ),
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'Tap to start recording',
            style: AppTextStyle.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Dimensions.space24),
        ],
      ),
    );
  }

  Widget _buildRecordingInProgress(RecordingInProgress state) {
    return Column(
      children: [
        SizedBox(height: Dimensions.space16),
        RecordingTimer(
          elapsed: state.session.elapsed,
          style: AppTextStyle.headlineSmall.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: Dimensions.space16),
        RecordingWaveform(
          amplitude: state.session.currentAmplitude ?? 0.0,
          color: AppColors.error,
          height: 60,
        ),
        SizedBox(height: Dimensions.space16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel button
            OutlinedButton.icon(
              onPressed: _handleCancelRecording,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
            SizedBox(width: Dimensions.space16),
            // Stop button
            FilledButton.icon(
              onPressed: _handleStopRecording,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.space16),
      ],
    );
  }

  Widget _buildRecordingPaused(RecordingPaused state) {
    return Column(
      children: [
        SizedBox(height: Dimensions.space16),
        RecordingTimer(
          elapsed: state.session.elapsed,
          style: AppTextStyle.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: Dimensions.space16),
        Text(
          'Recording paused',
          style: AppTextStyle.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.space16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel button
            OutlinedButton.icon(
              onPressed: _handleCancelRecording,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
            SizedBox(width: Dimensions.space16),
            // Resume button
            FilledButton.icon(
              onPressed: () {
                context.read<RecordingBloc>().add(const ResumeRecordingRequested());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
            ),
            SizedBox(width: Dimensions.space16),
            // Stop button
            FilledButton.icon(
              onPressed: _handleStopRecording,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.space16),
      ],
    );
  }

  Widget _buildRecordingCompleted() {
    if (_completedRecording == null) return const SizedBox.shrink();

    final minutes = _completedRecording!.duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = (_completedRecording!.duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return Column(
      children: [
        SizedBox(height: Dimensions.space16),
        Container(
          padding: EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: AppBorders.widthThin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: Dimensions.iconMedium,
              ),
              SizedBox(width: Dimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recording complete',
                      style: AppTextStyle.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$minutes:$seconds',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),

        // Optional text note
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: AppBorders.widthThin,
            ),
          ),
          child: TextField(
            controller: _controller,
            style: AppTextStyle.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              hintStyle: AppTextStyle.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.space16,
                vertical: Dimensions.space12,
              ),
            ),
            maxLines: null,
            textInputAction: TextInputAction.newline,
          ),
        ),

        SizedBox(height: Dimensions.space12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleCancelRecording,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Discard'),
              ),
            ),
            SizedBox(width: Dimensions.space12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _handleSendAudioComment,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send'),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.space16),
      ],
    );
  }

  Widget _buildRecordingError(RecordingError state) {
    return Column(
      children: [
        SizedBox(height: Dimensions.space16),
        Container(
          padding: EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: AppBorders.widthThin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: Dimensions.iconMedium,
              ),
              SizedBox(width: Dimensions.space12),
              Expanded(
                child: Text(
                  state.message,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),
        OutlinedButton(
          onPressed: () {
            context.read<RecordingBloc>().add(const CancelRecordingRequested());
          },
          child: const Text('Dismiss'),
        ),
        SizedBox(height: Dimensions.space16),
      ],
    );
  }
}
