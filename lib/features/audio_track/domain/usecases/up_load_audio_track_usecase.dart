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
  final ProjectTrackService projectTrackService; // Permits
  final ProjectsRepository projectsRepository;
  final SessionStorage sessionStorage;
  final AudioMetadataService audioMetadataService;
  final AudioStorageRepository audioStorageRepository; // Para subir archivos
  final AddTrackVersionUseCase addTrackVersionUseCase;
  final SetActiveTrackVersionUseCase setActiveTrackVersionUseCase;
  final GetOrGenerateWaveform getOrGenerateWaveform;

  UploadAudioTrackUseCase(
    this.projectTrackService,
    this.projectsRepository,
    this.sessionStorage,
    this.audioMetadataService,
    this.audioStorageRepository,
    this.addTrackVersionUseCase,
    this.setActiveTrackVersionUseCase,
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
      if (userId == null)
        return Left(AuthenticationFailure('User not authenticated'));

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
      );

      // Si los permisos fallan, retornar error
      if (permissionCheck.isLeft()) {
        return permissionCheck.map((_) => unit);
      }

      // Extraer el track creado del resultado
      final track = permissionCheck.getOrElse(() => throw Exception());

      // 4. SUBIR ARCHIVO DE AUDIO (por ahora usamos cache local)
      final cacheResult = await audioStorageRepository.storeAudio(
        track.id,
        params.file,
        referenceId: 'upload_${track.id.value}',
        canDelete: false,
      );
      if (cacheResult.isLeft()) {
        // Rollback: eliminar track si falla el cache
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return Left(CacheFailure('Failed to cache audio file'));
      }

      // Obtener la ruta del archivo en cache para la versión
      final cachedAudio = cacheResult.getOrElse(() => throw Exception());
      final cachedFile = File(cachedAudio.filePath);

      // 5. CREAR PRIMERA VERSIÓN usando archivo del cache
      final versionResult = await addTrackVersionUseCase.call(
        AddTrackVersionParams(
          trackId: track.id,
          file: cachedFile, // Usar archivo del cache en lugar del original
          label: 'v1',
        ),
      );
      if (versionResult.isLeft()) {
        // Rollback completo
        await audioStorageRepository.deleteAudioFile(track.id);
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return versionResult.map((_) => unit);
      }
      final version = versionResult.getOrElse(() => throw Exception());

      // 6. ESTABLECER VERSIÓN ACTIVA
      final setActiveResult = await setActiveTrackVersionUseCase.call(
        SetActiveTrackVersionParams(trackId: track.id, versionId: version.id),
      );
      if (setActiveResult.isLeft()) {
        // Rollback completo
        await audioStorageRepository.deleteAudioFile(track.id);
        await projectTrackService.deleteTrack(
          project: project,
          requester: UserId.fromUniqueString(userId),
          trackId: track.id,
        );
        return setActiveResult;
      }

      // 7. GENERAR WAVEFORM (puede fallar sin afectar el éxito)
      try {
        final bytes = await params.file.readAsBytes();
        final audioSourceHash = crypto.sha1.convert(bytes).toString();

        await getOrGenerateWaveform(
          GetOrGenerateWaveformParams(
            trackId: track.id,
            versionId: version.id,
            audioFilePath: params.file.path,
            audioSourceHash: audioSourceHash,
            algorithmVersion: 1,
            targetSampleCount: null,
            forceRefresh: true,
          ),
        );
      } catch (e) {
        // Log error pero no fallar la subida
        print('Waveform generation failed: $e');
      }

      return Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure('Upload failed: $e'));
    }
  }
}
