import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/value_objects/conflict_policy.dart';
import '../bloc/track_cache_bloc.dart';
import '../bloc/track_cache_event.dart';
import '../bloc/track_cache_state.dart';

/// Configuration for interaction behavior
class TrackCacheInteractionConfig {
  final String trackId;
  final String versionId;
  final String audioUrl;
  final String? referenceId;
  final bool enableHapticFeedback;
  final bool enableUndoAction;
  final Duration undoDuration;
  final ConflictPolicy conflictPolicy;

  const TrackCacheInteractionConfig({
    required this.trackId,
    required this.versionId,
    required this.audioUrl,
    this.referenceId,
    this.enableHapticFeedback = true,
    this.enableUndoAction = true,
    this.undoDuration = const Duration(seconds: 4),
    this.conflictPolicy = ConflictPolicy.lastWins,
  });
}

/// Handles all user interactions and bloc events for track cache
class TrackCacheInteractionHandler {
  final TrackCacheInteractionConfig config;
  final VoidCallback? onStateChanged;

  const TrackCacheInteractionHandler({
    required this.config,
    this.onStateChanged,
  });

  /// Handle tap interaction based on current state
  void handleTap(BuildContext context, TrackCacheState currentState) {
    if (config.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    final bloc = context.read<TrackCacheBloc>();

    if (currentState is TrackCacheStatusLoaded) {
      _handleStatusLoadedState(context, bloc, currentState);
    } else if (currentState is TrackCacheLoading) {
      _handleLoadingState();
    } else if (currentState is TrackCacheOperationFailure) {
      _startCaching(bloc);
    } else {
      // Default action - start caching
      _startCaching(bloc);
    }

    onStateChanged?.call();
  }

  // Removed _handleInfoWatchingState since unified info is no longer used

  /// Handle TrackCacheStatusLoaded state
  void _handleStatusLoadedState(
    BuildContext context,
    TrackCacheBloc bloc,
    TrackCacheStatusLoaded state,
  ) {
    if (state.status == CacheStatus.cached) {
      _removeFromCache(context, bloc);
    } else {
      _startCaching(bloc);
    }
  }

  /// Handle loading state with haptic feedback
  void _handleLoadingState() {
    if (config.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  // Removed specific downloading handler; not needed with status-only UI

  /// Remove track from cache and show undo if enabled
  void _removeFromCache(BuildContext context, TrackCacheBloc bloc) {
    bloc.add(
      RemoveTrackCacheRequested(
        trackId: config.trackId,
        versionId: config.versionId,
      ),
    );

    if (config.enableUndoAction) {
      showUndoSnackBar(context);
    }
  }

  /// Start caching based on configuration
  void _startCaching(TrackCacheBloc bloc) {
    if (config.referenceId != null) {
      bloc.add(
        CacheTrackRequested(
          trackId: config.trackId,
          versionId: config.versionId,
          audioUrl: config.audioUrl,
          policy: config.conflictPolicy,
        ),
      );
    } else {
      bloc.add(
        CacheTrackRequested(
          trackId: config.trackId,
          versionId: config.versionId,
          audioUrl: config.audioUrl,
          policy: config.conflictPolicy,
        ),
      );
    }
  }

  /// Show undo snackbar
  void showUndoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Track removed from cache'),
        backgroundColor: Colors.green,
        duration: config.undoDuration,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => undoRemoval(context),
        ),
      ),
    );
  }

  /// Undo removal by re-caching the track
  void undoRemoval(BuildContext context) {
    final bloc = context.read<TrackCacheBloc>();
    _startCaching(bloc);
  }

  /// Request initial cache status
  void requestInitialStatus(BuildContext context) {
    context.read<TrackCacheBloc>().add(
      WatchTrackCacheStatusRequested(
        AudioTrackId.fromUniqueString(config.trackId),
        versionId: TrackVersionId.fromUniqueString(config.versionId),
      ),
    );
  }

  /// Refresh status after operation
  void refreshStatus(BuildContext context) {
    context.read<TrackCacheBloc>().add(
      WatchTrackCacheStatusRequested(
        AudioTrackId.fromUniqueString(config.trackId),
        versionId: TrackVersionId.fromUniqueString(config.versionId),
      ),
    );
  }
}
