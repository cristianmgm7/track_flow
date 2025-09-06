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

  /// New: watch comments by specific track version
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByVersion(
    TrackVersionId versionId,
  );

  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);

  /// Delete all comments from local cache
  Future<Either<Failure, Unit>> deleteAllComments();
}
