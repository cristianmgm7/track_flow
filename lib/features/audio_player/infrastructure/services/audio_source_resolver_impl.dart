import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../audio_cache/shared/domain/repositories/cache_storage_facade_repository.dart';
import '../../domain/services/audio_source_resolver.dart';

/// Pure audio source resolver implementation
/// Integrates with cache storage repository
/// Provides cache-first audio source resolution for pure audio architecture
@Injectable(as: AudioSourceResolver)
class AudioSourceResolverImpl implements AudioSourceResolver {
  const AudioSourceResolverImpl(this._cacheStorageRepository);

  final CacheStorageFacadeRepository _cacheStorageRepository;

  @override
  Future<Either<Failure, String>> resolveAudioSource(
    String originalUrl, {
    String? trackId,
  }) async {
    try {
      // Use provided trackId for consistent cache operations
      final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(originalUrl);

      // 1. Always check cache first (offline-first principle)
      final cacheResult = await validateCachedTrack(
        originalUrl,
        trackId: effectiveTrackId,
      );
      if (cacheResult.isRight()) {
        final cachedPath = cacheResult.getOrElse(() => null);
        if (cachedPath != null) {
          return Right(cachedPath);
        }
      }

      // 2. Start background caching for future use
      await startBackgroundCaching(originalUrl, trackId: effectiveTrackId);

      // 3. Return original URL for streaming
      return Right(originalUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isTrackCached(String url, {String? trackId}) async {
    try {
      final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(url);
      final existsResult = await _cacheStorageRepository.audioExists(
        effectiveTrackId,
      );

      return existsResult.fold((failure) => false, (exists) => exists);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String?>> validateCachedTrack(
    String url, {
    String? trackId,
  }) async {
    try {
      final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(url);
      final pathResult = await _cacheStorageRepository.getCachedAudioPath(
        effectiveTrackId,
      );

      return pathResult.fold(
        (failure) => const Right(null),
        (cachedPath) => Right(cachedPath),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> startBackgroundCaching(String url, {String? trackId}) async {
    try {
      final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(url);

      // Use cache storage repository for background caching
      await _cacheStorageRepository.downloadAndStoreAudio(
        effectiveTrackId,
        url,
      );
    } catch (e) {
      // Handle caching errors silently to not interrupt playback
    }
  }

  @override
  Future<Either<Failure, void>> preloadAudioSource(
    String url, {
    required String referenceId,
  }) async {
    try {
      final trackId = _extractTrackIdFromUrl(url);

      // Use cache storage repository for preloading
      final result = await _cacheStorageRepository.downloadAndStoreAudio(
        trackId,
        url,
      );

      return result.fold(
        (failure) => Left(CacheFailure('Preload failed: ${failure.message}')),
        (cachedAudio) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure('Preload error: $e'));
    }
  }

  /// Extract track ID from URL for cache operations
  /// This is a simplified approach - may need refinement based on URL structure
  String _extractTrackIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.last.split('.').first;
    } catch (e) {
      // Fallback: use hash of URL if parsing fails
      return url.hashCode.toString();
    }
  }
}

/// Cache-specific failure for pure audio architecture
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Server-specific failure for pure audio architecture
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Offline-specific failure for pure audio architecture
class OfflineFailure extends Failure {
  const OfflineFailure(super.message);
}
