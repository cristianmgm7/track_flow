import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_event.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart'
    as user_profile;

import 'widgets/track_actions_section.dart';
import 'widgets/track_duration_formatter.dart';
import 'widgets/track_info_section.dart';
import 'widgets/track_interaction_handler.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TrackCacheBloc>()),
        BlocProvider(
          create:
              (context) =>
                  sl<AudioContextBloc>()
                    ..add(LoadTrackContextRequested(widget.track.id)),
        ),
      ],
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, playerState) {
          final isCurrent = _isCurrentTrack(playerState);

          return Card(
            color:
                isCurrent
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.space4),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
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
                        child: InkWell(
                          onTap: () {
                            if (interactionHandler.isPlayButtonEnabled) {
                              interactionHandler.handlePlayTrack(context);
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Cover art placeholder
                              Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.space4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Track info section
                              TrackInfoSection(
                                trackName: interactionHandler.trackName,
                                uploaderName: _getUploaderNameFromState(
                                  contextState,
                                ),
                                statusBadge: Container(),
                              ),
                              const SizedBox(width: 8),
                              // Duration
                              TrackDurationText(
                                duration: interactionHandler.trackDuration,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Actions section (cache + menu)
                      TrackActionsSection(
                        cacheIcon: SmartTrackCacheIcon(
                          trackId: interactionHandler.trackId,
                          audioUrl: interactionHandler.trackUrl,
                          size: 20.0,
                          onSuccess:
                              (message) =>
                                  feedbackHandler.showSuccess(context, message),
                          onError:
                              (message) =>
                                  feedbackHandler.showError(context, message),
                        ),
                        onActionsPressed:
                            () => interactionHandler.handleOpenActionsSheet(
                              context,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
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
