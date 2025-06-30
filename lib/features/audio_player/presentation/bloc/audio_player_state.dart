import 'package:equatable/equatable.dart';
import '../../domain/entities/playback_session.dart';
import '../../domain/entities/audio_failure.dart';

/// Pure audio player states - ONLY audio concerns
/// NO: UserProfile, ProjectId, collaborators, or business context
abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when audio player is first created
class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial();
}

/// Audio player is loading (initializing, restoring state, etc.)
class AudioPlayerLoading extends AudioPlayerState {
  const AudioPlayerLoading();
}

/// Base state for when audio player has a session
abstract class AudioPlayerSessionState extends AudioPlayerState {
  const AudioPlayerSessionState(this.session);

  /// Current playback session with pure audio information
  final PlaybackSession session;

  @override
  List<Object?> get props => [session];
}

/// Audio is currently playing
class AudioPlayerPlaying extends AudioPlayerSessionState {
  const AudioPlayerPlaying(super.session);

  @override
  String toString() => 'AudioPlayerPlaying(track: ${session.currentTrack?.title})';
}

/// Audio is paused (can be resumed)
class AudioPlayerPaused extends AudioPlayerSessionState {
  const AudioPlayerPaused(super.session);

  @override
  String toString() => 'AudioPlayerPaused(track: ${session.currentTrack?.title})';
}

/// Audio is stopped (position reset to beginning)
class AudioPlayerStopped extends AudioPlayerSessionState {
  const AudioPlayerStopped(super.session);

  @override
  String toString() => 'AudioPlayerStopped';
}

/// Audio is loading/buffering a track
class AudioPlayerBuffering extends AudioPlayerSessionState {
  const AudioPlayerBuffering(super.session);

  @override
  String toString() => 'AudioPlayerBuffering(track: ${session.currentTrack?.title})';
}

/// Audio playback completed (reached end of track/queue)
class AudioPlayerCompleted extends AudioPlayerSessionState {
  const AudioPlayerCompleted(super.session);

  @override
  String toString() => 'AudioPlayerCompleted';
}

/// Error state with pure audio error information
class AudioPlayerError extends AudioPlayerState {
  const AudioPlayerError(this.failure, [this.session]);

  /// Audio-specific failure information
  final AudioFailure failure;
  
  /// Optional session state when error occurred
  final PlaybackSession? session;

  @override
  List<Object?> get props => [failure, session];

  @override
  String toString() => 'AudioPlayerError(${failure.message})';
}

/// Audio player is ready but no track loaded
class AudioPlayerReady extends AudioPlayerState {
  const AudioPlayerReady();

  @override
  String toString() => 'AudioPlayerReady';
}