import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../audio_cache/shared/domain/repositories/audio_storage_repository.dart';
import '../../../audio_cache/shared/domain/repositories/audio_download_repository.dart';
import '../../domain/services/audio_source_resolver.dart';
import '../../../../../core/entities/unique_id.dart';

/// Pure audio source resolver implementation
/// Integrates with specialized cache repositories
/// Provides cache-first audio source resolution for pure audio architecture
@Injectable(as: AudioSourceResolver)
class AudioSourceResolverImpl implements AudioSourceResolver {
  const AudioSourceResolverImpl(
    this._audioStorageRepository,
    this._audioDownloadRepository,
  );

  final AudioStorageRepository _audioStorageRepository;
  final AudioDownloadRepository _audioDownloadRepository;

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
      final audioTrackId = AudioTrackId.fromUniqueString(effectiveTrackId);
      final existsResult = await _audioStorageRepository.audioExists(
        audioTrackId,
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
      final audioTrackId = AudioTrackId.fromUniqueString(effectiveTrackId);
      final pathResult = await _audioStorageRepository.getCachedAudioPath(
        audioTrackId,
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

      // Use audio download repository for background caching
      final audioTrackId = AudioTrackId.fromUniqueString(effectiveTrackId);
      await _audioDownloadRepository.downloadAudio(
        audioTrackId,
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

      // Use audio download repository for preloading
      final audioTrackId = AudioTrackId.fromUniqueString(trackId);
      final result = await _audioDownloadRepository.downloadAudio(
        audioTrackId,
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
