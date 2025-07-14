import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app_dimensions.dart';
import '../../app_colors.dart';
import '../../app_shadows.dart';
import '../../app_borders.dart';
import '../../app_animations.dart';
import '../cards/base_card.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import '../../../../features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';
import '../../../../features/audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../../features/audio_context/presentation/bloc/audio_context_event.dart';
import '../../../../features/audio_context/presentation/bloc/audio_context_state.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_state.dart';
import '../../../../features/audio_track/domain/entities/audio_track.dart';
import '../../../../features/audio_track/presentation/component/widgets/track_actions_section.dart';
import '../../../../features/audio_track/presentation/component/widgets/track_duration_formatter.dart';
import '../../../../features/audio_track/presentation/component/widgets/track_info_section.dart';
import '../../../../features/audio_track/presentation/component/widgets/track_interaction_handler.dart';
import '../../../../features/user_profile/domain/entities/user_profile.dart' as user_profile;

/// Audio track component following TrackFlow design system
/// Replaces hardcoded values with design system constants
class AppTrackComponent extends StatefulWidget {
  final AudioTrack track;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const AppTrackComponent({
    super.key,
    required this.track,
    this.onPlay,
    this.onComment,
    required this.projectId,
  });

  @override
  State<AppTrackComponent> createState() => _AppTrackComponentState();
}

class _AppTrackComponentState extends State<AppTrackComponent> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TrackCacheBloc>()),
        BlocProvider(
          create: (context) => sl<AudioContextBloc>()
            ..add(LoadTrackContextRequested(widget.track.id)),
        ),
      ],
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, playerState) {
          final isCurrent = _isCurrentTrack(playerState);

          return AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: BaseCard(
                  backgroundColor: isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  elevation: isCurrent ? AppShadows.elevation4 : AppShadows.elevation2,
                  borderRadius: AppBorders.medium,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.space12,
                    horizontal: Dimensions.space16,
                  ),
                  child: BlocBuilder<AudioContextBloc, AudioContextState>(
                    builder: (context, contextState) {
                      final uploader = _getUploaderFromState(contextState);
                      final interactionHandler = TrackInteractionHandler(
                        config: TrackInteractionConfig(
                          track: widget.track,
                          uploader: uploader,
                          projectId: widget.projectId,
                          onPlay: widget.onPlay,
                          onComment: widget.onComment,
                        ),
                      );
                      final feedbackHandler = const TrackUIFeedbackHandler();

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) => _animationController.forward(),
                              onTapUp: (_) => _animationController.reverse(),
                              onTapCancel: () => _animationController.reverse(),
                              onTap: () {
                                if (interactionHandler.isPlayButtonEnabled) {
                                  interactionHandler.handlePlayTrack(context);
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Cover art placeholder
                                  _buildCoverArt(context, isCurrent),
                                  
                                  SizedBox(width: Dimensions.space12),
                                  
                                  // Track info section
                                  Expanded(
                                    child: TrackInfoSection(
                                      trackName: interactionHandler.trackName,
                                      uploaderName: _getUploaderNameFromState(
                                        contextState,
                                      ),
                                      statusBadge: Container(),
                                    ),
                                  ),
                                  
                                  SizedBox(width: Dimensions.space8),
                                  
                                  // Duration
                                  _buildDuration(context, interactionHandler),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(width: Dimensions.space12),
                          
                          // Actions section (cache + menu)
                          _buildActionsSection(context, interactionHandler, feedbackHandler),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCoverArt(BuildContext context, bool isCurrent) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      width: Dimensions.space48,
      height: Dimensions.space48,
      decoration: BoxDecoration(
        color: isCurrent
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: isCurrent 
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: AppBorders.widthThin,
              )
            : null,
      ),
      child: AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: Icon(
          Icons.music_note_rounded,
          size: Dimensions.iconMedium,
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildDuration(BuildContext context, TrackInteractionHandler handler) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space8,
        vertical: Dimensions.space4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: AppBorders.subtleBorder(context),
      ),
      child: TrackDurationText(
        duration: handler.trackDuration,
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    TrackInteractionHandler handler,
    TrackUIFeedbackHandler feedbackHandler,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space8,
        vertical: Dimensions.space4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: TrackActionsSection(
        cacheIcon: SmartTrackCacheIcon(
          trackId: handler.trackId,
          audioUrl: handler.trackUrl,
          size: Dimensions.iconMedium,
          onSuccess: (message) => feedbackHandler.showSuccess(context, message),
          onError: (message) => feedbackHandler.showError(context, message),
        ),
        onActionsPressed: () => handler.handleOpenActionsSheet(context),
      ),
    );
  }

  bool _isCurrentTrack(AudioPlayerState playerState) {
    return playerState is AudioPlayerSessionState &&
        playerState.session.currentTrack?.id.value == widget.track.id.value;
  }

  user_profile.UserProfile? _getUploaderFromState(
    AudioContextState contextState,
  ) {
    if (contextState is AudioContextLoaded) {
      final collaborator = contextState.context.collaborator;
      if (collaborator != null) {
        return user_profile.UserProfile(
          id: UserId.fromUniqueString(collaborator.id),
          name: collaborator.name,
          email: collaborator.email ?? '',
          avatarUrl: collaborator.avatarUrl ?? '',
          createdAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  String _getUploaderNameFromState(AudioContextState contextState) {
    if (contextState is AudioContextLoaded) {
      return contextState.context.collaborator?.name ?? 'Unknown User';
    } else if (contextState is AudioContextLoading) {
      return 'Loading...';
    } else if (contextState is AudioContextError) {
      return 'Error';
    }
    return 'Unknown User';
  }
}

/// Backward compatibility wrapper for existing TrackComponent
class TrackComponent extends StatefulWidget {
  final AudioTrack track;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const TrackComponent({
    super.key,
    required this.track,
    this.onPlay,
    this.onComment,
    required this.projectId,
  });

  @override
  State<TrackComponent> createState() => _TrackComponentState();
}

class _TrackComponentState extends State<TrackComponent> {
  @override
  Widget build(BuildContext context) {
    return AppTrackComponent(
      track: widget.track,
      onPlay: widget.onPlay,
      onComment: widget.onComment,
      projectId: widget.projectId,
    );
  }
}