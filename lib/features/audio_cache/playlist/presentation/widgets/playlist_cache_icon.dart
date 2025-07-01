import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playlist_cache_bloc.dart';
import '../bloc/playlist_cache_event.dart';
import '../bloc/playlist_cache_state.dart';
import '../../domain/entities/playlist_cache_stats.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/entities/unique_id.dart' as core_ids;
import '../../../../audio_player/domain/entities/audio_track_id.dart';
import '../../../../audio_player/domain/repositories/audio_content_repository.dart';
import 'cache_icon_builder.dart';
import 'cache_dialog_builder.dart';
import 'cache_dialog_data.dart';

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
    return BlocProvider<PlaylistCacheBloc>(
      create: (context) => sl<PlaylistCacheBloc>(),
      child: _PlaylistCacheIconContent(
        playlistId: playlistId,
        trackIds: trackIds,
        size: size,
        onTap: onTap,
      ),
    );
  }
}

class _PlaylistCacheIconContent extends StatelessWidget {
  const _PlaylistCacheIconContent({
    required this.playlistId,
    required this.trackIds,
    required this.size,
    this.onTap,
  });

  final String playlistId;
  final List<String> trackIds;
  final double size;
  final VoidCallback? onTap;

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

  Future<void> _showCacheDialog(
    BuildContext context,
    PlaylistCacheStats? stats,
  ) async {
    final dialogData = CacheDialogData.forCache(
      trackCount: trackIds.length,
      stats: stats,
    );

    final result = await _dialogBuilder.showConfirmationDialog(
      context,
      dialogData,
    );

    if (result == true && context.mounted) {
      unawaited(_cachePlaylist(context, context.read<PlaylistCacheBloc>()));
    }
  }

  Future<void> _showRemoveCacheDialog(
    BuildContext context,
    PlaylistCacheStats? stats,
  ) async {
    final dialogData = CacheDialogData.forRemove(
      trackCount: trackIds.length,
      stats: stats,
    );

    final result = await _dialogBuilder.showConfirmationDialog(
      context,
      dialogData,
    );

    if (result == true && context.mounted) {
      _removePlaylistCache(context, context.read<PlaylistCacheBloc>());
    }
  }

  Future<void> _cachePlaylist(
    BuildContext context,
    PlaylistCacheBloc bloc,
  ) async {
    final trackUrlPairs = <String, String>{};
    final audioContentRepository = sl<AudioContentRepository>();

    for (final trackId in trackIds) {
      try {
        // Convert business track ID to pure audio track ID
        final businessTrackId = core_ids.AudioTrackId.fromUniqueString(trackId);
        final audioTrackId = AudioTrackId(businessTrackId.value);

        // Get the actual audio URL
        final audioUrl = await audioContentRepository.getAudioSourceUrl(
          audioTrackId,
        );
        trackUrlPairs[trackId] = audioUrl;
      } catch (e) {
        // Skip tracks that fail to get URLs but continue with others
        debugPrint('Failed to get audio URL for track $trackId: $e');
      }
    }

    // Check if widget is still mounted and bloc is still open before adding event
    if (trackUrlPairs.isNotEmpty && context.mounted && !bloc.isClosed) {
      bloc.add(
        CachePlaylistRequested(
          playlistId: playlistId,
          trackUrlPairs: trackUrlPairs,
        ),
      );
    }
  }

  void _removePlaylistCache(BuildContext context, PlaylistCacheBloc bloc) {
    if (context.mounted && !bloc.isClosed) {
      bloc.add(
        RemovePlaylistCacheRequested(
          playlistId: playlistId,
          trackIds: trackIds,
        ),
      );
    }
  }

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
        final iconData = _iconBuilder.getIconDataFromState(state, trackIds);
        return GestureDetector(
          onTap: onTap ?? () => _handleCacheAction(context, state),
          child: _iconBuilder.buildIcon(iconData, size),
        );
      },
    );
  }

  // Builders
  static const _iconBuilder = CacheIconBuilder();
  static const _dialogBuilder = CacheDialogBuilder();
}
