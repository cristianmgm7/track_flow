import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart';

// Params
class WatchCommentsByTrackParams {
  final AudioTrackId trackId;

  WatchCommentsByTrackParams({required this.trackId});
}

@lazySingleton
class WatchCommentsByTrackUseCase {
  final ProjectCommentService projectCommentService;

  WatchCommentsByTrackUseCase(this.projectCommentService);

  Stream<Either<Failure, List<AudioComment>>> call(
    WatchCommentsByTrackParams params,
  ) {
    return projectCommentService.watchCommentsByTrack(params.trackId);
  }
}
