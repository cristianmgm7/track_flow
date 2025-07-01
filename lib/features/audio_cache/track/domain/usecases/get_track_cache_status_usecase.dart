import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/download_progress.dart';
import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_repository.dart';

@injectable
class GetTrackCacheStatusUseCase {
  final CacheStorageRepository _cacheStorageRepository;

  GetTrackCacheStatusUseCase(this._cacheStorageRepository);

  /// Get current cache status for a track
  Future<Either<CacheFailure, CacheStatus>> call(String trackId) async {
    try {
      final result = await _cacheStorageRepository.audioExists(trackId);
      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists ? CacheStatus.cached : CacheStatus.notCached),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get cache status: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  /// Get cached audio information
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    String trackId,
  ) async {
    try {
      return await _cacheStorageRepository.getCachedAudio(trackId);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get cached audio: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  /// Get cached audio path
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId,
  ) async {
    try {
      return await _cacheStorageRepository.getCachedAudioPath(trackId);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get cached audio path: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  /// Watch cache status changes for a track
  Stream<CacheStatus> watchCacheStatus(String trackId) {
    // For now, we'll create a simple stream that checks periodically
    // In a full implementation, this would use Isar's watch functionality
    return Stream.periodic(const Duration(seconds: 1), (_) => trackId).asyncMap(
      (id) async {
        final result = await call(id);
        return result.fold(
          (failure) => CacheStatus.notCached,
          (status) => status,
        );
      },
    ).distinct();
  }

  /// Watch download progress for a track
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    return _cacheStorageRepository.watchDownloadProgress(trackId);
  }

  /// Watch combined cache info (status + progress)
  Stream<TrackCacheInfo> watchTrackCacheInfo({required String trackId}) {
    return Rx.combineLatest2(
      watchCacheStatus(trackId),
      watchDownloadProgress(trackId),
      (CacheStatus status, DownloadProgress progress) =>
          TrackCacheInfo(trackId: trackId, status: status, progress: progress),
    );
  }
}

/// Combined cache information for a track
class TrackCacheInfo {
  const TrackCacheInfo({
    required this.trackId,
    required this.status,
    required this.progress,
  });

  final String trackId;
  final CacheStatus status;
  final DownloadProgress progress;
}
