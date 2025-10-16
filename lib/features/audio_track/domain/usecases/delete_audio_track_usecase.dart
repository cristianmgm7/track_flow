import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

// Params
class DeleteAudioTrackParams {
  final AudioTrackId trackId;
  final ProjectId projectId;

  DeleteAudioTrackParams({required this.trackId, required this.projectId});
}

@lazySingleton
class DeleteAudioTrack {
  final SessionStorage sessionStorage;
  final ProjectsRepository projectDetailRepository;
  final ProjectTrackService projectTrackService;
  final TrackVersionRepository trackVersionRepository;
  final WaveformRepository waveformRepository;
  final AudioStorageRepository audioStorageRepository;
  final AudioCommentRepository audioCommentRepository;

  DeleteAudioTrack(
    this.sessionStorage,
    this.projectDetailRepository,
    this.projectTrackService,
    this.trackVersionRepository,
    this.waveformRepository,
    this.audioStorageRepository,
    this.audioCommentRepository,
  );

  Future<Either<Failure, Unit>> call(DeleteAudioTrackParams params) async {
    try {
      // 1. OBTENER USUARIO Y PROYECTO
      final userId = await sessionStorage.getUserId();
      if (userId == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      final projectResult = await projectDetailRepository.getProjectById(
        params.projectId,
      );
      if (projectResult.isLeft()) {
        return projectResult.map((_) => unit);
      }
      final project = projectResult.getOrElse(() => throw Exception());

      // 2. OBTENER TODAS LAS VERSIONES DEL TRACK
      final versionsResult = await trackVersionRepository.getVersionsByTrack(
        params.trackId,
      );
      if (versionsResult.isLeft()) {
        return versionsResult.map((_) => unit);
      }
      final versions = versionsResult.getOrElse(() => []);

      // 3. ELIMINAR RECURSOS RELACIONADOS (comments, waveforms, versiones)
      // Orden recomendado: comments/waveforms -> versiones -> cache -> track

      // 3.0. Eliminar comentarios por track (remoto + local)
      try {
        await audioCommentRepository.deleteByTrackId(params.trackId);
      } catch (e) {
        // No es crítico si falla; continuar con la eliminación del resto
      AppLogger.warning(
        'Failed to delete comments for track ${params.trackId}: $e',
        tag: 'DELETE_AUDIO_TRACK_USECASE',
        );
      }
      for (final version in versions) {
        // 3.1. Eliminar la versión primero (maneja eliminación remota en Firebase)
        try {
          final deleteVersionResult = await trackVersionRepository
              .deleteVersion(version.id);
          if (deleteVersionResult.isLeft()) {
            AppLogger.warning(
              'Failed to delete version ${version.id}: ${deleteVersionResult.fold((l) => l.message, (r) => 'Unknown error')}',
              tag: 'DELETE_AUDIO_TRACK_USECASE',
            );
          }
        } catch (e) {
          // Log error pero continuar con otras versiones
          AppLogger.warning('Failed to delete version ${version.id}: $e', tag: 'DELETE_AUDIO_TRACK_USECASE');
        }

        // 3.2. Eliminar waveforms locales para esta versión
        // (waveforms remotas se eliminan cuando se elimina la versión)
        try {
          await waveformRepository.deleteWaveformsForVersion(
            params.trackId,
            version.id,
          );
        } catch (e) {
          // Log error pero continuar - no es crítico
          AppLogger.warning(
            'Failed to delete waveforms for version ${version.id}: $e',
            tag: 'DELETE_AUDIO_TRACK_USECASE',
          );
        }
        // 3.3. (Comentarios por versión) Opcional si se requiere limpieza fina
        // Si se implementa deleteByTrackId, esto no es necesario por versión
      }
      // 3.5. Eliminar archivos de audio en cache local (una sola vez)
      try {
        await audioStorageRepository.deleteAudioFile(params.trackId);
      } catch (e) {
        // Log error pero continuar - no es crítico
        AppLogger.warning(
          'Failed to delete cached audio for track ${params.trackId}: $e',
          tag: 'DELETE_AUDIO_TRACK_USECASE',
        );
      }

      // 4. ELIMINAR EL TRACK PRINCIPAL
      final deleteTrackResult = await projectTrackService.deleteTrack(
        project: project,
        requester: UserId.fromUniqueString(userId),
        trackId: params.trackId,
      );

      // Si la eliminación del track falla, es un error crítico
      if (deleteTrackResult.isLeft()) {
        return deleteTrackResult;
      }

      return Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure('Delete failed: $e'));
    }
  }
}
