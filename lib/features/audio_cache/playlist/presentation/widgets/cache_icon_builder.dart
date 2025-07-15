import 'package:flutter/material.dart';
import 'cache_icon_data.dart';
import '../bloc/playlist_cache_state.dart';
import '../../domain/entities/playlist_cache_stats.dart';

/// Builder class responsible for creating cache icons based on state
class CacheIconBuilder {
  const CacheIconBuilder();

  /// Builds icon widget from CacheIconData
  Widget buildIcon(CacheIconData data, double size) {
    if (data.isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: data.color,
        ),
      );
    }

    final icon = Icon(data.icon, size: size, color: data.color);

    if (data.showBadge && data.badgeText != null) {
      return _buildIconWithBadge(icon, data.badgeText!, data.badgeColor ?? data.color);
    }

    return Tooltip(message: data.tooltip, child: icon);
  }

  /// Creates CacheIconData from PlaylistCacheState
  CacheIconData getIconDataFromState(PlaylistCacheState state, List<String> trackIds) {
    if (state is PlaylistCacheLoading) {
      return CacheIconData.loading();
    }

    if (state is PlaylistCacheStatsLoaded) {
      return _getIconDataFromStats(state.stats);
    }

    if (state is PlaylistCacheStatusLoaded) {
      return _getIconDataFromStatus(state.trackStatuses, trackIds);
    }

    if (state is PlaylistCacheOperationSuccess) {
      return CacheIconData.fullyCached(tooltip: 'Operation completed successfully');
    }

    if (state is PlaylistCacheOperationFailure) {
      return CacheIconData.failed(tooltip: 'Operation failed: ${state.error}');
    }

    return CacheIconData.notCached();
  }

  CacheIconData _getIconDataFromStats(PlaylistCacheStats stats) {
    switch (stats.status) {
      case CacheStatus.fullyCached:
        return CacheIconData.fullyCached(
          tooltip: '${stats.progressDescription}\n${stats.statusDescription}',
        );
      
      case CacheStatus.downloading:
        return CacheIconData.downloading(
          tooltip: '${stats.progressDescription}\nDownloading ${stats.downloadingTracks} tracks...',
        );
      
      case CacheStatus.partiallyCached:
        return CacheIconData.partiallyCached(
          tooltip: '${stats.progressDescription}\n${stats.statusDescription}',
          badgeText: stats.cachedTracks.toString(),
        );
      
      case CacheStatus.failed:
        return CacheIconData.failed(
          tooltip: '${stats.progressDescription}\n${stats.failedTracks} tracks failed',
        );
      
      case CacheStatus.notCached:
        return CacheIconData.notCached();
    }
  }

  CacheIconData _getIconDataFromStatus(Map<String, bool> trackStatuses, List<String> trackIds) {
    final cachedCount = trackStatuses.values.where((exists) => exists).length;
    final totalCount = trackIds.length;
    final cachePercentage = totalCount > 0 ? cachedCount / totalCount : 0.0;

    if (cachePercentage == 1.0) {
      return CacheIconData.fullyCached(
        tooltip: 'Fully cached ($cachedCount/$totalCount tracks)',
      );
    } else if (cachePercentage > 0) {
      return CacheIconData.partiallyCached(
        tooltip: 'Partially cached ($cachedCount/$totalCount tracks)',
        badgeText: cachedCount.toString(),
      );
    } else {
      return CacheIconData.notCached();
    }
  }

  Widget _buildIconWithBadge(Widget icon, String badgeText, Color badgeColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}