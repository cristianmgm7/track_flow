import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

// Params
class WatchCommentsByTrackParams {
  final AudioTrackId trackId;

  WatchCommentsByTrackParams({required this.trackId});
}

class WatchCommentsByTrackUseCase {
  final AudioCommentRepository repository;

  WatchCommentsByTrackUseCase(this.repository);

  Stream<Either<Failure, List<AudioComment>>> call(
    WatchCommentsByTrackParams params,
  ) {
    return repository.watchCommentsByTrack(params.trackId.value);
  }
}
