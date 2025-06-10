import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

class DeleteAudioCommentParams {
  final AudioCommentId commentId;

  DeleteAudioCommentParams({required this.commentId});
}

@lazySingleton
class DeleteAudioCommentUseCase {
  final AudioCommentRepository repository;

  DeleteAudioCommentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(DeleteAudioCommentParams params) {
    return repository.deleteComment(params.commentId.value);
  }
}
