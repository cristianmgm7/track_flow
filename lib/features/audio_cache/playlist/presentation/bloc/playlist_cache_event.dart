import 'package:equatable/equatable.dart';

import '../../../shared/domain/value_objects/conflict_policy.dart';

abstract class PlaylistCacheEvent extends Equatable {
  const PlaylistCacheEvent();

  @override
  List<Object?> get props => [];
}

class CachePlaylistRequested extends PlaylistCacheEvent {
  final String playlistId;
  final Map<String, String> trackUrlPairs;
  final ConflictPolicy policy;

  const CachePlaylistRequested({
    required this.playlistId,
    required this.trackUrlPairs,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [playlistId, trackUrlPairs, policy];
}


class RemovePlaylistCacheRequested extends PlaylistCacheEvent {
  final String playlistId;
  final List<String> trackIds;

  const RemovePlaylistCacheRequested({
    required this.playlistId,
    required this.trackIds,
  });

  @override
  List<Object?> get props => [playlistId, trackIds];
}


class GetPlaylistCacheStatusRequested extends PlaylistCacheEvent {
  final List<String> trackIds;

  const GetPlaylistCacheStatusRequested({
    required this.trackIds,
  });

  @override
  List<Object?> get props => [trackIds];
}

class GetPlaylistCacheStatsRequested extends PlaylistCacheEvent {
  final String playlistId;
  final List<String> trackIds;

  const GetPlaylistCacheStatsRequested({
    required this.playlistId,
    required this.trackIds,
  });

  @override
  List<Object?> get props => [playlistId, trackIds];
}

class GetDetailedProgressRequested extends PlaylistCacheEvent {
  final String playlistId;
  final List<String> trackIds;

  const GetDetailedProgressRequested({
    required this.playlistId,
    required this.trackIds,
  });

  @override
  List<Object?> get props => [playlistId, trackIds];
}

