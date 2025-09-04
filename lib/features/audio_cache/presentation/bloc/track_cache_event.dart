import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../domain/value_objects/conflict_policy.dart';

abstract class TrackCacheEvent extends Equatable {
  const TrackCacheEvent();

  @override
  List<Object?> get props => [];
}

class CacheTrackRequested extends TrackCacheEvent {
  final String trackId;
  final String audioUrl;
  final ConflictPolicy policy;

  const CacheTrackRequested({
    required this.trackId,
    required this.audioUrl,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [trackId, audioUrl, policy];
}

class CacheTrackWithReferenceRequested extends TrackCacheEvent {
  final String trackId;
  final String audioUrl;
  final String referenceId;
  final ConflictPolicy policy;

  const CacheTrackWithReferenceRequested({
    required this.trackId,
    required this.audioUrl,
    required this.referenceId,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [trackId, audioUrl, referenceId, policy];
}

class RemoveTrackCacheRequested extends TrackCacheEvent {
  final String trackId;
  final String referenceId;

  const RemoveTrackCacheRequested({
    required this.trackId,
    this.referenceId = 'individual',
  });

  @override
  List<Object?> get props => [trackId, referenceId];
}

class GetCachedTrackPathRequested extends TrackCacheEvent {
  final String trackId;

  const GetCachedTrackPathRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

/// Unified event to watch both cache status and download progress
class WatchTrackCacheInfoRequested extends TrackCacheEvent {
  final String trackId;

  const WatchTrackCacheInfoRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

/// Event to stop watching unified track cache info
class StopWatchingTrackCacheInfo extends TrackCacheEvent {
  const StopWatchingTrackCacheInfo();
}

class WatchTrackCacheStatusRequested extends TrackCacheEvent {
  final AudioTrackId trackId;

  const WatchTrackCacheStatusRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}
