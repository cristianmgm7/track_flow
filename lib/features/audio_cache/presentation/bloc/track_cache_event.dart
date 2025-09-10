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

// Removed referenced-based caching to simplify API

class RemoveTrackCacheRequested extends TrackCacheEvent {
  final String trackId;

  const RemoveTrackCacheRequested({required this.trackId});

  @override
  List<Object?> get props => [trackId];
}

class GetCachedTrackPathRequested extends TrackCacheEvent {
  final String trackId;

  const GetCachedTrackPathRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

// Removed unified info watching events (status + progress) since UI doesn't use them

class WatchTrackCacheStatusRequested extends TrackCacheEvent {
  final AudioTrackId trackId;
  final TrackVersionId? versionId;

  const WatchTrackCacheStatusRequested(this.trackId, {this.versionId});

  @override
  List<Object?> get props => [trackId, versionId];
}
