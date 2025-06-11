import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

// Params
class AddAudioCommentParams {
  final AudioComment comment;

  AddAudioCommentParams({required this.comment});
}

@lazySingleton
class AddAudioCommentUseCase {
  final AudioCommentRepository repository;

  AddAudioCommentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(AddAudioCommentParams params) {
    return repository.addComment(params.comment);
  }
}
