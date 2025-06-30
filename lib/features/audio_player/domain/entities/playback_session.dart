import 'package:equatable/equatable.dart';
import 'audio_track_metadata.dart';
import 'audio_queue.dart';
import 'playback_state.dart';
import 'repeat_mode.dart';

/// Pure audio playback session state
/// Contains only audio-related information, NO business domain concerns
/// NO: UserProfile, ProjectId, collaborators, or any business context
class PlaybackSession extends Equatable {
  const PlaybackSession({
    this.currentTrack,
    required this.queue,
    required this.state,
    required this.position,
    required this.repeatMode,
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.error,
  });

  /// Current track metadata (null if no track loaded)
  final AudioTrackMetadata? currentTrack;

  /// Audio queue management
  final AudioQueue queue;

  /// Current playback state
  final PlaybackState state;

  /// Current position in the track
  final Duration position;

  /// Repeat mode setting
  final RepeatMode repeatMode;

  /// Playback speed multiplier (1.0 = normal speed)
  final double playbackSpeed;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Error message if state is error
  final String? error;

  /// Check if audio is currently playing
  bool get isPlaying => state == PlaybackState.playing;

  /// Check if audio is paused
  bool get isPaused => state == PlaybackState.paused;

  /// Check if audio is stopped
  bool get isStopped => state == PlaybackState.stopped;

  /// Check if audio is loading
  bool get isLoading => state == PlaybackState.loading;

  /// Check if there's an error
  bool get hasError => state == PlaybackState.error;

  /// Check if playback is completed
  bool get isCompleted => state == PlaybackState.completed;

  /// Get total duration of current track
  Duration? get duration => currentTrack?.duration;

  /// Get playback progress (0.0 to 1.0)
  double get progress {
    final dur = duration;
    if (dur == null || dur.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Check if shuffle is enabled
  bool get shuffleEnabled => queue.shuffleEnabled;

  /// Check if there's a next track
  bool get hasNext => queue.hasNext;

  /// Check if there's a previous track
  bool get hasPrevious => queue.hasPrevious;

  @override
  List<Object?> get props => [
        currentTrack,
        queue,
        state,
        position,
        repeatMode,
        playbackSpeed,
        volume,
        error,
      ];

  PlaybackSession copyWith({
    AudioTrackMetadata? currentTrack,
    AudioQueue? queue,
    PlaybackState? state,
    Duration? position,
    RepeatMode? repeatMode,
    double? playbackSpeed,
    double? volume,
    String? error,
  }) {
    return PlaybackSession(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      state: state ?? this.state,
      position: position ?? this.position,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      error: error ?? this.error,
    );
  }

  /// Create initial/empty session
  factory PlaybackSession.initial() {
    return PlaybackSession(
      queue: AudioQueue.empty(),
      state: PlaybackState.stopped,
      position: Duration.zero,
      repeatMode: RepeatMode.none,
    );
  }

  /// Create session with error state
  factory PlaybackSession.error(String errorMessage) {
    return PlaybackSession(
      queue: AudioQueue.empty(),
      state: PlaybackState.error,
      position: Duration.zero,
      repeatMode: RepeatMode.none,
      error: errorMessage,
    );
  }

  @override
  String toString() => 'PlaybackSession(track: ${currentTrack?.title}, state: $state, position: $position)';
}