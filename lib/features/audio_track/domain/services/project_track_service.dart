import 'dart:io';

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

  ProjectTrackService(this.trackRepository);

  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    return trackRepository.watchTracksByProject(projectId);
  }

  Future<Either<Failure, Unit>> addTrackToProject({
    required Project project,
    required UserId requester,
    required String name,
    required String url,
    required Duration duration,
  }) async {
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!collaborator.hasPermission(ProjectPermission.addTrack)) {
      return Left(ProjectPermissionException());
    }

    final track = AudioTrack.create(
      url: url,
      name: name,
      duration: duration,
      projectId: project.id,
      uploadedBy: requester,
    );

    final result = await trackRepository.uploadAudioTrack(
      file: File(url),
      track: track,
    );
    return result.fold((failure) => Left(failure), (_) => Right(unit));
  }

  Future<Either<Failure, Unit>> deleteTrack({
    required Project project,
    required UserId requester,
    required AudioTrackId trackId,
  }) async {
    final trackResult = await trackRepository.getTrackById(trackId);
    return trackResult.fold((failure) => Left(failure), (track) async {
      final collaborator = project.collaborators.firstWhere(
        (c) => c.userId == requester,
        orElse: () => throw UserNotCollaboratorException(),
      );
      if (!collaborator.hasPermission(ProjectPermission.deleteTrack)) {
        return Left(ProjectPermissionException());
      }
      return await trackRepository.deleteTrack(track.id, project.id);
    });
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
