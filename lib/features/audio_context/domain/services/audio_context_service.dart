import '../entities/track_context.dart';

/// Service for providing business context for audio tracks
/// Separated from pure audio playback concerns
abstract class AudioContextService {
  /// Get business context for a specific track
  Future<TrackContext?> getTrackContext(String trackId);

  /// Stream context changes for a track
  /// Useful for real-time updates of collaboration info
  Stream<TrackContext> watchTrackContext(String trackId);
}
