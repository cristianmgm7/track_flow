import 'package:flutter/material.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/download_progress.dart';
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

    // Handle unified TrackCacheInfoWatching state
    if (state is TrackCacheInfoWatching) {
      return _buildUnifiedIcon(state, color, config);
    } else if (state is TrackCacheLoading) {
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

  /// Unified icon builder that handles both status and progress
  Widget _buildUnifiedIcon(
    TrackCacheInfoWatching state,
    Color color,
    TrackCacheIconConfig config,
  ) {
    // If downloading, show progress
    if (state.isDownloading) {
      return _buildProgressIcon(state.progress, color, config);
    }

    // Otherwise, show status-based icon
    return _buildStatusIcon(state.status, color, config);
  }

  /// Build progress indicator with percentage
  Widget _buildProgressIcon(
    DownloadProgress progress,
    Color color,
    TrackCacheIconConfig config,
  ) {
    final progressValue = progress.progressPercentage;
    final progressPercent = (progressValue * 100).toInt();

    switch (progress.state) {
      case DownloadState.downloading:
        return SizedBox(
          width: config.size,
          height: config.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue > 0 ? progressValue : null,
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
              if (config.showProgress && progressPercent > 0)
                Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: config.size * 0.25,
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
          size: config.size,
        );

      case DownloadState.failed:
        return Icon(Icons.error_outline, color: Colors.red, size: config.size);

      default:
        return _buildDefaultIcon(color, config.size);
    }
  }

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
