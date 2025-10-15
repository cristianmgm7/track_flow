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

  /// Watch recent comments across all accessible projects.
  /// Returns comments ordered by createdAt descending (most recent first).
  /// Limited to `limit` items for dashboard preview.
  Stream<Either<Failure, List<AudioComment>>> watchRecentComments({
    required UserId userId,
    required int limit,
  });

  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);

  /// Delete all comments from local cache
  Future<Either<Failure, Unit>> deleteAllComments();

  /// Delete all comments belonging to a track (by iterating its versions)
  Future<Either<Failure, Unit>> deleteByTrackId(AudioTrackId trackId);

  /// Delete all comments for a specific track version
  Future<Either<Failure, Unit>> deleteCommentsByVersion(
    TrackVersionId versionId,
  );
}
