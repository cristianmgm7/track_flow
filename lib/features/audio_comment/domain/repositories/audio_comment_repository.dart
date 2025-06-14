import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentRepository {
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  );

  Future<Either<Failure, Unit>> addComment(AudioComment comment);

  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);
}
