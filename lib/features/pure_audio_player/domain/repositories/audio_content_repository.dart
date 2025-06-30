import '../entities/audio_track_id.dart';
import '../entities/audio_track_metadata.dart';
import '../entities/playlist_id.dart';

/// Pure audio content repository interface
/// Provides access to audio track data without business domain concerns
/// NO: UserProfile, ProjectId, collaborators, or business context
abstract class AudioContentRepository {
  /// Get metadata for a specific audio track
  /// Returns only audio-related information needed for playback
  Future<AudioTrackMetadata> getTrackMetadata(AudioTrackId trackId);

  /// Get list of track metadata for a playlist
  /// Returns tracks in the order they should be played
  Future<List<AudioTrackMetadata>> getPlaylistTracks(PlaylistId playlistId);

  /// Get the audio source URL for playback
  /// This should handle cache vs streaming logic internally
  Future<String> getAudioSourceUrl(AudioTrackId trackId);

  /// Check if track is available for offline playback
  /// Used to determine playback availability without network
  Future<bool> isTrackCached(AudioTrackId trackId);

  /// Get multiple track metadata efficiently
  /// Useful for queue preparation and batch operations
  Future<List<AudioTrackMetadata>> getTracksMetadata(List<AudioTrackId> trackIds);

  /// Stream track metadata changes
  /// Useful for real-time updates to track information
  Stream<AudioTrackMetadata> watchTrackMetadata(AudioTrackId trackId);
}