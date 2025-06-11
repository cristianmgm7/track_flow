import 'dart:io';

import 'package:injectable/injectable.dart';
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

  Future<AudioTrack> addTrackToProject({
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
      throw ProjectPermissionException();
    }

    final track = AudioTrack.create(
      url: url,
      name: name,
      duration: duration,
      projectId: project.id,
      uploadedBy: requester,
    );

    await trackRepository.uploadAudioTrack(file: File(url), track: track);
    return track;
  }

  Future<void> deleteTrack({
    required Project project,
    required UserId requester,
    required AudioTrack track,
  }) async {
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!collaborator.hasPermission(ProjectPermission.deleteTrack)) {
      throw ProjectPermissionException();
    }

    await trackRepository.deleteTrack(track.id.value);
  }
}
