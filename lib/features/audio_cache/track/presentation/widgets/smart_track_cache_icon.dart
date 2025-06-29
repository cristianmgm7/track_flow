import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/download_progress.dart';
import '../../../shared/domain/entities/track_cache_info.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';
import '../../../shared/domain/value_objects/conflict_policy.dart';
import '../bloc/track_cache_bloc.dart';
import '../bloc/track_cache_event.dart';
import '../bloc/track_cache_state.dart';

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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  CacheStatus? _lastKnownStatus;
  Timer? _progressPollingTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Check initial cache status and start watching unified stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackCacheBloc>().add(
        GetTrackCacheStatusRequested(widget.trackId),
      );
      // Start watching unified track cache info
      context.read<TrackCacheBloc>().add(
        WatchTrackCacheInfoRequested(widget.trackId),
      );
    });
  }

  @override
  void dispose() {
    _progressPollingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(TrackCacheState currentState) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Animate for immediate feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final bloc = context.read<TrackCacheBloc>();

    if (currentState is TrackCacheInfoWatching) {
      if (currentState.isCached) {
        // Already cached - remove from cache
        bloc.add(
          RemoveTrackCacheRequested(
            trackId: widget.trackId,
            referenceId: widget.referenceId ?? 'individual',
          ),
        );

        if (widget.enableUndoAction) {
          _showUndoSnackBar();
        }
      } else if (currentState.isDownloading) {
        // Currently downloading - could add cancel functionality in future
        if (widget.enableHapticFeedback) {
          HapticFeedback.selectionClick();
        }
      } else {
        // Not cached or failed - start caching
        _startCaching(bloc);
      }
    } else if (currentState is TrackCacheStatusLoaded) {
      if (currentState.status == CacheStatus.cached) {
        // Already cached - remove from cache
        bloc.add(
          RemoveTrackCacheRequested(
            trackId: widget.trackId,
            referenceId: widget.referenceId ?? 'individual',
          ),
        );

        if (widget.enableUndoAction) {
          _showUndoSnackBar();
        }
      } else {
        // Not cached - start caching
        _startCaching(bloc);
      }
    } else if (currentState is TrackCacheLoading) {
      // Currently loading - could add cancel functionality in future
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }
    } else if (currentState is TrackCacheOperationFailure) {
      // Error - retry caching
      _startCaching(bloc);
    } else {
      // Default action - start caching
      _startCaching(bloc);
    }

    widget.onStateChanged?.call();
  }

  void _startCaching(TrackCacheBloc bloc) {
    if (widget.referenceId != null) {
      bloc.add(
        CacheTrackWithReferenceRequested(
          trackId: widget.trackId,
          audioUrl: widget.audioUrl,
          referenceId: widget.referenceId!,
          policy: widget.conflictPolicy,
        ),
      );
    } else {
      bloc.add(
        CacheTrackRequested(
          trackId: widget.trackId,
          audioUrl: widget.audioUrl,
          policy: widget.conflictPolicy,
        ),
      );
    }
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track removed from cache'),
        backgroundColor: Colors.green,
        duration: widget.undoDuration,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => _undoRemoval(),
        ),
      ),
    );
  }

  void _undoRemoval() {
    // Re-cache the removed track
    final bloc = context.read<TrackCacheBloc>();
    _startCaching(bloc);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackCacheBloc, TrackCacheState>(
      listener: (context, state) {
        if (state is TrackCacheOperationSuccess) {
          widget.onSuccess?.call(state.message);

          // Refresh status after successful operation
          context.read<TrackCacheBloc>().add(
            GetTrackCacheStatusRequested(widget.trackId),
          );
        } else if (state is TrackCacheOperationFailure) {
          widget.onError?.call(state.error);
        } else if (state is TrackCacheStatusLoaded) {
          _lastKnownStatus = state.status;
        } else if (state is TrackCacheInfoWatching) {
          _lastKnownStatus = state.status;
        }
      },
      child: BlocBuilder<TrackCacheBloc, TrackCacheState>(
        builder: (context, state) {
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
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: _buildMainIcon(state),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainIcon(TrackCacheState state) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;

    // 🎯 NEW: Handle unified TrackCacheInfoWatching state
    if (state is TrackCacheInfoWatching) {
      return _buildUnifiedIcon(state, color);
    } else if (state is TrackCacheLoading) {
      // Loading state
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
        ),
      );
    } else if (state is TrackCacheStatusLoaded) {
      return _buildStatusIcon(state.status, color);
    } else if (state is TrackCacheOperationSuccess) {
      // Show success state briefly, then will update to actual status
      return Icon(Icons.check_circle, color: Colors.green, size: widget.size);
    } else if (state is TrackCacheOperationFailure) {
      // Error state - show retry icon
      return Icon(Icons.refresh, color: Colors.red, size: widget.size);
    } else if (_lastKnownStatus != null) {
      // Use last known status while loading
      return _buildStatusIcon(_lastKnownStatus!, color);
    }

    // Default state - show download icon
    return Icon(
      Icons.download_outlined,
      color: color.withValues(alpha: 0.7),
      size: widget.size,
    );
  }

  /// 🎯 NEW: Unified icon builder that handles both status and progress
  Widget _buildUnifiedIcon(TrackCacheInfoWatching state, Color color) {
    // If downloading, show progress
    if (state.isDownloading) {
      return _buildProgressIcon(state.progress, color);
    }

    // Otherwise, show status-based icon
    return _buildStatusIcon(state.status, color);
  }

  Widget _buildProgressIcon(DownloadProgress progress, Color color) {
    final progressValue = progress.progressPercentage;
    final progressPercent = (progressValue * 100).toInt();

    switch (progress.state) {
      case DownloadState.downloading:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue > 0 ? progressValue : null,
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
              if (widget.showProgress && progressPercent > 0)
                Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: widget.size * 0.25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
        );

      case DownloadState.completed:
        return Icon(
          Icons.download_done,
          color: Colors.green,
          size: widget.size,
        );

      case DownloadState.failed:
        return Icon(Icons.error_outline, color: Colors.red, size: widget.size);

      default:
        return Icon(
          Icons.download_outlined,
          color: color.withValues(alpha: 0.7),
          size: widget.size,
        );
    }
  }

  Widget _buildStatusIcon(CacheStatus status, Color color) {
    switch (status) {
      case CacheStatus.cached:
        return Icon(
          Icons.download_done,
          color: Colors.green,
          size: widget.size,
        );

      case CacheStatus.downloading:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
              Icon(Icons.close, color: color, size: widget.size * 0.5),
            ],
          ),
        );

      case CacheStatus.failed:
        return Icon(Icons.error_outline, color: Colors.red, size: widget.size);

      case CacheStatus.notCached:
      default:
        return Icon(
          Icons.download_outlined,
          color: color.withValues(alpha: 0.7),
          size: widget.size,
        );
    }
  }
}
