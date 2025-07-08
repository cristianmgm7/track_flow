import 'package:equatable/equatable.dart';

/// Events for audio context management
/// These events can be triggered by UI components based on audio player state changes
abstract class AudioContextEvent extends Equatable {
  const AudioContextEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load context for a specific track
class LoadTrackContextRequested extends AudioContextEvent {
  const LoadTrackContextRequested(this.trackId);

  final String trackId;

  @override
  List<Object?> get props => [trackId];

  @override
  String toString() => 'LoadTrackContextRequested(trackId: $trackId)';
}

/// Request to update track context
class UpdateTrackContextRequested extends AudioContextEvent {
  const UpdateTrackContextRequested(this.context);

  final dynamic context; // TrackContext from domain

  @override
  List<Object?> get props => [context];

  @override
  String toString() => 'UpdateTrackContextRequested(context: $context)';
}

/// Request to clear current context
class ClearTrackContextRequested extends AudioContextEvent {
  const ClearTrackContextRequested();

  @override
  String toString() => 'ClearTrackContextRequested()';
}

/// Request to start watching context changes for current track
class StartWatchingTrackContextRequested extends AudioContextEvent {
  const StartWatchingTrackContextRequested();

  @override
  String toString() => 'StartWatchingTrackContextRequested()';
}

/// Request to stop watching context changes
class StopWatchingTrackContextRequested extends AudioContextEvent {
  const StopWatchingTrackContextRequested();

  @override
  String toString() => 'StopWatchingTrackContextRequested()';
}
