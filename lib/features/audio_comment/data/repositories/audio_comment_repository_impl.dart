import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

@LazySingleton(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AudioCommentRepositoryImpl({
    required AudioCommentRemoteDataSource remoteDataSource,
    required AudioCommentLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  ) async {
    final comments = await _localDataSource.getCachedCommentsByTrack(
      commentId.value,
    );
    return Right(comments.first.toDomain());
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    try {
      return _localDataSource
          .watchCommentsByTrack(trackId.value)
          .map((dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()));
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to watch local comments')),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    if (await _networkInfo.isConnected) {
      final remoteResult = await _remoteDataSource.addComment(comment);
      return await remoteResult.fold((failure) => Left(failure), (_) async {
        await _localDataSource.cacheComment(
          AudioCommentDTO.fromDomain(comment),
        );
        return Right(unit);
      });
    } else {
      await _localDataSource.cacheComment(AudioCommentDTO.fromDomain(comment));
      return Right(unit);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
    if (await _networkInfo.isConnected) {
      final remoteResult = await _remoteDataSource.deleteComment(commentId);
      return await remoteResult.fold((failure) => Left(failure), (_) async {
        await _localDataSource.deleteCachedComment(commentId.value);
        return Right(unit);
      });
    } else {
      await _localDataSource.deleteCachedComment(commentId.value);
      return Right(unit);
    }
  }
}
