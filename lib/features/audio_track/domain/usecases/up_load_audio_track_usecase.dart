import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class UploadAudioTrackParams {
  final ProjectId projectId;
  final File file;
  final String name;
  final Duration duration;

  UploadAudioTrackParams({
    required this.projectId,
    required this.file,
    required this.name,
    required this.duration,
  });
}

@lazySingleton
class UploadAudioTrackUseCase {
  final ProjectTrackService projectTrackService;
  final ProjectDetailRepository projectDetailRepository;
  final SessionStorage sessionStorage;

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectDetailRepository,
    this.sessionStorage,
  );

  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return Left(ServerFailure('User not found'));
    }
    final project = await projectDetailRepository.getProjectById(
      params.projectId,
    );
    return project.fold((failure) => Left(failure), (project) async {
      await projectTrackService.addTrackToProject(
        project: project,
        requester: UserId.fromUniqueString(userId),
        name: params.name,
        url: params.file.path,
        duration: params.duration,
      );
      return Right(unit);
    });
  }
}
