import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/audio_comment.dart';

abstract class AudioCommentRepository {
  Future<Either<Failure, Unit>> addComment(AudioComment comment);

  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    String trackId,
  );

  Future<Either<Failure, Unit>> deleteComment(String commentId);
}
