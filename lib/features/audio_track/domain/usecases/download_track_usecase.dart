import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

/// Downloads a track version with user-friendly filename for sharing
@injectable
class DownloadTrackUseCase {
  final AudioStorageRepository _audioStorageRepository;
  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;
  final ProjectsRepository _projectsRepository;
  final SessionService _sessionService;

  DownloadTrackUseCase({
    required AudioStorageRepository audioStorageRepository,
    required AudioTrackRepository audioTrackRepository,
    required TrackVersionRepository trackVersionRepository,
    required ProjectsRepository projectsRepository,
    required SessionService sessionService,
  })  : _audioStorageRepository = audioStorageRepository,
        _audioTrackRepository = audioTrackRepository,
        _trackVersionRepository = trackVersionRepository,
        _projectsRepository = projectsRepository,
        _sessionService = sessionService;

  /// Downloads track version and returns path to temporary file with friendly name
  ///
  /// Returns:
  /// - Right(filePath): Path to temporary file ready for sharing
  /// - Left(Failure): Permission error, cache error, or track not found
  Future<Either<Failure, String>> call({
    required String trackId,
    String? versionId, // If null, uses active version
  }) async {
    try {
      // 1. Get current user
      final userIdResult = await _sessionService.getCurrentUserId();
      final userId = userIdResult.fold(
        (failure) => null,
        (id) => id,
      );
      
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // 2. Get track
      final trackResult = await _audioTrackRepository.getTrackById(
        AudioTrackId.fromUniqueString(trackId),
      );
      if (trackResult.isLeft()) {
        return left(const ServerFailure('Track not found'));
      }
      final track = trackResult.getOrElse(() => throw Exception('Unreachable'));

      // 3. Get project and check permission
      final projectResult = await _projectsRepository.getProjectById(
        track.projectId,
      );
      if (projectResult.isLeft()) {
        return left(const ServerFailure('Project not found'));
      }
      final project = projectResult.getOrElse(() => throw Exception('Unreachable'));

      final currentUserCollaborator = project.collaborators.firstWhere(
        (c) => c.userId.value == userId,
        orElse: () => throw const UserNotCollaboratorException(),
      );

      if (!currentUserCollaborator.hasPermission(ProjectPermission.downloadTrack)) {
        return left(const ProjectPermissionException());
      }

      // 4. Determine version to download
      final targetVersionId = versionId ?? track.activeVersionId?.value;
      if (targetVersionId == null) {
        return left(const ServerFailure('No version available for download'));
      }

      // 5. Get cached audio path
      final cachedPathResult = await _audioStorageRepository.getCachedAudioPath(
        AudioTrackId.fromUniqueString(trackId),
        versionId: TrackVersionId.fromUniqueString(targetVersionId),
      );

      if (cachedPathResult.isLeft()) {
        return left(const ServerFailure('Track not cached yet'));
      }
      final cachedPath = cachedPathResult.getOrElse(() => throw Exception('Unreachable'));

      // 6. Get version info for filename
      final versionResult = await _trackVersionRepository.getById(
        TrackVersionId.fromUniqueString(targetVersionId),
      );
      if (versionResult.isLeft()) {
        return left(const ServerFailure('Version not found'));
      }
      final version = versionResult.getOrElse(() => throw Exception('Unreachable'));

      // 7. Generate user-friendly filename
      final extension = _getExtensionFromPath(cachedPath);
      final sanitizedName = _sanitizeFilename(track.name);
      final friendlyFilename = '${sanitizedName}_v${version.versionNumber}$extension';

      // 8. Create temporary copy with friendly name
      final cachedFile = File(cachedPath);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$friendlyFilename');

      // Remove old temp file if exists
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Copy to temp with friendly name
      await cachedFile.copy(tempFile.path);

      return right(tempFile.path);
    } on ProjectPermissionException catch (_) {
      return left(const ProjectPermissionException());
    } on UserNotCollaboratorException catch (_) {
      return left(const UserNotCollaboratorException());
    } catch (e) {
      return left(ServerFailure('Download failed: $e'));
    }
  }

  /// Extract file extension from path
  String _getExtensionFromPath(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '.mp3';
    return path.substring(lastDot).toLowerCase();
  }

  /// Sanitize filename for filesystem compatibility
  /// Replaces spaces with underscores, removes special characters
  String _sanitizeFilename(String name) {
    // Replace spaces with underscores
    var sanitized = name.replaceAll(' ', '_');

    // Remove or replace special characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

    // Limit length to 100 characters
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized;
  }
}

