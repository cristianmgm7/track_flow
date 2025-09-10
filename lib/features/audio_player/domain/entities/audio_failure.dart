import 'package:equatable/equatable.dart';

/// Pure audio-related failures
/// Contains only audio playback errors, no business domain failures
abstract class AudioFailure extends Equatable {
  const AudioFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// Track not found or inaccessible
class TrackNotFoundFailure extends AudioFailure {
  const TrackNotFoundFailure(String trackId)
    : super('Track not found: $trackId');
}

/// Version not found or inaccessible
class VersionNotFoundFailure extends AudioFailure {
  const VersionNotFoundFailure(String versionId)
    : super('Version not found: $versionId');
}

/// Audio source URL could not be resolved
class AudioSourceFailure extends AudioFailure {
  const AudioSourceFailure(String trackId)
    : super('Could not resolve audio source for track: $trackId');
}

/// Network error when trying to load remote audio
class NetworkFailure extends AudioFailure {
  const NetworkFailure() : super('Network error occurred while loading audio');
}

/// Audio playback error (codec, format, etc.)
class PlaybackFailure extends AudioFailure {
  const PlaybackFailure(String details) : super('Playback error: $details');
}

/// Playlist not found or empty
class PlaylistFailure extends AudioFailure {
  const PlaylistFailure(String playlistId)
    : super('Playlist error: $playlistId');
}

/// Invalid queue operation
class QueueFailure extends AudioFailure {
  const QueueFailure(String operation)
    : super('Queue operation failed: $operation');
}

/// Audio cache/storage failure
class StorageFailure extends AudioFailure {
  const StorageFailure(String details) : super('Storage error: $details');
}

/// Generic audio player failure
class AudioPlayerFailure extends AudioFailure {
  const AudioPlayerFailure(String details)
    : super('Audio player error: $details');
}
