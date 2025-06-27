import 'package:equatable/equatable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/cache_reference.dart';

sealed class TrackCacheState extends Equatable {
  const TrackCacheState();

  @override
  List<Object?> get props => [];
}

class TrackCacheInitial extends TrackCacheState {
  const TrackCacheInitial();
}

class TrackCacheLoading extends TrackCacheState {
  const TrackCacheLoading();
}

class TrackCacheStatusLoaded extends TrackCacheState {
  final String trackId;
  final CacheStatus status;

  const TrackCacheStatusLoaded({
    required this.trackId,
    required this.status,
  });

  @override
  List<Object?> get props => [trackId, status];
}

class TrackCachePathLoaded extends TrackCacheState {
  final String trackId;
  final String? filePath;

  const TrackCachePathLoaded({
    required this.trackId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [trackId, filePath];
}

class TrackCacheReferenceLoaded extends TrackCacheState {
  final String trackId;
  final CacheReference? reference;

  const TrackCacheReferenceLoaded({
    required this.trackId,
    required this.reference,
  });

  @override
  List<Object?> get props => [trackId, reference];
}

class TrackCacheOperationSuccess extends TrackCacheState {
  final String trackId;
  final String message;

  const TrackCacheOperationSuccess({
    required this.trackId,
    required this.message,
  });

  @override
  List<Object?> get props => [trackId, message];
}

class TrackCacheOperationFailure extends TrackCacheState {
  final String trackId;
  final String error;

  const TrackCacheOperationFailure({
    required this.trackId,
    required this.error,
  });

  @override
  List<Object?> get props => [trackId, error];
}

class TrackCacheWatching extends TrackCacheState {
  final String trackId;
  final CacheStatus currentStatus;

  const TrackCacheWatching({
    required this.trackId,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [trackId, currentStatus];
}