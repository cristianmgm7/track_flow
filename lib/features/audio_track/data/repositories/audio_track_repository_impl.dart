import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'dart:io';

@LazySingleton(as: AudioTrackRepository)
class AudioTrackRepositoryImpl implements AudioTrackRepository {
  final AudioTrackRemoteDataSource remoteDataSource;

  AudioTrackRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    return remoteDataSource
        .watchTracksByProject(projectId)
        .map(
          (tracks) => tracks.fold(
            (failure) => Left(failure),
            (tracks) => Right(tracks),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  }) async {
    try {
      await remoteDataSource.uploadAudioTrack(file: file, track: track);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(String trackId) async {
    try {
      await remoteDataSource.deleteTrack(trackId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
