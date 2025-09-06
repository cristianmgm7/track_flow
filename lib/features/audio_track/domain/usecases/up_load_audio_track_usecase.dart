import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:trackflow/features/waveform/domain/usecases/get_or_generate_waveform.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart';

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
  final GetOrGenerateWaveform getOrGenerateWaveform;
  final AudioStorageRepository audioStorageRepository;
  final AddTrackVersionUseCase addTrackVersionUseCase;
  final SetActiveTrackVersionUseCase setActiveTrackVersionUseCase;

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectDetailRepository,
    this.sessionStorage,
    this.audioMetadataService,
    this.getOrGenerateWaveform,
    this.audioStorageRepository,
    this.addTrackVersionUseCase,
    this.setActiveTrackVersionUseCase,
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
          // 4. Create AudioTrack first (without activeVersionId)
          final trackResult = await projectTrackService.addTrackToProject(
            project: project,
            requester: UserId.fromUniqueString(userId),
            name: params.name,
            url: params.file.path, // Temporary path, will be updated
            duration: duration,
          );

          return await trackResult.fold((f) => Left(f), (track) async {
            try {
              // 5. Create TrackVersion (v1) for this track
              final versionResult = await addTrackVersionUseCase.call(
                AddTrackVersionParams(
                  trackId: track.id,
                  file: params.file,
                  label: 'v1',
                ),
              );

              return await versionResult.fold((f) => Left(f), (version) async {
                // 6. Set version as active for the track
                final setActiveResult = await setActiveTrackVersionUseCase.call(
                  SetActiveTrackVersionParams(
                    trackId: track.id,
                    versionId: version.id,
                  ),
                );

                return await setActiveResult.fold((f) => Left(f), (_) async {
                  // 7. Generate waveform for the version
                  final cachedPathEither = await audioStorageRepository
                      .getCachedAudioPath(track.id);
                  final waveformPath = cachedPathEither.fold(
                    (_) => params.file.path,
                    (p) => p,
                  );

                  final bytes = await File(waveformPath).readAsBytes();
                  final audioSourceHash = crypto.sha1.convert(bytes).toString();
                  await getOrGenerateWaveform(
                    GetOrGenerateWaveformParams(
                      trackId: track.id,
                      audioFilePath: waveformPath,
                      audioSourceHash: audioSourceHash,
                      algorithmVersion: 1,
                      targetSampleCount: null,
                      forceRefresh: true,
                    ),
                  );

                  return const Right(unit);
                });
              });
            } catch (e) {
              return Left(
                ServerFailure('Version creation failed: ${e.toString()}'),
              );
            }
          });
        });
      });
    } catch (e) {
      return Left(ServerFailure('Upload failed: ${e.toString()}'));
    }
  }
}
