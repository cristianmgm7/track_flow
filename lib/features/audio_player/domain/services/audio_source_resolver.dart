import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Pure audio source resolver interface
/// Handles cache vs streaming decisions for pure audio architecture
/// NO business logic - only audio source resolution
abstract class AudioSourceResolver {
  /// Resolve the best audio source URL for playback
  /// Returns cached path if available, otherwise original URL
  /// [originalUrl] - The original remote URL of the audio
  /// [trackId] - The track ID for consistent cache operations
  Future<Either<Failure, String>> resolveAudioSource(
    String originalUrl, {
    String? trackId,
  });

  /// Check if a track is cached and available offline
  /// [url] - The original URL of the audio
  /// [trackId] - Optional track ID for consistent cache operations
  Future<bool> isTrackCached(String url, {String? trackId});

  /// Validate cached track integrity
  /// Returns cached path if valid, null if not cached/invalid
  /// [url] - The original URL of the audio
  /// [trackId] - Optional track ID for consistent cache operations
  Future<Either<Failure, String?>> validateCachedTrack(
    String url, {
    String? trackId,
  });

  /// Start background caching for future offline use
  /// Does not block current playback
  /// [url] - The original URL of the audio
  /// [trackId] - Optional track ID for consistent cache operations
  Future<void> startBackgroundCaching(String url, {String? trackId});

  /// Preload audio source for immediate playback
  /// Similar to background caching but with higher priority
  Future<Either<Failure, void>> preloadAudioSource(
    String url, {
    required String referenceId,
  });
}
