import 'package:equatable/equatable.dart';

import '../../domain/entities/cached_audio.dart';
// Removed download_progress import; progress UI is not handled here

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

  const TrackCacheStatusLoaded({required this.trackId, required this.status});

  @override
  List<Object?> get props => [trackId, status];
}

class TrackCachePathLoaded extends TrackCacheState {
  final String trackId;
  final String? filePath;

  const TrackCachePathLoaded({required this.trackId, required this.filePath});

  @override
  List<Object?> get props => [trackId, filePath];
}

// Removed reference-based state

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

/// Download ready - file path with friendly name for sharing
class TrackDownloadReady extends TrackCacheState {
  final String trackId;
  final String filePath; // Path to temp file with friendly name

  const TrackDownloadReady({
    required this.trackId,
    required this.filePath,
  });

  @override
  List<Object> get props => [trackId, filePath];
}

/// Download failed - either permission denied or file not ready
class TrackDownloadFailure extends TrackCacheState {
  final String trackId;
  final String error;
  final bool isPermissionError;

  const TrackDownloadFailure({
    required this.trackId,
    required this.error,
    this.isPermissionError = false,
  });

  @override
  List<Object> get props => [trackId, error, isPermissionError];
}

class TrackCacheOperationInProgress extends TrackCacheState {
  final String trackId;

  const TrackCacheOperationInProgress({required this.trackId});

  @override
  List<Object> get props => [trackId];
}

// Removed unified progress + status state since UI uses status-only
