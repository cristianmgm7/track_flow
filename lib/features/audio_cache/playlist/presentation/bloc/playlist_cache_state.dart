import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist_cache_stats.dart';

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
  final Map<String, bool> trackStatuses;

  const PlaylistCacheStatusLoaded({required this.trackStatuses});

  @override
  List<Object?> get props => [trackStatuses];
}

class PlaylistCacheStatsLoaded extends PlaylistCacheState {
  final PlaylistCacheStats stats;
  final Map<String, dynamic> detailedProgress;

  const PlaylistCacheStatsLoaded({
    required this.stats,
    required this.detailedProgress,
  });

  @override
  List<Object?> get props => [stats, detailedProgress];
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

