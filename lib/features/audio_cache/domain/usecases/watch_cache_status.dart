import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart';

import '../entities/cached_audio.dart';
import '../entities/download_progress.dart';
import '../repositories/audio_storage_repository.dart';

@injectable
class WatchTrackCacheStatusUseCase {
  final AudioStorageRepository _audioStorageRepository;

  WatchTrackCacheStatusUseCase(this._audioStorageRepository);

  /// Watch cache status changes for a track
  Stream<Either<CacheFailure, CacheStatus>> call(String trackId) {
    return _audioStorageRepository
        .watchTrackCacheStatus(AudioTrackId.fromUniqueString(trackId))
        .map<Either<CacheFailure, CacheStatus>>(
          (exists) => Right<CacheFailure, CacheStatus>(
            exists ? CacheStatus.cached : CacheStatus.notCached,
          ),
        )
        .handleError(
          (e) => Left(
            StorageCacheFailure(
              message: e.toString(),
              type: StorageFailureType.diskError,
            ),
          ),
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
