import 'package:equatable/equatable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../domain/usecases/get_playlist_cache_status_usecase.dart';

sealed class PlaylistCacheState extends Equatable {
  const PlaylistCacheState();

  @override
  List<Object?> get props => [];
}

class PlaylistCacheInitial extends PlaylistCacheState {
  const PlaylistCacheInitial();
}

class PlaylistCacheLoading extends PlaylistCacheState {
  const PlaylistCacheLoading();
}

class PlaylistCacheStatusLoaded extends PlaylistCacheState {
  final Map<String, CacheStatus> trackStatuses;

  const PlaylistCacheStatusLoaded({
    required this.trackStatuses,
  });

  @override
  List<Object?> get props => [trackStatuses];
}

class PlaylistCacheStatsLoaded extends PlaylistCacheState {
  final PlaylistCacheStats stats;

  const PlaylistCacheStatsLoaded({
    required this.stats,
  });

  @override
  List<Object?> get props => [stats];
}

class PlaylistFullyCachedResult extends PlaylistCacheState {
  final bool isFullyCached;

  const PlaylistFullyCachedResult({
    required this.isFullyCached,
  });

  @override
  List<Object?> get props => [isFullyCached];
}

class CachedTrackIdsLoaded extends PlaylistCacheState {
  final List<String> cachedTrackIds;

  const CachedTrackIdsLoaded({
    required this.cachedTrackIds,
  });

  @override
  List<Object?> get props => [cachedTrackIds];
}

class UncachedTrackIdsLoaded extends PlaylistCacheState {
  final List<String> uncachedTrackIds;

  const UncachedTrackIdsLoaded({
    required this.uncachedTrackIds,
  });

  @override
  List<Object?> get props => [uncachedTrackIds];
}

class PlaylistCacheOperationSuccess extends PlaylistCacheState {
  final String playlistId;
  final String message;
  final int? affectedTracksCount;

  const PlaylistCacheOperationSuccess({
    required this.playlistId,
    required this.message,
    this.affectedTracksCount,
  });

  @override
  List<Object?> get props => [playlistId, message, affectedTracksCount];
}

class PlaylistCacheOperationFailure extends PlaylistCacheState {
  final String playlistId;
  final String error;

  const PlaylistCacheOperationFailure({
    required this.playlistId,
    required this.error,
  });

  @override
  List<Object?> get props => [playlistId, error];
}

class PlaylistCacheProgress extends PlaylistCacheState {
  final String playlistId;
  final int completedTracks;
  final int totalTracks;
  final double progressPercentage;

  const PlaylistCacheProgress({
    required this.playlistId,
    required this.completedTracks,
    required this.totalTracks,
    required this.progressPercentage,
  });

  @override
  List<Object?> get props => [playlistId, completedTracks, totalTracks, progressPercentage];
}