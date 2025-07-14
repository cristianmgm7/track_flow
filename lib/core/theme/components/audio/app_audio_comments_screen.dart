import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app_dimensions.dart';
import '../../app_text_style.dart';
import '../../app_borders.dart';
import '../../app_shadows.dart';
import '../../app_animations.dart';
import '../navigation/app_scaffold.dart';
import '../navigation/app_bar.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import '../../../../features/audio_comment/presentation/bloc/audio_comment_event.dart';
import '../../../../features/audio_comment/presentation/components/header/audio_comment_header.dart';
import '../../../../features/audio_comment/presentation/components/header/waveform.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_event.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_state.dart';
import '../../../../features/audio_track/domain/entities/audio_track.dart';
import '../../../../features/user_profile/domain/entities/user_profile.dart';
import '../../../../features/audio_comment/presentation/components/audio_comment_list_comments.dart';
import '../../../../features/audio_comment/presentation/components/audio_comment_input_comment_component.dart';

/// Arguments for the audio comments screen
class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;

  AudioCommentsScreenArgs({
    required this.projectId,
    required this.track,
    required this.collaborators,
  });
}

/// Audio comments screen following TrackFlow design system
/// Replaces hardcoded values with design system constants
class AppAudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;

  const AppAudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });

  @override
  State<AppAudioCommentsScreen> createState() => _AppAudioCommentsScreenState();
}

class _AppAudioCommentsScreenState extends State<AppAudioCommentsScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  Duration? _capturedTimestamp;
  bool _isInputFocused = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );

    _focusNode.addListener(_handleInputFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleInputFocus);
    _focusNode.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(title: 'Comments'),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Waveform header
                _buildWaveformHeader(),

                // Comments list
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.screenMarginSmall,
                    ),
                    child: AudioCommentCommentsList(
                      collaborators: widget.collaborators,
                    ),
                  ),
                ),

                // Space for input when visible
                SizedBox(height: Dimensions.space80),
              ],
            ),

            // Floating comment input
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: -_slideAnimation.value * Dimensions.space80,
                  child: _buildCommentInput(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformHeader() {
    return Container(
      margin: EdgeInsets.all(Dimensions.screenMarginSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppBorders.large,
        boxShadow: AppShadows.medium,
        border: AppBorders.subtleBorder(context),
      ),
      child: ClipRRect(
        borderRadius: AppBorders.large,
        child: AudioCommentHeader(
          waveform: AudioCommentWaveformDisplay(trackId: widget.track.id),
          trackId: widget.track.id,
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
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
          padding: EdgeInsets.all(Dimensions.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: Dimensions.space48,
                  height: Dimensions.space4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Dimensions.radiusRound),
                  ),
                ),
              ),

              SizedBox(height: Dimensions.space12),

              // Timestamp header (if focused)
              if (_isInputFocused && _capturedTimestamp != null)
                _buildTimestampHeader(),

              // Comment input
              AudioCommentInputComment(
                focusNode: _focusNode,
                header: null, // We handle the header above
                onSend: (text) {
                  context.read<AudioCommentBloc>().add(
                    AddAudioCommentEvent(
                      widget.projectId,
                      widget.track.id,
                      text,
                      _capturedTimestamp ?? Duration.zero,
                    ),
                  );
                  _focusNode.unfocus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestampHeader() {
    if (_capturedTimestamp == null) return const SizedBox.shrink();

    final timestamp = _capturedTimestamp!;
    final minutes = timestamp.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = (timestamp.inSeconds % 60).toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: EdgeInsets.only(bottom: Dimensions.space12),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: Dimensions.iconSmall,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: Dimensions.space8),
          Text(
            'Comment at $minutes:$seconds',
            style: AppTextStyle.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility wrapper for existing AudioCommentsScreen
class AudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;

  const AudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });

  @override
  State<AudioCommentsScreen> createState() => _AudioCommentsScreenState();
}

class _AudioCommentsScreenState extends State<AudioCommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppAudioCommentsScreen(
      projectId: widget.projectId,
      track: widget.track,
      collaborators: widget.collaborators,
    );
  }
}
