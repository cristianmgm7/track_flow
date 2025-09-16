import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

abstract class TrackVersionRepository {
  Future<Either<Failure, TrackVersion>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
    Duration? duration,
    required UserId createdBy,
  });

  Stream<Either<Failure, List<TrackVersion>>> watchVersionsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, List<TrackVersion>>> getVersionsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, TrackVersion>> getById(TrackVersionId id);

  Future<Either<Failure, TrackVersion>> getActiveVersion(AudioTrackId trackId);

  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  });

  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId);

  Future<Either<Failure, Unit>> renameVersion({
    required TrackVersionId versionId,
    required String? newLabel,
  });

  Future<Either<Failure, Unit>> clearCache();
}
