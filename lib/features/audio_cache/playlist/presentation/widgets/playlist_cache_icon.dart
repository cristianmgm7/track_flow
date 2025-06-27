import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/value_objects/conflict_policy.dart';
import '../../domain/usecases/get_playlist_cache_status_usecase.dart';
import '../bloc/playlist_cache_bloc.dart';
import '../bloc/playlist_cache_event.dart';
import '../bloc/playlist_cache_state.dart';

class PlaylistCacheIcon extends StatefulWidget {
  // Playlist identification
  final String playlistId;
  final Map<String, String> trackUrlPairs; // trackId -> audioUrl
  final String? playlistName;
  
  // Visual configuration
  final double size;
  final Color? color;
  final bool showProgress;
  final bool showTrackCount;
  final bool enableHapticFeedback;
  final ConflictPolicy conflictPolicy;
  
  // Callbacks
  final VoidCallback? onStateChanged;
  final Function(String message)? onSuccess;
  final Function(String message)? onError;

  const PlaylistCacheIcon({
    super.key,
    required this.playlistId,
    required this.trackUrlPairs,
    this.playlistName,
    this.size = 28.0,
    this.color,
    this.showProgress = true,
    this.showTrackCount = true,
    this.enableHapticFeedback = true,
    this.conflictPolicy = ConflictPolicy.lastWins,
    this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

  @override
  State<PlaylistCacheIcon> createState() => _PlaylistCacheIconState();
}

class _PlaylistCacheIconState extends State<PlaylistCacheIcon> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  PlaylistCacheStats? _lastKnownStats;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Check initial cache status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistCacheBloc>().add(
        GetPlaylistCacheStatsRequested(
          playlistId: widget.playlistId,
          trackIds: widget.trackUrlPairs.keys.toList(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(PlaylistCacheState currentState) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Animate for immediate feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final bloc = context.read<PlaylistCacheBloc>();

    if (currentState is PlaylistCacheStatsLoaded) {
      final stats = currentState.stats;
      
      if (stats.isFullyCached) {
        // All tracks cached - remove entire playlist
        bloc.add(RemovePlaylistCacheRequested(
          playlistId: widget.playlistId,
          trackIds: widget.trackUrlPairs.keys.toList(),
        ));
        _showRemovalSnackBar(stats.totalTracks);
      } else {
        // Some or no tracks cached - cache the playlist
        bloc.add(CachePlaylistRequested(
          playlistId: widget.playlistId,
          trackUrlPairs: widget.trackUrlPairs,
          policy: widget.conflictPolicy,
        ));
      }
    } else if (currentState is PlaylistCacheLoading) {
      // Currently loading - provide feedback
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }
    } else if (currentState is PlaylistCacheOperationFailure) {
      // Error - retry caching
      bloc.add(CachePlaylistRequested(
        playlistId: widget.playlistId,
        trackUrlPairs: widget.trackUrlPairs,
        policy: widget.conflictPolicy,
      ));
    } else {
      // Default action - cache playlist
      bloc.add(CachePlaylistRequested(
        playlistId: widget.playlistId,
        trackUrlPairs: widget.trackUrlPairs,
        policy: widget.conflictPolicy,
      ));
    }
    
    widget.onStateChanged?.call();
  }

  void _showRemovalSnackBar(int trackCount) {
    final playlistName = widget.playlistName ?? 'Playlist';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$playlistName ($trackCount tracks) removed from cache'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => _undoRemoval(),
        ),
      ),
    );
  }

  void _undoRemoval() {
    // Re-cache the removed playlist
    context.read<PlaylistCacheBloc>().add(CachePlaylistRequested(
      playlistId: widget.playlistId,
      trackUrlPairs: widget.trackUrlPairs,
      policy: widget.conflictPolicy,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistCacheBloc, PlaylistCacheState>(
      listener: (context, state) {
        if (state is PlaylistCacheOperationSuccess) {
          widget.onSuccess?.call(state.message);
          
          // Refresh stats after successful operation
          context.read<PlaylistCacheBloc>().add(
            GetPlaylistCacheStatsRequested(
              playlistId: widget.playlistId,
              trackIds: widget.trackUrlPairs.keys.toList(),
            ),
          );
        } else if (state is PlaylistCacheOperationFailure) {
          widget.onError?.call(state.error);
        } else if (state is PlaylistCacheStatsLoaded) {
          _lastKnownStats = state.stats;
        }
      },
      child: BlocBuilder<PlaylistCacheBloc, PlaylistCacheState>(
        builder: (context, state) {
          return InkWell(
            onTap: () => _handleTap(state),
            borderRadius: BorderRadius.circular(widget.size / 2),
            splashColor: (widget.color ?? Theme.of(context).primaryColor)
                .withValues(alpha: 0.2),
            highlightColor: (widget.color ?? Theme.of(context).primaryColor)
                .withValues(alpha: 0.1),
            child: Container(
              width: widget.size + 12,
              height: widget.size + 12,
              padding: const EdgeInsets.all(6),
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

  Widget _buildMainIcon(PlaylistCacheState state) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;

    Widget iconWidget;

    if (state is PlaylistCacheLoading) {
      // Loading state
      iconWidget = SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
        ),
      );
    } else if (state is PlaylistCacheStatsLoaded) {
      iconWidget = _buildStatsIcon(state.stats, color);
    } else if (state is PlaylistCacheProgress) {
      iconWidget = _buildProgressIcon(state, color);
    } else if (state is PlaylistCacheOperationSuccess) {
      // Show success state briefly
      iconWidget = Icon(
        Icons.check_circle,
        color: Colors.green,
        size: widget.size,
      );
    } else if (state is PlaylistCacheOperationFailure) {
      // Error state - show retry icon
      iconWidget = Icon(
        Icons.refresh,
        color: Colors.red,
        size: widget.size,
      );
    } else if (_lastKnownStats != null) {
      // Use last known stats while loading
      iconWidget = _buildStatsIcon(_lastKnownStats!, color);
    } else {
      // Default state - show download icon
      iconWidget = Icon(
        Icons.playlist_add_circle_outlined,
        color: color.withValues(alpha: 0.7),
        size: widget.size,
      );
    }

    // Add track count badge if enabled
    if (widget.showTrackCount) {
      return Stack(
        alignment: Alignment.center,
        children: [
          iconWidget,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                '${widget.trackUrlPairs.length}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: widget.size * 0.25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }

  Widget _buildStatsIcon(PlaylistCacheStats stats, Color color) {
    if (stats.isFullyCached) {
      // All tracks cached
      return Icon(
        Icons.playlist_add_check_circle,
        color: Colors.green,
        size: widget.size,
      );
    } else if (stats.isPartiallyCached) {
      // Some tracks cached - show progress circle
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: stats.cachePercentage,
              strokeWidth: 2,
              color: Colors.orange,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
          Icon(
            Icons.playlist_add_circle_outlined,
            color: Colors.orange,
            size: widget.size * 0.6,
          ),
        ],
      );
    } else if (stats.hasDownloading) {
      // Currently downloading
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
        ),
      );
    } else if (stats.hasFailures) {
      // Has failed tracks
      return Icon(
        Icons.error_outline,
        color: Colors.red,
        size: widget.size,
      );
    } else {
      // No tracks cached
      return Icon(
        Icons.playlist_add_circle_outlined,
        color: color.withValues(alpha: 0.7),
        size: widget.size,
      );
    }
  }

  Widget _buildProgressIcon(PlaylistCacheProgress progress, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: progress.progressPercentage,
            strokeWidth: 2,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        ),
        Text(
          '${progress.completedTracks}/${progress.totalTracks}',
          style: TextStyle(
            fontSize: widget.size * 0.2,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}