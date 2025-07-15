import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist_cache_stats.dart';

/// Value object that encapsulates all information needed to show cache dialogs
class CacheDialogData extends Equatable {
  const CacheDialogData({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.subtitle,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String? subtitle;
  final bool isDestructive;

  /// Factory for cache confirmation dialog
  factory CacheDialogData.forCache({
    required int trackCount,
    PlaylistCacheStats? stats,
  }) {
    final message = stats != null
        ? 'Cache remaining ${stats.totalTracks - stats.cachedTracks} tracks for offline playback?'
        : 'Cache $trackCount tracks for offline playback?';

    final subtitle = stats?.progressDescription;

    return CacheDialogData(
      title: 'Cache Playlist',
      message: message,
      actionLabel: 'Cache',
      subtitle: subtitle,
    );
  }

  /// Factory for remove confirmation dialog
  factory CacheDialogData.forRemove({
    required int trackCount,
    PlaylistCacheStats? stats,
  }) {
    final message = stats != null
        ? 'Remove ${stats.cachedTracks} cached tracks from this playlist?'
        : 'Remove all cached tracks for this playlist?';

    final subtitle = stats?.statusDescription;

    return CacheDialogData(
      title: 'Remove Cache',
      message: message,
      actionLabel: 'Remove',
      subtitle: subtitle,
      isDestructive: true,
    );
  }

  @override
  List<Object?> get props => [
        title,
        message,
        actionLabel,
        subtitle,
        isDestructive,
      ];
}