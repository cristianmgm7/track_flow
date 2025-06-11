import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

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
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    try {
      // Logic to add the comment to the data source
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to add comment'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    String trackId,
  ) async* {
    try {
      // Logic to watch comments by track from the data source
      yield Right(<AudioComment>[]);
    } catch (e) {
      yield Left(ServerFailure('Failed to watch comments by track'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async {
    try {
      // Logic to delete the comment from the data source
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comment'));
    }
  }
}
