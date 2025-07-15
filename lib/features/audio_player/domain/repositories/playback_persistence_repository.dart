import '../entities/playback_session.dart';

/// Pure audio state persistence repository
/// Handles saving/loading of audio playback state only
/// NO: UserProfile, ProjectId, collaboration data, or business context
abstract class PlaybackPersistenceRepository {
  /// Save current playback session state
  /// Only persists audio-related information
  Future<void> savePlaybackState(PlaybackSession session);

  /// Load previously saved playback session
  /// Returns null if no saved state exists
  Future<PlaybackSession?> loadPlaybackState();

  /// Clear saved playback state
  Future<void> clearPlaybackState();

  /// Check if saved state exists
  Future<bool> hasPlaybackState();

  /// Save queue information separately for faster access
  /// Useful for restoring queue without full session data
  Future<void> saveQueue(List<String> trackIds, int currentIndex);

  /// Load saved queue information
  Future<({List<String> trackIds, int currentIndex})?> loadQueue();

  /// Save playback position for specific track
  /// Allows resuming from last position when track is played again
  Future<void> saveTrackPosition(String trackId, Duration position);

  /// Load saved position for specific track
  Future<Duration?> loadTrackPosition(String trackId);

  /// Clear all track positions
  Future<void> clearTrackPositions();
}