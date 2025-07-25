import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/value_objects/conflict_policy.dart';
import '../bloc/track_cache_bloc.dart';
import '../bloc/track_cache_event.dart';
import '../bloc/track_cache_state.dart';

/// Configuration for interaction behavior
class TrackCacheInteractionConfig {
  final String trackId;
  final String audioUrl;
  final String? referenceId;
  final bool enableHapticFeedback;
  final bool enableUndoAction;
  final Duration undoDuration;
  final ConflictPolicy conflictPolicy;

  const TrackCacheInteractionConfig({
    required this.trackId,
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

    if (currentState is TrackCacheInfoWatching) {
      _handleInfoWatchingState(context, bloc, currentState);
    } else if (currentState is TrackCacheStatusLoaded) {
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

  /// Handle TrackCacheInfoWatching state
  void _handleInfoWatchingState(
    BuildContext context,
    TrackCacheBloc bloc,
    TrackCacheInfoWatching state,
  ) {
    if (state.isCached) {
      _removeFromCache(context, bloc);
    } else if (state.isDownloading) {
      _handleDownloadingState();
    } else {
      _startCaching(bloc);
    }
  }

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

  /// Handle downloading state with haptic feedback
  void _handleDownloadingState() {
    if (config.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  /// Remove track from cache and show undo if enabled
  void _removeFromCache(BuildContext context, TrackCacheBloc bloc) {
    bloc.add(
      RemoveTrackCacheRequested(
        trackId: config.trackId,
        referenceId: config.referenceId ?? 'individual',
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
        CacheTrackWithReferenceRequested(
          trackId: config.trackId,
          audioUrl: config.audioUrl,
          referenceId: config.referenceId!,
          policy: config.conflictPolicy,
        ),
      );
    } else {
      bloc.add(
        CacheTrackRequested(
          trackId: config.trackId,
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
      ),
    );
  }

  /// Refresh status after operation
  void refreshStatus(BuildContext context) {
    context.read<TrackCacheBloc>().add(
      WatchTrackCacheStatusRequested(
        AudioTrackId.fromUniqueString(config.trackId),
      ),
    );
  }
}
