import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';

import 'widgets/track_play_button.dart';
import 'widgets/track_info_section.dart';
import 'widgets/track_duration_formatter.dart';
import 'widgets/track_actions_section.dart';
import 'widgets/track_interaction_handler.dart';

class TrackComponent extends StatefulWidget {
  final AudioTrack track;
  final UserProfile? uploader;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const TrackComponent({
    super.key,
    required this.track,
    required this.uploader,
    this.onPlay,
    this.onComment,
    required this.projectId,
  });

  @override
  State<TrackComponent> createState() => _TrackComponentState();
}

class _TrackComponentState extends State<TrackComponent> {
  late final TrackInteractionHandler _interactionHandler;
  late final TrackUIFeedbackHandler _feedbackHandler;

  @override
  void initState() {
    super.initState();
    _interactionHandler = TrackInteractionHandler(
      config: TrackInteractionConfig(
        track: widget.track,
        uploader: widget.uploader,
        projectId: widget.projectId,
        onPlay: widget.onPlay,
        onComment: widget.onComment,
      ),
    );
    _feedbackHandler = const TrackUIFeedbackHandler();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrackCacheBloc>(),
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, playerState) {
          final isCurrent = _isCurrentTrack(playerState);
          final isPlaying = isCurrent && playerState is AudioPlayerPlaying;

          return Card(
            color:
                isCurrent
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.space4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Play/Pause button
                  TrackPlayButton(
                    isCurrentTrack: isCurrent,
                    isPlaying: isPlaying,
                    isEnabled: _interactionHandler.isPlayButtonEnabled,
                    onTap: () => _interactionHandler.handlePlayTrack(context),
                  ),
                  const SizedBox(width: 12),
                  // Track info section
                  TrackInfoSection(
                    trackName: _interactionHandler.trackName,
                    uploaderName: _interactionHandler.uploaderName,
                    statusBadge: Container(), // TODO: Implement status badge
                  ),
                  const SizedBox(width: 8),
                  // Duration
                  TrackDurationText(
                    duration: _interactionHandler.trackDuration,
                  ),
                  const SizedBox(width: 8),
                  // Actions section (cache + menu)
                  TrackActionsSection(
                    cacheIcon: SmartTrackCacheIcon(
                      trackId: _interactionHandler.trackId,
                      audioUrl: _interactionHandler.trackUrl,
                      size: 20.0,
                      onSuccess:
                          (message) =>
                              _feedbackHandler.showSuccess(context, message),
                      onError:
                          (message) =>
                              _feedbackHandler.showError(context, message),
                    ),
                    onActionsPressed:
                        () =>
                            _interactionHandler.handleOpenActionsSheet(context),
                  ),
                ],
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
}
