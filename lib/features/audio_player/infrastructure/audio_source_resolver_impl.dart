import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';
import 'dart:io';

@Injectable(as: AudioSourceResolver)
class AudioSourceResolverImpl implements AudioSourceResolver {
  final GetCachedAudioPath getCachedAudioPath;
  
  // Track background caching operations
  final Set<String> _backgroundCachingUrls = <String>{};
  
  AudioSourceResolverImpl(this.getCachedAudioPath);

  @override
  Future<Either<Failure, String>> resolveAudioSource(String originalUrl) async {
    try {
      // 1. First try cache
      final cacheResult = await validateCachedTrack(originalUrl);
      if (cacheResult.isRight()) {
        final cachedPath = cacheResult.getOrElse(() => null);
        if (cachedPath != null) {
          return Right(cachedPath);
        }
      }
      
      // 2. Fallback to streaming URL and start background caching
      await startBackgroundCaching(originalUrl);
      return Right(originalUrl);
      
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isTrackCached(String url) async {
    try {
      final cachedPath = await getCachedAudioPath(url);
      final file = File(cachedPath);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String?>> validateCachedTrack(String url) async {
    try {
      if (!await isTrackCached(url)) {
        return const Right(null);
      }
      
      final cachedPath = await getCachedAudioPath(url);
      final file = File(cachedPath);
      
      // Validate file integrity
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          // Additional integrity checks could be added here
          // e.g., checksum validation, file header validation
          return Right(cachedPath);
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> startBackgroundCaching(String url) async {
    if (_backgroundCachingUrls.contains(url)) {
      return; // Already caching
    }
    
    _backgroundCachingUrls.add(url);
    
    // Start background caching (implementation would depend on cache service)
    try {
      // This would typically trigger the cache service to download the file
      await getCachedAudioPath(url);
      // In a real implementation, this would initiate async download
    } catch (e) {
      // Handle caching errors silently to not interrupt playback
    } finally {
      _backgroundCachingUrls.remove(url);
    }
  }

  @override
  Future<CacheStatus> getCacheStatus(String url) async {
    if (_backgroundCachingUrls.contains(url)) {
      return CacheStatus.caching;
    }
    
    try {
      final isValid = await isTrackCached(url);
      if (isValid) {
        return CacheStatus.cached;
      }
      
      // Check if file exists but is corrupted
      final cachedPath = await getCachedAudioPath(url);
      final file = File(cachedPath);
      if (await file.exists()) {
        return CacheStatus.corrupted;
      }
      
      return CacheStatus.notCached;
    } catch (e) {
      return CacheStatus.notCached;
    }
  }

  @override
  Future<void> clearInvalidCache() async {
    try {
      // Implementation would scan cache directory and remove corrupted files
      // This is a placeholder for the actual implementation
    } catch (e) {
      // Handle cleanup errors
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}