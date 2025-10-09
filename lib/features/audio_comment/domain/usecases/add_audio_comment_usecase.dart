import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class AddAudioCommentParams {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;

  // Audio recording fields
  final String? localAudioPath;
  final Duration? audioDuration;
  final CommentType commentType;

  AddAudioCommentParams({
    required this.projectId,
    required this.versionId,
    required this.content,
    required this.timestamp,
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
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
        versionId: params.versionId,
        content: params.content,
        timestamp: params.timestamp,
        localAudioPath: params.localAudioPath,
        audioDuration: params.audioDuration,
        commentType: params.commentType,
      );
    });
  }
}
