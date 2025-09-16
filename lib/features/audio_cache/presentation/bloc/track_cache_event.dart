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
  final String versionId;
  final ConflictPolicy policy;

  const CacheTrackRequested({
    required this.trackId,
    required this.audioUrl,
    required this.versionId,
    this.policy = ConflictPolicy.lastWins,
  });

  @override
  List<Object?> get props => [trackId, audioUrl, versionId, policy];
}

// Removed referenced-based caching to simplify API

class RemoveTrackCacheRequested extends TrackCacheEvent {
  final String trackId;
  final String? versionId;

  const RemoveTrackCacheRequested({required this.trackId, this.versionId});

  @override
  List<Object?> get props => [trackId, versionId];
}

class GetCachedTrackPathRequested extends TrackCacheEvent {
  final String trackId;
  final String? versionId;

  const GetCachedTrackPathRequested(this.trackId, {this.versionId});

  @override
  List<Object?> get props => [trackId, versionId];
}

// Removed unified info watching events (status + progress) since UI doesn't use them

class WatchTrackCacheStatusRequested extends TrackCacheEvent {
  final AudioTrackId trackId;
  final TrackVersionId? versionId;

  const WatchTrackCacheStatusRequested(this.trackId, {this.versionId});

  @override
  List<Object?> get props => [trackId, versionId];
}
