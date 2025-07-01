import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playlist_cache_bloc.dart';
import '../bloc/playlist_cache_event.dart';
import '../bloc/playlist_cache_state.dart';
import '../../domain/entities/playlist_cache_stats.dart';

/// Widget that displays a cache icon for playlist with different states
class PlaylistCacheIcon extends StatelessWidget {
  const PlaylistCacheIcon({
    super.key,
    required this.playlistId,
    required this.trackIds,
    this.size = 24.0,
    this.onTap,
  });

  final String playlistId;
  final List<String> trackIds;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaylistCacheBloc, PlaylistCacheState>(
      listener: (context, state) {
        // Auto-load detailed stats when widget builds
        if (state is PlaylistCacheInitial) {
          context.read<PlaylistCacheBloc>().add(
            GetDetailedProgressRequested(
              playlistId: playlistId,
              trackIds: trackIds,
            ),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: onTap ?? () => _handleCacheAction(context, state),
          child: _buildIcon(state),
        );
      },
    );
  }

  Widget _buildIcon(PlaylistCacheState state) {
    if (state is PlaylistCacheLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    if (state is PlaylistCacheStatsLoaded) {
      return _buildStatsIcon(state.stats, state.detailedProgress);
    }

    if (state is PlaylistCacheStatusLoaded) {
      final cachedCount =
          state.trackStatuses.values.where((exists) => exists).length;
      final totalCount = trackIds.length;
      final cachePercentage = totalCount > 0 ? cachedCount / totalCount : 0.0;

      return _buildBasicIcon(cachePercentage, cachedCount, totalCount);
    }

    if (state is PlaylistCacheOperationSuccess) {
      if (state.playlistId == playlistId) {
        return Icon(Icons.check_circle, size: size, color: Colors.green);
      }
    }

    if (state is PlaylistCacheOperationFailure) {
      if (state.playlistId == playlistId) {
        return Icon(Icons.error, size: size, color: Colors.red);
      }
    }

    // Default state - not cached
    return Icon(Icons.cloud_off, size: size, color: Colors.grey);
  }

  Widget _buildStatsIcon(
    PlaylistCacheStats stats,
    Map<String, dynamic> progress,
  ) {
    final status = stats.status;

    // Show detailed progress text for partially cached
    if (status == CacheStatus.partiallyCached) {
      return Tooltip(
        message: '${stats.progressDescription}\n${stats.statusDescription}',
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.cloud_sync, size: size, color: Colors.orange),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  stats.cachedTracks.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Other states with rich tooltips
    return Tooltip(
      message: _getTooltipMessage(stats, progress),
      child: _getIconForStatus(status),
    );
  }

  Widget _buildBasicIcon(
    double cachePercentage,
    int cachedCount,
    int totalCount,
  ) {
    if (cachePercentage == 1.0) {
      return Tooltip(
        message: 'Fully cached ($cachedCount/$totalCount tracks)',
        child: Icon(Icons.cloud_done, size: size, color: Colors.green),
      );
    } else if (cachePercentage > 0) {
      return Tooltip(
        message: 'Partially cached ($cachedCount/$totalCount tracks)',
        child: Icon(Icons.cloud_sync, size: size, color: Colors.orange),
      );
    } else {
      return Tooltip(
        message: 'Not cached',
        child: Icon(Icons.cloud_off, size: size, color: Colors.grey),
      );
    }
  }

  Widget _getIconForStatus(CacheStatus status) {
    switch (status) {
      case CacheStatus.fullyCached:
        return Icon(Icons.cloud_done, size: size, color: Colors.green);
      case CacheStatus.downloading:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: Colors.blue,
          ),
        );
      case CacheStatus.partiallyCached:
        return Icon(Icons.cloud_sync, size: size, color: Colors.orange);
      case CacheStatus.failed:
        return Icon(Icons.error, size: size, color: Colors.red);
      case CacheStatus.notCached:
        return Icon(Icons.cloud_off, size: size, color: Colors.grey);
    }
  }

  String _getTooltipMessage(
    PlaylistCacheStats stats,
    Map<String, dynamic> progress,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(stats.progressDescription);
    buffer.writeln(stats.statusDescription);

    if (stats.hasFailures) {
      buffer.writeln('${stats.failedTracks} tracks failed');
    }

    if (stats.hasDownloading) {
      buffer.writeln('${stats.downloadingTracks} tracks downloading');
    }

    return buffer.toString().trim();
  }

  void _handleCacheAction(BuildContext context, PlaylistCacheState state) {
    if (state is PlaylistCacheLoading) {
      return; // Don't allow action while loading
    }

    if (state is PlaylistCacheStatsLoaded) {
      final stats = state.stats;
      final progress = state.detailedProgress;

      final canCache = progress['canCache'] as bool? ?? true;

      if (stats.isFullyCached) {
        _showRemoveCacheDialog(context, stats);
      } else if (canCache) {
        _showCacheDialog(context, stats);
      }
      return;
    }

    if (state is PlaylistCacheStatusLoaded) {
      final cachedCount =
          state.trackStatuses.values.where((exists) => exists).length;
      final totalCount = trackIds.length;

      if (cachedCount == totalCount) {
        _showRemoveCacheDialog(context, null);
      } else {
        _showCacheDialog(context, null);
      }
    } else {
      _showCacheDialog(context, null);
    }
  }

  void _showCacheDialog(BuildContext context, PlaylistCacheStats? stats) {
    final message =
        stats != null
            ? 'Cache remaining ${stats.totalTracks - stats.cachedTracks} tracks for offline playback?'
            : 'Cache ${trackIds.length} tracks for offline playback?';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cache Playlist'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (stats != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${stats.progressDescription}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _cachePlaylist(context);
                },
                child: const Text('Cache'),
              ),
            ],
          ),
    );
  }

  void _showRemoveCacheDialog(BuildContext context, PlaylistCacheStats? stats) {
    final message =
        stats != null
            ? 'Remove ${stats.cachedTracks} cached tracks from this playlist?'
            : 'Remove all cached tracks for this playlist?';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Cache'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (stats != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${stats.statusDescription}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removePlaylistCache(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _cachePlaylist(BuildContext context) {
    // Create a map of trackId to audioUrl (you'll need to provide the URLs)
    final trackUrlPairs = <String, String>{};
    for (final trackId in trackIds) {
      // TODO: Get the actual audio URL for each track
      trackUrlPairs[trackId] = 'https://example.com/audio/$trackId.mp3';
    }

    context.read<PlaylistCacheBloc>().add(
      CachePlaylistRequested(
        playlistId: playlistId,
        trackUrlPairs: trackUrlPairs,
      ),
    );
  }

  void _removePlaylistCache(BuildContext context) {
    context.read<PlaylistCacheBloc>().add(
      RemovePlaylistCacheRequested(playlistId: playlistId, trackIds: trackIds),
    );
  }
}
