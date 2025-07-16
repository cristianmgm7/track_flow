import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/ui/modals/trackflow_action_sheet.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/audio_track_actions.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Configuration for track interactions
class TrackInteractionConfig {
  final AudioTrack track;
  final UserProfile? uploader;
  final ProjectId projectId;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;

  const TrackInteractionConfig({
    required this.track,
    required this.uploader,
    required this.projectId,
    this.onPlay,
    this.onComment,
  });
}

/// Handles all user interactions and business logic for tracks
class TrackInteractionHandler {
  final TrackInteractionConfig config;

  const TrackInteractionHandler({required this.config});

  /// Handle play/pause action
  void handlePlayTrack(BuildContext context) {
    if (config.uploader == null) return;

    if (config.onPlay != null) {
      config.onPlay!();
    } else {
      context.read<AudioPlayerBloc>().add(
        PlayAudioRequested(
          AudioTrackId.fromUniqueString(config.track.id.value),
        ),
      );
    }
  }

  /// Handle opening track actions sheet
  void handleOpenActionsSheet(BuildContext context) {
    showTrackFlowActionSheet(
      title: config.track.name,
      context: context,
      actions: TrackActions.forTrack(
        context,
        config.projectId,
        config.track,
        config.uploader != null ? [config.uploader!] : [],
      ),
    );
  }

  /// Check if track play button should be enabled
  bool get isPlayButtonEnabled => config.uploader != null;

  /// Get track name for display
  String get trackName => config.track.name;

  /// Get uploader name for display
  String get uploaderName => config.uploader?.name ?? 'Unknown User';

  /// Get track duration
  Duration get trackDuration => config.track.duration;

  /// Get track ID for audio operations
  String get trackId => config.track.id.value;

  /// Get track URL for cache operations
  String get trackUrl => config.track.url;
}

/// UI feedback handler for showing messages to user
class TrackUIFeedbackHandler {
  const TrackUIFeedbackHandler();

  /// Show success message
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
