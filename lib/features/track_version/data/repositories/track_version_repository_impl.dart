import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

@LazySingleton(as: TrackVersionRepository)
class TrackVersionRepositoryImpl implements TrackVersionRepository {
  final TrackVersionLocalDataSource _local;
  TrackVersionRepositoryImpl(this._local);

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
  }) {
    return _local.setActiveVersion(trackId: trackId, versionId: versionId);
  }

  @override
  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId) {
    return _local.deleteVersion(versionId);
  }
}
