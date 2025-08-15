import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../bloc/audio_comment_bloc.dart';
import '../bloc/audio_comment_event.dart';

/// Complete comment input modal component that handles everything:
/// - Modal container and styling
/// - Animation and positioning
/// - Focus handling and timestamp capture
/// - Input field and submission
/// - Timestamp header display
class CommentInputModal extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrackId trackId;

  const CommentInputModal({
    super.key,
    required this.projectId,
    required this.trackId,
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

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AudioCommentBloc>().add(
        AddAudioCommentEvent(
          widget.projectId,
          widget.trackId,
          text,
          _capturedTimestamp ?? Duration.zero,
        ),
      );
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      audioPlayerBloc.add(const ResumeAudioRequested());
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _handleClose() {
    _controller.clear();
    _focusNode.unfocus();
    // Resume audio when modal is closed
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    audioPlayerBloc.add(const ResumeAudioRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

              // Comment input field (always visible)
              _buildInputField(),
            ],
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

  Widget _buildInputField() {
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
              onSubmitted: (_) => _handleSend(),
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
            onPressed: _handleSend,
          ),
        ),
      ],
    );
  }
}
