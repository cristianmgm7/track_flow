import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/cache_reference.dart';
import '../../../shared/domain/entities/download_progress.dart';
import '../../../shared/domain/entities/track_cache_info.dart';
import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';

@injectable
class GetTrackCacheStatusUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  GetTrackCacheStatusUseCase(this._cacheOrchestrationService);

  /// Validate track ID and return failure if invalid
  Either<CacheFailure, Unit> _validateTrackId(String trackId) {
    if (trackId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
    return const Right(unit);
  }

  /// Handle errors consistently across all methods
  Either<CacheFailure, T> _handleError<T>(
    String operation,
    String trackId,
    dynamic error,
  ) {
    return Left(
      ValidationCacheFailure(
        message: 'Unexpected error while $operation: $error',
        field: 'cache_operation',
        value: {'trackId': trackId},
      ),
    );
  }

  Future<Either<CacheFailure, CacheStatus>> call({
    required String trackId,
  }) async {
    final validation = _validateTrackId(trackId);
    if (validation.isLeft())
      return validation.fold((f) => Left(f), (_) => throw Exception());

    try {
      return await _cacheOrchestrationService.getCacheStatus(trackId);
    } catch (e) {
      return _handleError('getting cache status', trackId, e);
    }
  }

  Future<Either<CacheFailure, String?>> getCachedAudioPath({
    required String trackId,
  }) async {
    final validation = _validateTrackId(trackId);
    if (validation.isLeft())
      return validation.fold((f) => Left(f), (_) => throw Exception());

    try {
      final result = await _cacheOrchestrationService.getCachedAudioPath(
        trackId,
      );
      return result.fold((failure) => Left(failure), (path) => Right(path));
    } catch (e) {
      return _handleError('getting cached audio path', trackId, e);
    }
  }

  Future<Either<CacheFailure, CacheReference?>> getCacheReference({
    required String trackId,
  }) async {
    final validation = _validateTrackId(trackId);
    if (validation.isLeft())
      return validation.fold((f) => Left(f), (_) => throw Exception());

    try {
      return await _cacheOrchestrationService.getCacheReference(trackId);
    } catch (e) {
      return _handleError('getting cache reference', trackId, e);
    }
  }

  /// Watch both cache status and download progress in a single stream
  /// This provides a unified view of track cache information
  Stream<TrackCacheInfo> watchTrackCacheInfo({required String trackId}) {
    final validation = _validateTrackId(trackId);
    if (validation.isLeft()) {
      return Stream.error(validation.fold((f) => f, (_) => throw Exception()));
    }

    try {
      return Rx.combineLatest2(
        _cacheOrchestrationService.watchCacheStatus(trackId),
        _cacheOrchestrationService.watchDownloadProgress(trackId),
        (CacheStatus status, DownloadProgress progress) => TrackCacheInfo(
          trackId: trackId,
          status: status,
          progress: progress,
        ),
      );
    } catch (e) {
      return Stream.error(
        _handleError(
          'watching track cache info',
          trackId,
          e,
        ).fold((f) => f, (_) => throw Exception()),
      );
    }
  }
}
