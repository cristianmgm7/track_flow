import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';

/// Service for persisting and restoring playback state across app sessions
abstract class PlaybackStatePersistence {
  /// Saves the current playback state to persistent storage
  Future<Either<Failure, Unit>> savePlaybackState(PersistedPlaybackState state);
  
  /// Restores the playback state from persistent storage
  Future<Either<Failure, PersistedPlaybackState?>> restorePlaybackState();
  
  /// Clears all persisted playback state
  Future<Either<Failure, Unit>> clearPlaybackState();
  
  /// Saves only the position for the current track (for frequent updates)
  Future<Either<Failure, Unit>> savePosition(Duration position);
}

/// Simplified state representation for persistence
class PersistedPlaybackState {
  final String? currentTrackId;
  final List<String> queue;
  final int currentIndex;
  final RepeatMode repeatMode;
  final PlaybackQueueMode queueMode;
  final Duration lastPosition;
  final String? playlistId;
  final bool wasPlaying;
  final DateTime lastUpdated;

  const PersistedPlaybackState({
    this.currentTrackId,
    required this.queue,
    required this.currentIndex,
    required this.repeatMode,
    required this.queueMode,
    required this.lastPosition,
    this.playlistId,
    required this.wasPlaying,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentTrackId': currentTrackId,
      'queue': queue,
      'currentIndex': currentIndex,
      'repeatMode': repeatMode.index,
      'queueMode': queueMode.index,
      'lastPosition': lastPosition.inMilliseconds,
      'playlistId': playlistId,
      'wasPlaying': wasPlaying,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PersistedPlaybackState.fromJson(Map<String, dynamic> json) {
    return PersistedPlaybackState(
      currentTrackId: json['currentTrackId'] as String?,
      queue: (json['queue'] as List<dynamic>).cast<String>(),
      currentIndex: json['currentIndex'] as int,
      repeatMode: RepeatMode.values[json['repeatMode'] as int],
      queueMode: PlaybackQueueMode.values[json['queueMode'] as int],
      lastPosition: Duration(milliseconds: json['lastPosition'] as int),
      playlistId: json['playlistId'] as String?,
      wasPlaying: json['wasPlaying'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  PersistedPlaybackState copyWith({
    String? currentTrackId,
    List<String>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    PlaybackQueueMode? queueMode,
    Duration? lastPosition,
    String? playlistId,
    bool? wasPlaying,
    DateTime? lastUpdated,
  }) {
    return PersistedPlaybackState(
      currentTrackId: currentTrackId ?? this.currentTrackId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      queueMode: queueMode ?? this.queueMode,
      lastPosition: lastPosition ?? this.lastPosition,
      playlistId: playlistId ?? this.playlistId,
      wasPlaying: wasPlaying ?? this.wasPlaying,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}