import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playlist_cache_bloc.dart';
import '../bloc/playlist_cache_event.dart';
import '../bloc/playlist_cache_state.dart';
import '../../domain/entities/playlist_cache_stats.dart';
import 'cache_icon_builder.dart';
import 'cache_dialog_builder.dart';
import 'cache_dialog_data.dart';

/// Widget that displays a cache icon for playlist with different states.
///
/// NOTE: This widget expects a PlaylistCacheBloc to be provided by an ancestor BlocProvider.
/// For correct synchronization, provide the Bloc at the PlaylistWidget or screen level.
class PlaylistCacheIcon extends StatefulWidget {
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
  State<PlaylistCacheIcon> createState() => _PlaylistCacheIconState();
}

class _PlaylistCacheIconState extends State<PlaylistCacheIcon> {
  @override
  void initState() {
    super.initState();
    // Emit the event to load detailed progress when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistCacheBloc>().add(
          GetDetailedProgressRequested(
            playlistId: widget.playlistId,
            trackIds: widget.trackIds,
          ),
        );
      }
    });
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
      final totalCount = widget.trackIds.length;
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
      trackCount: widget.trackIds.length,
      stats: stats,
    );
    final result = await _dialogBuilder.showConfirmationDialog(
      context,
      dialogData,
    );
    if (result == true && context.mounted) {
      // Dispatch event to BLoC, let BLoC handle repository logic
      context.read<PlaylistCacheBloc>().add(
        CachePlaylistRequested(
          playlistId: widget.playlistId,
          trackIds: widget.trackIds,
        ),
      );
    }
  }

  Future<void> _showRemoveCacheDialog(
    BuildContext context,
    PlaylistCacheStats? stats,
  ) async {
    final dialogData = CacheDialogData.forRemove(
      trackCount: widget.trackIds.length,
      stats: stats,
    );
    final result = await _dialogBuilder.showConfirmationDialog(
      context,
      dialogData,
    );
    if (result == true && context.mounted) {
      context.read<PlaylistCacheBloc>().add(
        RemovePlaylistCacheRequested(
          playlistId: widget.playlistId,
          trackIds: widget.trackIds,
        ),
      );
    }
  }

  // Builders
  static const _iconBuilder = CacheIconBuilder();
  static const _dialogBuilder = CacheDialogBuilder();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCacheBloc, PlaylistCacheState>(
      builder: (context, state) {
        final iconData = _iconBuilder.getIconDataFromState(
          state,
          widget.trackIds,
        );
        return GestureDetector(
          onTap: widget.onTap ?? () => _handleCacheAction(context, state),
          child: _iconBuilder.buildIcon(iconData, widget.size),
        );
      },
    );
  }
}
