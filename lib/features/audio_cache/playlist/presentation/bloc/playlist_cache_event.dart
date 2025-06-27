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

class CacheSelectedTracksRequested extends PlaylistCacheEvent {
  final String playlistId;
  final Map<String, String> selectedTrackUrlPairs;
  final ConflictPolicy policy;

  const CacheSelectedTracksRequested({
    required this.playlistId,
    required this.selectedTrackUrlPairs,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [playlistId, selectedTrackUrlPairs, policy];
}

class AddTrackToPlaylistCacheRequested extends PlaylistCacheEvent {
  final String playlistId;
  final String trackId;
  final String audioUrl;
  final ConflictPolicy policy;

  const AddTrackToPlaylistCacheRequested({
    required this.playlistId,
    required this.trackId,
    required this.audioUrl,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [playlistId, trackId, audioUrl, policy];
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

class RemoveSelectedTracksRequested extends PlaylistCacheEvent {
  final String playlistId;
  final List<String> selectedTrackIds;

  const RemoveSelectedTracksRequested({
    required this.playlistId,
    required this.selectedTrackIds,
  });

  @override
  List<Object?> get props => [playlistId, selectedTrackIds];
}

class RemoveTrackFromPlaylistRequested extends PlaylistCacheEvent {
  final String playlistId;
  final String trackId;

  const RemoveTrackFromPlaylistRequested({
    required this.playlistId,
    required this.trackId,
  });

  @override
  List<Object?> get props => [playlistId, trackId];
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

class CheckPlaylistFullyCachedRequested extends PlaylistCacheEvent {
  final List<String> trackIds;

  const CheckPlaylistFullyCachedRequested({
    required this.trackIds,
  });

  @override
  List<Object?> get props => [trackIds];
}

class GetCachedTrackIdsRequested extends PlaylistCacheEvent {
  final List<String> trackIds;

  const GetCachedTrackIdsRequested({
    required this.trackIds,
  });

  @override
  List<Object?> get props => [trackIds];
}

class GetUncachedTrackIdsRequested extends PlaylistCacheEvent {
  final List<String> trackIds;

  const GetUncachedTrackIdsRequested({
    required this.trackIds,
  });

  @override
  List<Object?> get props => [trackIds];
}