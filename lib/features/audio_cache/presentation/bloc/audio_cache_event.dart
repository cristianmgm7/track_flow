import 'package:equatable/equatable.dart';

abstract class AudioCacheEvent extends Equatable {
  const AudioCacheEvent();

  @override
  List<Object?> get props => [];
}

class CheckCacheStatusRequested extends AudioCacheEvent {
  final String trackUrl;

  const CheckCacheStatusRequested(this.trackUrl);

  @override
  List<Object?> get props => [trackUrl];
}

class DownloadTrackRequested extends AudioCacheEvent {
  final String trackId;
  final String trackUrl;
  final String trackName;

  const DownloadTrackRequested({
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
  });

  @override
  List<Object?> get props => [trackId, trackUrl, trackName];
}

class CancelDownloadRequested extends AudioCacheEvent {
  final String trackId;

  const CancelDownloadRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class RemoveFromCacheRequested extends AudioCacheEvent {
  final String trackUrl;

  const RemoveFromCacheRequested(this.trackUrl);

  @override
  List<Object?> get props => [trackUrl];
}

class RetryDownloadRequested extends AudioCacheEvent {
  final String trackId;
  final String trackUrl;
  final String trackName;

  const RetryDownloadRequested({
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
  });

  @override
  List<Object?> get props => [trackId, trackUrl, trackName];
}

// Legacy support for existing code
class LoadCacheRequested extends AudioCacheEvent {
  final String remoteUrl;

  const LoadCacheRequested(this.remoteUrl);

  @override
  List<Object?> get props => [remoteUrl];
}