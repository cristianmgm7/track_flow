import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class UploadAudioTrackParams {
  final ProjectId projectId;
  final File file;
  final String name;

  UploadAudioTrackParams({
    required this.projectId,
    required this.file,
    required this.name,
  });
}

@lazySingleton
class UploadAudioTrackUseCase {
  final ProjectTrackService projectTrackService;
  final ProjectsRepository projectDetailRepository;
  final SessionStorage sessionStorage;
  final AudioMetadataService audioMetadataService;

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectDetailRepository,
    this.sessionStorage,
    this.audioMetadataService,
  );

  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    try {
      // 1. Extract audio metadata (duration) in domain layer
      final durationResult = await audioMetadataService.extractDuration(
        params.file,
      );

      return await durationResult.fold((failure) => Left(failure), (
        duration,
      ) async {
        // 2. Get user ID
        final userId = await sessionStorage.getUserId();
        if (userId == null) {
          return Left(ServerFailure('User not found'));
        }

        // 3. Get project details
        final project = await projectDetailRepository.getProjectById(
          params.projectId,
        );

        return await project.fold((failure) => Left(failure), (project) async {
          // 4. Add track to project with extracted duration
          final result = await projectTrackService.addTrackToProject(
            project: project,
            requester: UserId.fromUniqueString(userId),
            name: params.name,
            url: params.file.path,
            duration: duration,
          );
          return result;
        });
      });
    } catch (e) {
      return Left(ServerFailure('Upload failed: ${e.toString()}'));
    }
  }
}
