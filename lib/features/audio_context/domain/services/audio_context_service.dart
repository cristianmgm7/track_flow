import '../entities/track_context.dart';

/// Service for providing business context for audio tracks
/// Separated from pure audio playback concerns
abstract class AudioContextService {
  /// Get business context for a specific track
  Future<TrackContext?> getTrackContext(String trackId);

  /// Get context for multiple tracks efficiently
  Future<Map<String, TrackContext>> getTracksContext(List<String> trackIds);

  /// Stream context changes for a track
  /// Useful for real-time updates of collaboration info
  Stream<TrackContext> watchTrackContext(String trackId);

  /// Update track context information
  Future<void> updateTrackContext(TrackContext context);

  /// Get collaborators for a project
  Future<List<UserProfile>> getProjectCollaborators(String projectId);

  /// Check if user has permission to access track
  Future<bool> canAccessTrack(String trackId, String userId);
}