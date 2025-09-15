import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

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
  final ProjectTrackService projectTrackService; // Permits
  final ProjectsRepository projectsRepository;
  final SessionStorage sessionStorage;
  final AddTrackVersionUseCase addTrackVersionUseCase;
  final AudioTrackRepository
  audioTrackRepository; // Para actualizar activeVersionId

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectsRepository,
    this.sessionStorage,
    this.addTrackVersionUseCase,
    this.audioTrackRepository,
  );

  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    try {
      // 1. OBTENER USUARIO Y PROYECTO
      final userId = await sessionStorage.getUserId();
      if (userId == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      final projectResult = await projectsRepository.getProjectById(
        params.projectId,
      );
      if (projectResult.isLeft()) {
        return projectResult.map((_) => unit);
      }
      final project = projectResult.getOrElse(() => throw Exception());

      // 2. VERIFICAR PERMISOS Y CREAR TRACK (usando ProjectTrackService)
      final permissionCheck = await projectTrackService.addTrackToProject(
        project: project,
        requester: UserId.fromUniqueString(userId),
        name: params.name,
        url: '', // temporary empty url
        activeVersionId: null, // initially null, will be updated later
      );

      // if permissions fail, return error
      if (permissionCheck.isLeft()) {
        return permissionCheck.map((_) => unit);
      }

      // extract the created track from the result
      final track = permissionCheck.getOrElse(() => throw Exception());

      // 3. CREATE FIRST VERSION (before caching)
      final addVersionResult = await addTrackVersionUseCase.call(
        AddTrackVersionParams(
          trackId: track.id,
          file: params.file,
          label: 'Initial version',
        ),
      );

      if (addVersionResult.isLeft()) {
        // Rollback: delete track if version creation fails
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return addVersionResult.map((_) => unit);
      }

      final version = addVersionResult.getOrElse(() => throw Exception());

      // 4. UPDATE TRACK WITH ACTIVE VERSION
      final updateActiveVersionResult = await audioTrackRepository
          .setActiveVersion(trackId: track.id, versionId: version.id);
      if (updateActiveVersionResult.isLeft()) {
        // Rollback: delete track if active version update fails
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return Left(
          updateActiveVersionResult.fold(
            (l) => l,
            (_) => UnexpectedFailure('Failed to set active version'),
          ),
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure('Upload failed: $e'));
    }
  }
}
