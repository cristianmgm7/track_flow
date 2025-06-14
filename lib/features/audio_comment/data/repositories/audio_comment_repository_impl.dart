import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

@LazySingleton(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentRemoteDataSource _remoteDataSource;

  AudioCommentRepositoryImpl({
    required AudioCommentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  ) async {
    return _remoteDataSource.getCommentById(commentId);
  }

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    return _remoteDataSource.addComment(comment);
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    return _remoteDataSource
        .watchCommentsByTrack(trackId)
        .map(
          (comments) => comments.fold(
            (failure) => Left(failure),
            (comments) => Right(comments),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
    try {
      // Logic to delete the comment from the data source
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comment'));
    }
  }
}
