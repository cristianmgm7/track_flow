import '../entities/audio_source.dart';
import '../entities/playback_session.dart';
import '../entities/repeat_mode.dart';

/// Pure audio playback service interface
/// Handles only audio playback operations without business logic
/// NO: UserProfile, ProjectId, collaborators, or business concerns
abstract class AudioPlaybackService {
  /// Current playback session state
  Stream<PlaybackSession> get sessionStream;

  /// Get current session synchronously
  PlaybackSession get currentSession;

  /// Load and play an audio source
  Future<void> play(AudioSource source);

  /// Pause current playback (can be resumed)
  Future<void> pause();

  /// Resume paused playback
  Future<void> resume();

  /// Stop playback and reset position
  Future<void> stop();

  /// Seek to specific position in current track
  Future<void> seek(Duration position);

  /// Set playback speed (1.0 = normal speed)
  Future<void> setPlaybackSpeed(double speed);

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Set repeat mode
  Future<void> setRepeatMode(RepeatMode mode);

  /// Skip to next track in queue
  /// Returns false if no next track available
  Future<bool> skipToNext();

  /// Skip to previous track in queue
  /// Returns false if no previous track available
  Future<bool> skipToPrevious();

  /// Enable or disable shuffle mode
  /// When enabled, queue order is randomized
  Future<void> setShuffleEnabled(bool enabled);

  /// Load a queue of audio sources
  /// Replaces current queue and starts playing from specified index
  Future<void> loadQueue(List<AudioSource> sources, {int startIndex = 0});

  /// Add track to end of current queue
  Future<void> addToQueue(AudioSource source);

  /// Insert track at specific position in queue
  Future<void> insertInQueue(AudioSource source, int index);

  /// Remove track from queue by index
  Future<void> removeFromQueue(int index);

  /// Clear entire queue and stop playback
  Future<void> clearQueue();

  /// Release resources and cleanup
  Future<void> dispose();
}