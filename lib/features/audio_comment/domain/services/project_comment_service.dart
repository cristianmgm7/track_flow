import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class ProjectCommentService {
  final AudioCommentRepository commentRepository;

  ProjectCommentService(this.commentRepository);

  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    return commentRepository.watchCommentsByTrack(trackId.value);
  }

  Future<Either<Failure, Unit>> addComment({
    required Project project,
    required AudioTrackId trackId,
    required UserId requester,
    required String content,
  }) async {
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!collaborator.hasPermission(ProjectPermission.addComment)) {
      return Left(ProjectPermissionException());
    }

    final comment = AudioComment.create(
      projectId: project.id,
      trackId: trackId,
      createdBy: requester,
      content: content,
    );

    return await commentRepository.addComment(comment);
  }

  Future<Either<Failure, Unit>> deleteComment({
    required Project project,
    required UserId requester,
    required AudioCommentId commentId,
    required AudioTrackId trackId,
  }) async {
    final commentResult = await commentRepository.getCommentById(commentId);
    return commentResult.fold((failure) => Left(failure), (comment) async {
      final collaborator = project.collaborators.firstWhere(
        (c) => c.userId == requester,
        orElse: () => throw UserNotCollaboratorException(),
      );

      if (!collaborator.hasPermission(ProjectPermission.deleteComment)) {
        return Left(ProjectPermissionException());
      }
      // Only allow users to delete their own comments unless they have admin rights
      if (comment.createdBy != requester &&
          !collaborator.hasPermission(ProjectPermission.deleteComment)) {
        return Left(ProjectPermissionException());
      }

      return await commentRepository.deleteComment(comment.id);
    });
  }
}
