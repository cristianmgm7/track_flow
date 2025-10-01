import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';

@LazySingleton()
class WaveformIncrementalSyncService
    implements IncrementalSyncService<dynamic> {
  final TrackVersionLocalDataSource _versionLocalDataSource;
  final WaveformLocalDataSource _waveformLocalDataSource;
  final WaveformRemoteDataSource _waveformRemoteDataSource;

  WaveformIncrementalSyncService(
    this._versionLocalDataSource,
    this._waveformLocalDataSource,
    this._waveformRemoteDataSource,
  );
  @override
  Future<Either<Failure, List<dynamic>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    // Waveforms are derived from track versions; no standalone modifiedSince.
    // We return empty and drive actual sync work in performIncrementalSync.
    return const Right([]);
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<dynamic>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'WAVEFORMS',
        'Starting incremental sync (derived from track versions)',
        syncKey: userId,
      );

      // 1) Get current local track versions (active and known)
      final versionsResult = await _versionLocalDataSource.getAllVersions();
      final versions = versionsResult.getOrElse(() => <TrackVersionDTO>[]);
      final versionIds =
          versions.map((v) => TrackVersionId.fromUniqueString(v.id)).toList();

      // 2) Ensure local waveforms exist for each version; fetch remote canonical if missing
      int downloads = 0;
      for (final v in versions) {
        final versionId = TrackVersionId.fromUniqueString(v.id);
        final local = await _waveformLocalDataSource.getWaveformByVersionId(
          versionId,
        );
        if (local == null) {
          final remote = await _waveformRemoteDataSource
              .fetchCanonicalForVersion(
                trackId: v.trackId,
                versionId: versionId,
              );
          if (remote != null) {
            await _waveformLocalDataSource.saveWaveform(remote);
            downloads++;
          }
        }
      }

      // 3) Delete local waveforms for versions no longer present
      // Note: WaveformLocalDataSource does not expose list-all; we rely on deletions
      // being triggered by version deletions elsewhere. As a safety, if needed,
      // implement a list-all and diff here in the future.

      final result = IncrementalSyncResult(
        modifiedItems: const [],
        deletedItemIds: const [],
        serverTimestamp:
            downloads == 0 ? lastSyncTime.toUtc() : DateTime.now().toUtc(),
        totalProcessed: downloads,
      );

      AppLogger.sync(
        'WAVEFORMS',
        'Incremental sync completed: downloaded $downloads canonical waveforms',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Waveform incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<dynamic>>> performFullSync(
    String userId,
  ) async {
    return performIncrementalSync(
      DateTime.fromMillisecondsSinceEpoch(0),
      userId,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    return Right({
      'userId': userId,
      'totalWaveforms': 0,
      'syncStrategy': 'placeholder',
      'lastSync': DateTime.now().toIso8601String(),
    });
  }
}
