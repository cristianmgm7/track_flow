import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class DeleteAudioCommentParams {
  final AudioCommentId commentId;
  final ProjectId projectId;
  final AudioTrackId trackId;

  DeleteAudioCommentParams({
    required this.commentId,
    required this.projectId,
    required this.trackId,
  });
}

@lazySingleton
class DeleteAudioCommentUseCase {
  final ProjectCommentService projectCommentService;
  final ProjectsRepository projectDetailRepository;
  final SessionStorage sessionStorage;

  DeleteAudioCommentUseCase(
    this.projectCommentService,
    this.projectDetailRepository,
    this.sessionStorage,
  );

  Future<Either<Failure, Unit>> call(DeleteAudioCommentParams params) async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      return Left(ServerFailure('User not found'));
    }
    final project = await projectDetailRepository.getProjectById(
      params.projectId,
    );
    return project.fold((failure) => Left(failure), (project) async {
      return await projectCommentService.deleteComment(
        project: project,
        requester: UserId.fromUniqueString(userId),
        commentId: params.commentId,
        trackId: params.trackId,
      );
    });
  }
}
