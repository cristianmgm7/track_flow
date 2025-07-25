import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class AddAudioCommentParams {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final String content;
  final Duration timestamp;

  AddAudioCommentParams({
    required this.projectId,
    required this.trackId,
    required this.content,
    required this.timestamp,
  });
}

@lazySingleton
class AddAudioCommentUseCase {
  final ProjectCommentService projectCommentService;
  final ProjectsRepository projectDetailRepository;
  final SessionStorage sessionStorage;

  AddAudioCommentUseCase(
    this.projectCommentService,
    this.projectDetailRepository,
    this.sessionStorage,
  );

  Future<Either<Failure, Unit>> call(AddAudioCommentParams params) async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      return Left(ServerFailure('User not found'));
    }
    final project = await projectDetailRepository.getProjectById(
      params.projectId,
    );
    return project.fold((failure) => Left(failure), (project) async {
      return await projectCommentService.addComment(
        project: project,
        requester: UserId.fromUniqueString(userId),
        trackId: params.trackId,
        content: params.content,
        timestamp: params.timestamp,
      );
    });
  }
}
