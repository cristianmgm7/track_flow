import 'package:equatable/equatable.dart';
import 'audio_track_id.dart';

/// Pure audio queue management without business logic
/// Contains only the information needed for audio playback sequencing
class AudioQueue extends Equatable {
  const AudioQueue({
    required this.tracks,
    required this.currentIndex,
    this.shuffleEnabled = false,
    this.originalOrder,
  });

  /// List of track IDs in the current queue order
  final List<AudioTrackId> tracks;

  /// Current track index in the queue
  final int currentIndex;

  /// Whether shuffle mode is enabled
  final bool shuffleEnabled;

  /// Original order of tracks (before shuffle)
  /// Only populated when shuffle is enabled
  final List<AudioTrackId>? originalOrder;

  /// Check if queue is empty
  bool get isEmpty => tracks.isEmpty;

  /// Check if queue has tracks
  bool get isNotEmpty => tracks.isNotEmpty;

  /// Get current track ID (null if queue is empty or index invalid)
  AudioTrackId? get currentTrack {
    if (isEmpty || currentIndex < 0 || currentIndex >= tracks.length) {
      return null;
    }
    return tracks[currentIndex];
  }

  /// Check if there's a next track
  bool get hasNext => isNotEmpty && currentIndex < tracks.length - 1;

  /// Check if there's a previous track
  bool get hasPrevious => isNotEmpty && currentIndex > 0;

  /// Get next track ID (null if no next track)
  AudioTrackId? get nextTrack {
    if (!hasNext) return null;
    return tracks[currentIndex + 1];
  }

  /// Get previous track ID (null if no previous track)
  AudioTrackId? get previousTrack {
    if (!hasPrevious) return null;
    return tracks[currentIndex - 1];
  }

  /// Total number of tracks in queue
  int get length => tracks.length;

  @override
  List<Object?> get props => [tracks, currentIndex, shuffleEnabled, originalOrder];

  AudioQueue copyWith({
    List<AudioTrackId>? tracks,
    int? currentIndex,
    bool? shuffleEnabled,
    List<AudioTrackId>? originalOrder,
  }) {
    return AudioQueue(
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      originalOrder: originalOrder ?? this.originalOrder,
    );
  }

  /// Create empty queue
  factory AudioQueue.empty() => const AudioQueue(tracks: [], currentIndex: -1);

  /// Create queue from list of track IDs
  factory AudioQueue.fromTracks(List<AudioTrackId> tracks, {int currentIndex = 0}) {
    return AudioQueue(
      tracks: tracks,
      currentIndex: tracks.isEmpty ? -1 : currentIndex,
    );
  }

  @override
  String toString() => 'AudioQueue(tracks: ${tracks.length}, currentIndex: $currentIndex, shuffle: $shuffleEnabled)';
}