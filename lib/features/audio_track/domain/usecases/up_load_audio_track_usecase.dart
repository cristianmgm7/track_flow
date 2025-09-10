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
  final AudioMetadataService audioMetadataService;
  final AudioStorageRepository audioStorageRepository; // Para subir archivos
  final AddTrackVersionUseCase addTrackVersionUseCase;
  final AudioTrackRepository
  audioTrackRepository; // Para actualizar activeVersionId
  final GetOrGenerateWaveform getOrGenerateWaveform;

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectsRepository,
    this.sessionStorage,
    this.audioMetadataService,
    this.audioStorageRepository,
    this.addTrackVersionUseCase,
    this.audioTrackRepository,
    this.getOrGenerateWaveform,
  );

  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    try {
      // 1. EXTRAER METADATA DEL ARCHIVO
      final durationResult = await audioMetadataService.extractDuration(
        params.file,
      );
      if (durationResult.isLeft()) {
        return durationResult.map((_) => unit);
      }
      final duration = durationResult.getOrElse(() => Duration.zero);

      // 2. OBTENER USUARIO Y PROYECTO
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

      // 3. VERIFICAR PERMISOS Y CREAR TRACK (usando ProjectTrackService)
      final permissionCheck = await projectTrackService.addTrackToProject(
        project: project,
        requester: UserId.fromUniqueString(userId),
        name: params.name,
        url: '', // Temporalmente vacío
        duration: duration,
        activeVersionId: null, // Inicialmente null, se actualizará después
      );

      // Si los permisos fallan, retornar error
      if (permissionCheck.isLeft()) {
        return permissionCheck.map((_) => unit);
      }

      // Extraer el track creado del resultado
      final track = permissionCheck.getOrElse(() => throw Exception());

      // 4. CREAR PRIMERA VERSIÓN (antes de cachear)
      final addVersionResult = await addTrackVersionUseCase(
        AddTrackVersionParams(
          trackId: track.id,
          file: params.file,
          label: 'Initial version',
          duration: duration,
        ),
      );

      if (addVersionResult.isLeft()) {
        // Rollback: eliminar track si falla la versión
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return addVersionResult.map((_) => unit);
      }

      final version = addVersionResult.getOrElse(() => throw Exception());

      // 5. ACTUALIZAR TRACK CON LA VERSIÓN ACTIVA
      final updateActiveVersionResult = await audioTrackRepository
          .setActiveVersion(trackId: track.id, versionId: version.id);
      if (updateActiveVersionResult.isLeft()) {
        // Rollback: eliminar track si falla actualizar versión activa
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

      // 6. GENERAR WAVEFORM usando archivo original (maneja cache internamente)
      try {
        final bytes = await params.file.readAsBytes();
        final audioSourceHash = crypto.sha1.convert(bytes).toString();

        await getOrGenerateWaveform(
          GetOrGenerateWaveformParams(
            versionId: version.id,
            audioFilePath: params.file.path,
            audioSourceHash: audioSourceHash,
            algorithmVersion: 1,
            targetSampleCount: null,
            forceRefresh: true,
          ),
        );
      } catch (e) {
        // Waveform generation is best-effort, don't fail the entire operation
      }

      return Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure('Upload failed: $e'));
    }
  }
}
