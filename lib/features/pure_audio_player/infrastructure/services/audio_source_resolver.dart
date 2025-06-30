import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Pure audio source resolver interface
/// Handles cache vs streaming decisions for pure audio architecture
/// NO business logic - only audio source resolution
abstract class AudioSourceResolver {
  /// Resolve the best audio source URL for playback
  /// Returns cached path if available, otherwise original URL
  Future<Either<Failure, String>> resolveAudioSource(String originalUrl);

  /// Check if a track is cached and available offline
  Future<bool> isTrackCached(String url);

  /// Validate cached track integrity
  /// Returns cached path if valid, null if not cached/invalid
  Future<Either<Failure, String?>> validateCachedTrack(String url);

  /// Start background caching for future offline use
  /// Does not block current playback
  Future<void> startBackgroundCaching(String url);

  /// Preload audio source for immediate playback
  /// Similar to background caching but with higher priority
  Future<Either<Failure, void>> preloadAudioSource(
    String url, {
    required String referenceId,
  });
}