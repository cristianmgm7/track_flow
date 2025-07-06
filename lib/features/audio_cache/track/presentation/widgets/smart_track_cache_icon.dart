import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/value_objects/conflict_policy.dart';
import '../bloc/track_cache_bloc.dart';
import '../bloc/track_cache_state.dart';
import 'track_cache_animation_handler.dart';
import 'track_cache_icon_builder.dart';
import 'track_cache_interaction_handler.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../bloc/track_cache_event.dart';

class SmartTrackCacheIcon extends StatefulWidget {
  // Track identification
  final String trackId;
  final String audioUrl;
  final String? referenceId;

  // Visual configuration
  final double size;
  final Color? color;
  final bool showProgress;
  final bool enableHapticFeedback;
  final bool enableUndoAction;
  final Duration undoDuration;
  final ConflictPolicy conflictPolicy;

  // Callbacks
  final VoidCallback? onStateChanged;
  final Function(String message)? onSuccess;
  final Function(String message)? onError;

  const SmartTrackCacheIcon({
    super.key,
    required this.trackId,
    required this.audioUrl,
    this.referenceId,
    this.size = 24.0,
    this.color,
    this.showProgress = true,
    this.enableHapticFeedback = true,
    this.enableUndoAction = true,
    this.undoDuration = const Duration(seconds: 4),
    this.conflictPolicy = ConflictPolicy.lastWins,
    this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

  @override
  State<SmartTrackCacheIcon> createState() => _SmartTrackCacheIconState();
}

class _SmartTrackCacheIconState extends State<SmartTrackCacheIcon>
    with SingleTickerProviderStateMixin {
  late final TrackCacheAnimationHandler _animationHandler;
  late final TrackCacheIconBuilder _iconBuilder;
  late final TrackCacheInteractionHandler _interactionHandler;

  Timer? _progressPollingTimer;

  @override
  void initState() {
    super.initState();

    // Initialize handlers
    _animationHandler = TrackCacheAnimationHandler(vsync: this);
    _iconBuilder = const TrackCacheIconBuilder();
    _interactionHandler = TrackCacheInteractionHandler(
      config: TrackCacheInteractionConfig(
        trackId: widget.trackId,
        audioUrl: widget.audioUrl,
        referenceId: widget.referenceId,
        enableHapticFeedback: widget.enableHapticFeedback,
        enableUndoAction: widget.enableUndoAction,
        undoDuration: widget.undoDuration,
        conflictPolicy: widget.conflictPolicy,
      ),
      onStateChanged: widget.onStateChanged,
    );

    // Check initial cache status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackCacheBloc>().add(
        WatchTrackCacheStatusRequested(
          AudioTrackId.fromUniqueString(widget.trackId),
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressPollingTimer?.cancel();
    _animationHandler.dispose();
    super.dispose();
  }

  void _handleTap(TrackCacheState currentState) {
    // Animate for immediate feedback
    unawaited(_animationHandler.animateTap());

    // Handle interaction through dedicated handler
    _interactionHandler.handleTap(context, currentState);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackCacheBloc, TrackCacheState>(
      listener: (context, state) {
        if (state is TrackCacheOperationSuccess) {
          widget.onSuccess?.call(state.message);
          // No refresques el estado aquí, el stream lo hará automáticamente
        } else if (state is TrackCacheOperationFailure) {
          widget.onError?.call(state.error);
        }
      },
      child: BlocBuilder<TrackCacheBloc, TrackCacheState>(
        builder: (context, state) {
          CacheStatus status;
          if (state is TrackCacheStatusLoaded) {
            status = state.status;
          } else if (state is TrackCacheInfoWatching) {
            status = state.status;
          } else {
            status = CacheStatus.notCached;
          }

          final iconConfig = TrackCacheIconConfig(
            size: widget.size,
            color: widget.color,
            showProgress: widget.showProgress,
          );

          return InkWell(
            onTap: () => _handleTap(state),
            borderRadius: BorderRadius.circular(widget.size / 2),
            splashColor: (widget.color ?? Theme.of(context).primaryColor)
                .withValues(alpha: 0.2),
            highlightColor: (widget.color ?? Theme.of(context).primaryColor)
                .withValues(alpha: 0.1),
            child: Container(
              width: widget.size + 8,
              height: widget.size + 8,
              padding: const EdgeInsets.all(4),
              child: _animationHandler.buildAnimatedWidget(
                controller: _animationHandler.controller,
                child: _iconBuilder.buildIcon(
                  state,
                  iconConfig,
                  context,
                  lastKnownStatus: status,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
