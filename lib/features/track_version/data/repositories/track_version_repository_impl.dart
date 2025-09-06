import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: TrackVersionRepository)
class TrackVersionRepositoryImpl implements TrackVersionRepository {
  final TrackVersionLocalDataSource _local;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;

  TrackVersionRepositoryImpl(this._local, this._backgroundSyncCoordinator);

  @override
  Future<Either<Failure, TrackVersion>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
  }) async {
    final dtoEither = await _local.addVersion(
      trackId: trackId,
      file: file,
      label: label,
    );
    return dtoEither.map((dto) => dto.toDomain());
  }

  @override
  Stream<Either<Failure, List<TrackVersion>>> watchVersionsByTrack(
    AudioTrackId trackId,
  ) {
    return _local
        .watchVersionsByTrack(trackId)
        .map(
          (either) => either.map(
            (dtos) =>
                dtos.map((d) => d.toDomain()).toList()
                  ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber)),
          ),
        );
  }

  @override
  Future<Either<Failure, TrackVersion>> getActiveVersion(
    AudioTrackId trackId,
  ) async {
    final dtoEither = await _local.getActiveVersion(trackId);
    return dtoEither.map((dto) => dto.toDomain());
  }

  @override
  Future<Either<Failure, TrackVersion>> getById(TrackVersionId id) async {
    final dtoEither = await _local.getById(id);
    return dtoEither.map((dto) => dto.toDomain());
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    try {
      final result = await _local.setActiveVersion(
        trackId: trackId,
        versionId: versionId,
      );

      // Trigger upstream sync only (more efficient for local changes)
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_versions_update',
        ),
      );

      // 5. Return success only after successful queue
      return result;
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId) async {
    try {
      final result = await _local.deleteVersion(versionId);

      // Trigger upstream sync only (more efficient for local changes)
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_versions_update',
        ),
      );

      return result;
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete version: $e'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning(
        'Background sync trigger failed: $error',
        tag: 'TrackVersionRepositoryImpl',
      );
    });
  }
}
