import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'dart:io';

@LazySingleton(as: AudioTrackRepository)
class AudioTrackRepositoryImpl implements AudioTrackRepository {
  final AudioTrackRemoteDataSource remoteDataSource;
  final AudioTrackLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AudioTrackRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id) async {
    try {
      final result = await localDataSource.getTrackById(id.value);
      return result.fold(
        (failure) => Left(failure),
        (dto) =>
            dto != null
                ? Right(dto.toDomain())
                : Left(ServerFailure('Track not found')),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    try {
      return localDataSource
          .watchTracksByProject(projectId.value)
          .map(
            (either) => either.fold(
              (failure) => Left(failure),
              (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch local tracks')));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.uploadAudioTrack(
          AudioTrackDTO.fromDomain(track),
        );
        return await result.fold((failure) => Left(failure), (trackDTO) async {
          await localDataSource.cacheTrack(trackDTO);
          return Right(unit);
        });
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ServerFailure('No network connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(
    AudioTrackId trackId,
    ProjectId projectId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTrackFromProject(
          trackId.value,
          projectId.value,
        );
        await localDataSource.deleteTrack(trackId.value);
        return Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // await localDataSource.deleteTrack(trackId); // if I want to delete local
      return Left(ServerFailure('No network connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> editTrackName({
    required AudioTrackId trackId,
    required ProjectId projectId,
    required String newName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.editTrackName(
          trackId.value,
          projectId.value,
          newName,
        );
        await localDataSource.updateTrackName(trackId.value, newName);
        return Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ServerFailure('No network connection'));
    }
  }
}
