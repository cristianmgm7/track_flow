import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playlist_cache_bloc.dart';
import '../bloc/playlist_cache_event.dart';
import '../bloc/playlist_cache_state.dart';

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
    return BlocBuilder<PlaylistCacheBloc, PlaylistCacheState>(
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

    if (state is PlaylistCacheStatusLoaded) {
      final cachedCount =
          state.trackStatuses.values.where((exists) => exists).length;
      final totalCount = trackIds.length;
      final cachePercentage = totalCount > 0 ? cachedCount / totalCount : 0.0;

      if (cachePercentage == 1.0) {
        return Icon(Icons.cloud_done, size: size, color: Colors.green);
      } else if (cachePercentage > 0) {
        return Icon(Icons.cloud_sync, size: size, color: Colors.orange);
      } else {
        return Icon(Icons.cloud_off, size: size, color: Colors.grey);
      }
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

    // Default state - check if any tracks are cached
    return Icon(Icons.cloud_off, size: size, color: Colors.grey);
  }

  void _handleCacheAction(BuildContext context, PlaylistCacheState state) {
    if (state is PlaylistCacheLoading) {
      return; // Don't allow action while loading
    }

    if (state is PlaylistCacheStatusLoaded) {
      final cachedCount =
          state.trackStatuses.values.where((exists) => exists).length;
      final totalCount = trackIds.length;

      if (cachedCount == totalCount) {
        // All tracks cached, offer to remove
        _showRemoveCacheDialog(context);
      } else {
        // Some or no tracks cached, offer to cache
        _showCacheDialog(context);
      }
    } else {
      // No status loaded, offer to cache
      _showCacheDialog(context);
    }
  }

  void _showCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cache Playlist'),
            content: Text(
              'Cache ${trackIds.length} tracks for offline playback?',
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

  void _showRemoveCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Cache'),
            content: const Text('Remove all cached tracks for this playlist?'),
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

  void _getCacheStatus(BuildContext context) {
    context.read<PlaylistCacheBloc>().add(
      GetPlaylistCacheStatusRequested(trackIds: trackIds),
    );
  }
}
