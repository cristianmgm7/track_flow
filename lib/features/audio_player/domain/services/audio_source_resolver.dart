import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/models/audio_source_enum.dart';

/// Intelligent audio source determination service
/// Handles automatic fallback from cache to streaming with background caching
abstract class AudioSourceResolver {
  /// Resolves the best available audio source for a track
  /// Priority: Cache -> Local -> Streaming (with background caching)
  Future<Either<Failure, String>> resolveAudioSource(String originalUrl);

  /// Checks if a track is available in cache
  Future<bool> isTrackCached(String url);

  /// Validates cache integrity and returns path if valid
  Future<Either<Failure, String?>> validateCachedTrack(String url);

  /// Initiates background caching during streaming
  Future<void> startBackgroundCaching(String url);

  /// Gets cache status for a track
  Future<CacheStatus> getCacheStatus(String url);

  /// Clears invalid cache entries
  Future<void> clearInvalidCache();
}
