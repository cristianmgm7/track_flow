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
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/waveform/domain/usecases/generate_waveform_usecase.dart';

@lazySingleton
class ProjectTrackService {
  final AudioTrackRepository trackRepository;
  final AudioStorageRepository audioStorageRepository;
  final GenerateWaveformUseCase generateWaveformUseCase;

  ProjectTrackService(
    this.trackRepository, 
    this.audioStorageRepository,
    this.generateWaveformUseCase,
  );

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
    return result.fold((failure) => Left(failure), (_) async {
      // Persist a stable local copy in the app library for reliable playback
      try {
        await audioStorageRepository.storeAudio(
          track.id,
          File(url),
          referenceId: 'library',
          canDelete: false,
        );
        
        // Generate waveform after successful upload
        final waveformResult = await generateWaveformUseCase(
          GenerateWaveformParams(
            trackId: track.id,
            audioFilePath: url,
          ),
        );
        
        // Log waveform generation result but don't fail upload if waveform fails
        // Note: In production, consider using a proper logging framework
        waveformResult.fold(
          (failure) => {}, // Handle silently
          (waveform) => {}, // Handle silently
        );
      } catch (_) {}
      return Right(unit);
    });
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
      final deleteResult = await trackRepository.deleteTrack(
        track.id,
        project.id,
      );
      return await deleteResult.fold((failure) => Left(failure), (_) async {
        await audioStorageRepository.deleteAudioFile(trackId);
        return Right(unit);
      });
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
