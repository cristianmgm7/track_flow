import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class ProjectTrackService {
  final AudioTrackRepository trackRepository;
  // This service focuses ONLY on permissions and project-level track operations

  ProjectTrackService(this.trackRepository);

  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    return trackRepository.watchTracksByProject(projectId);
  }

  Future<Either<Failure, AudioTrack>> addTrackToProject({
    required Project project,
    required UserId requester,
    required String name,
    required String url,
    Duration? duration,
    TrackVersionId? activeVersionId,
  }) async {
    // 1. Verificar permisos del usuario en el proyecto
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!collaborator.hasPermission(ProjectPermission.addTrack)) {
      return Left(ProjectPermissionException());
    }

    // 2. Crear track (solo metadata, sin archivos)
    final track = AudioTrack.create(
      name: name,
      duration: duration ?? Duration.zero,
      projectId: project.id,
      uploadedBy: requester,
      activeVersionId: activeVersionId,
    );

    // 3. Persistir track en base de datos (solo metadata)
    final result = await trackRepository.createTrack(track);
    return result.fold(
      (failure) => Left(failure),
      (createdTrack) => Right(createdTrack),
    );
  }

  Future<Either<Failure, Unit>> deleteTrack({
    required Project project,
    required UserId requester,
    required AudioTrackId trackId,
  }) async {
    // 1. Verificar permisos del usuario
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!collaborator.hasPermission(ProjectPermission.deleteTrack)) {
      return Left(ProjectPermissionException());
    }

    // 2. Eliminar track (solo metadata, archivos se manejan en versiones)
    final deleteResult = await trackRepository.deleteTrack(trackId, project.id);

    return deleteResult.fold((failure) => Left(failure), (_) => Right(unit));
  }

  Future<Either<Failure, Unit>> editTrackName({
    required AudioTrackId trackId,
    required ProjectId projectId,
    required String newName,
  }) async {
    return await trackRepository.editTrackName(
      trackId: trackId,
      projectId: projectId,
      newName: newName,
    );
  }
}
