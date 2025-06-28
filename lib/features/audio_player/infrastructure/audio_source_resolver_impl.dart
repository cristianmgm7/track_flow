import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/models/audio_source_enum.dart';
import 'package:trackflow/features/audio_player/domain/models/connectivity_models.dart.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart';
import 'package:trackflow/features/audio_player/domain/services/offline_mode_service.dart';
import 'dart:io';

@Injectable(as: AudioSourceResolver)
class AudioSourceResolverImpl implements AudioSourceResolver {
  final CacheOrchestrationService cacheOrchestrationService;
  final OfflineModeService offlineModeService;

  // Track background caching operations
  final Set<String> _backgroundCachingUrls = <String>{};

  AudioSourceResolverImpl(
    this.cacheOrchestrationService,
    this.offlineModeService,
  );

  @override
  Future<Either<Failure, String>> resolveAudioSource(String originalUrl) async {
    try {
      final offlineMode = await offlineModeService.getOfflineMode();
      final isOfflineOnly = await offlineModeService.isOfflineOnlyModeEnabled();
      final networkQuality = await offlineModeService.getNetworkQuality();

      // 1. Always check cache first (offline-first principle)
      final cacheResult = await validateCachedTrack(originalUrl);
      if (cacheResult.isRight()) {
        final cachedPath = cacheResult.getOrElse(() => null);
        if (cachedPath != null) {
          return Right(cachedPath);
        }
      }

      // 2. If offline-only mode is enabled, reject streaming
      if (isOfflineOnly || networkQuality == NetworkQuality.offline) {
        return Left(OfflineFailure('Track not available offline'));
      }

      // 3. Apply offline mode strategy
      switch (offlineMode) {
        case OfflineMode.offlineOnly:
          return Left(OfflineFailure('Offline-only mode: Track not cached'));

        case OfflineMode.offlineFirst:
          // Try to start background caching, but allow streaming
          if (_shouldAllowStreaming(networkQuality)) {
            await startBackgroundCaching(originalUrl);
            return Right(originalUrl);
          } else {
            return Left(
              NetworkFailure('Network quality insufficient for streaming'),
            );
          }

        case OfflineMode.onlineFirst:
          // Prefer streaming if available
          if (_shouldAllowStreaming(networkQuality)) {
            // Start background caching for future offline use
            await startBackgroundCaching(originalUrl);
            return Right(originalUrl);
          } else {
            return Left(NetworkFailure('Network unavailable for streaming'));
          }

        case OfflineMode.auto:
          // Intelligent decision based on network quality
          return _handleAutoMode(originalUrl, networkQuality);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> _handleAutoMode(
    String originalUrl,
    NetworkQuality networkQuality,
  ) async {
    switch (networkQuality) {
      case NetworkQuality.excellent:
      case NetworkQuality.good:
        // Good connection: stream and cache in background
        await startBackgroundCaching(originalUrl);
        return Right(originalUrl);

      case NetworkQuality.limited:
        // Limited connection: check bandwidth preference
        final bandwidthPreference =
            await offlineModeService.getBandwidthPreference();
        if (bandwidthPreference == BandwidthPreference.unlimited ||
            bandwidthPreference == BandwidthPreference.wifi) {
          await startBackgroundCaching(originalUrl);
          return Right(originalUrl);
        } else {
          return Left(
            NetworkFailure('Bandwidth restrictions prevent streaming'),
          );
        }

      case NetworkQuality.poor:
        // Poor connection: prefer cache-only
        return Left(NetworkFailure('Network quality too poor for streaming'));

      case NetworkQuality.offline:
        return Left(OfflineFailure('No network connection available'));
    }
  }

  bool _shouldAllowStreaming(NetworkQuality networkQuality) {
    switch (networkQuality) {
      case NetworkQuality.excellent:
      case NetworkQuality.good:
        return true;
      case NetworkQuality.limited:
        return true; // Let bandwidth preference handle restriction
      case NetworkQuality.poor:
      case NetworkQuality.offline:
        return false;
    }
  }

  @override
  Future<bool> isTrackCached(String url) async {
    try {
      // For now, use URL as trackId (may need to be refined based on your URL structure)
      final trackId = _extractTrackIdFromUrl(url);
      final pathResult = await cacheOrchestrationService.getCachedAudioPath(trackId);
      
      return pathResult.fold(
        (failure) => false,
        (cachedPath) async {
          final file = File(cachedPath);
          return await file.exists() && await file.length() > 0;
        },
      );
    } catch (e) {
      return false;
    }
  }
  
  // Helper method to extract trackId from URL
  String _extractTrackIdFromUrl(String url) {
    // This is a simplified approach - you may need to adjust based on your URL structure
    return Uri.parse(url).pathSegments.last.split('.').first;
  }

  @override
  Future<Either<Failure, String?>> validateCachedTrack(String url) async {
    try {
      if (!await isTrackCached(url)) {
        return const Right(null);
      }

      final trackId = _extractTrackIdFromUrl(url);
      final pathResult = await cacheOrchestrationService.getCachedAudioPath(trackId);
      final cachedPath = pathResult.getOrElse(() => throw Exception('Cache path not found'));
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

    // Check if network operation is allowed
    final shouldAllowOperation = await _shouldAllowNetworkOperation(url);
    if (!shouldAllowOperation) {
      return;
    }

    _backgroundCachingUrls.add(url);

    // Start background caching using the new orchestration service
    try {
      final trackId = _extractTrackIdFromUrl(url);
      // This triggers caching via the orchestration service
      await cacheOrchestrationService.cacheAudio(trackId, url, 'background');
    } catch (e) {
      // Handle caching errors silently to not interrupt playback
    } finally {
      _backgroundCachingUrls.remove(url);
    }
  }

  Future<bool> _shouldAllowNetworkOperation(String url) async {
    final networkQuality = await offlineModeService.getNetworkQuality();
    final bandwidthPreference =
        await offlineModeService.getBandwidthPreference();
    final isOfflineOnly = await offlineModeService.isOfflineOnlyModeEnabled();

    // Block if offline-only mode
    if (isOfflineOnly) return false;

    // Block if offline
    if (networkQuality == NetworkQuality.offline) return false;

    // Check bandwidth restrictions
    switch (bandwidthPreference) {
      case BandwidthPreference.unlimited:
        return true;
      case BandwidthPreference.wifi:
        return offlineModeService.currentConnectivity ==
            ConnectivityStatus.online;
      case BandwidthPreference.limited:
        return networkQuality == NetworkQuality.excellent ||
            networkQuality == NetworkQuality.good;
      case BandwidthPreference.emergency:
        return false; // No background operations in emergency mode
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
      try {
        final trackId = _extractTrackIdFromUrl(url);
        final pathResult = await cacheOrchestrationService.getCachedAudioPath(trackId);
        final cachedPath = pathResult.getOrElse(() => '');
        if (cachedPath.isNotEmpty) {
          final file = File(cachedPath);
          if (await file.exists()) {
            return CacheStatus.corrupted;
          }
        }
      } catch (e) {
        // Ignore cache path errors
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
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
