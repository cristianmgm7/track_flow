import 'package:flutter/material.dart';

import '../../domain/entities/cached_audio.dart';
// Removed download progress dependency; icon shows status only
import '../bloc/track_cache_state.dart';

/// Configuration for icon appearance
class TrackCacheIconConfig {
  final double size;
  final Color? color;
  final bool showProgress;

  const TrackCacheIconConfig({
    required this.size,
    this.color,
    this.showProgress = true,
  });
}

/// Builds appropriate icons based on track cache state
class TrackCacheIconBuilder {
  const TrackCacheIconBuilder();

  /// Main entry point for building icons
  Widget buildIcon(
    TrackCacheState state,
    TrackCacheIconConfig config,
    BuildContext context, {
    CacheStatus? lastKnownStatus,
  }) {
    final theme = Theme.of(context);
    final color = config.color ?? theme.primaryColor;

    if (state is TrackCacheLoading) {
      return _buildLoadingIcon(color, config.size);
    } else if (state is TrackCacheStatusLoaded) {
      return _buildStatusIcon(state.status, color, config);
    } else if (state is TrackCacheOperationSuccess) {
      return _buildSuccessIcon(config.size);
    } else if (state is TrackCacheOperationFailure) {
      return _buildErrorIcon(config.size);
    } else if (lastKnownStatus != null) {
      return _buildStatusIcon(lastKnownStatus, color, config);
    }

    // Default state - show download icon
    return _buildDefaultIcon(color, config.size);
  }
  // Removed unified icon (status + progress)

  // Removed progress icon builder; we only show status-based icons now

  /// Build icon based on cache status
  Widget _buildStatusIcon(
    CacheStatus status,
    Color color,
    TrackCacheIconConfig config,
  ) {
    switch (status) {
      case CacheStatus.cached:
        return Icon(
          Icons.download_done,
          color: Colors.green,
          size: config.size,
        );

      case CacheStatus.downloading:
        return SizedBox(
          width: config.size,
          height: config.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
              Icon(Icons.close, color: color, size: config.size * 0.5),
            ],
          ),
        );

      case CacheStatus.failed:
        return Icon(Icons.error_outline, color: Colors.red, size: config.size);

      case CacheStatus.notCached:
      default:
        return _buildDefaultIcon(color, config.size);
    }
  }

  /// Build loading indicator
  Widget _buildLoadingIcon(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );
  }

  /// Build success icon
  Widget _buildSuccessIcon(double size) {
    return Icon(Icons.check_circle, color: Colors.green, size: size);
  }

  /// Build error icon
  Widget _buildErrorIcon(double size) {
    return Icon(Icons.refresh, color: Colors.red, size: size);
  }

  /// Build default download icon
  Widget _buildDefaultIcon(Color color, double size) {
    return Icon(
      Icons.download_outlined,
      color: color.withValues(alpha: 0.7),
      size: size,
    );
  }
}
