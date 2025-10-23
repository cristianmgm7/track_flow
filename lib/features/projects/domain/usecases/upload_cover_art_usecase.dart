import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class UploadCoverArtParams {
  final ProjectId projectId;
  final File imageFile;

  UploadCoverArtParams({
    required this.projectId,
    required this.imageFile,
  });
}

@lazySingleton
class UploadCoverArtUseCase {
  final ProjectsRepository _projectsRepository;
  final ImageStorageRepository _imageStorageRepository;
  final DirectoryService _directoryService;

  UploadCoverArtUseCase(
    this._projectsRepository,
    this._imageStorageRepository,
    this._directoryService,
  );

  Future<Either<Failure, String>> call(UploadCoverArtParams params) async {
    try {
      // 1. Get current project
      final projectResult = await _projectsRepository.getProjectById(params.projectId);

      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          // 2. Generate local file path for PERSISTENT storage
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final localPathResult = await _directoryService.getFilePath(
            DirectoryType.projectCovers,
            '${params.projectId.value}_cover_$timestamp.webp',
          );

          return await localPathResult.fold(
            (failure) async => Left(failure),
            (localPath) async {
              // 3. Copy to PERSISTENT local cache FIRST (offline-first)
              // This ensures the file survives even if the picker temp file is deleted
              final localFile = File(localPath);
              await localFile.parent.create(recursive: true);
              await params.imageFile.copy(localPath);

              // 4. Update project with local path immediately
              // This makes the image available offline instantly
              final projectWithLocalPath = project.copyWith(
                coverLocalPath: localPath,
              );
              final localUpdateResult = await _projectsRepository.updateProject(
                projectWithLocalPath,
              );

              if (localUpdateResult.isLeft()) {
                return localUpdateResult.fold(
                  (failure) => Left(failure),
                  (_) => throw StateError('Unreachable'),
                );
              }

              // 5. Upload to Firebase Storage from the PERSISTENT local copy
              // Use localFile instead of params.imageFile to avoid temp file issues
              final storagePath = 'cover_art_projects/${params.projectId.value}/cover_$timestamp.webp';
              final uploadResult = await _imageStorageRepository.uploadImage(
                imageFile: localFile,
                storagePath: storagePath,
                metadata: {
                  'projectId': params.projectId.value,
                  'uploadedAt': DateTime.now().toIso8601String(),
                },
                quality: 85,
              );

              return await uploadResult.fold(
                (failure) async => Left(failure),
                (downloadUrl) async {
                  // 6. Update project with remote URL
                  final updatedProject = projectWithLocalPath.copyWith(
                    coverUrl: downloadUrl,
                  );
                  final remoteUpdateResult = await _projectsRepository.updateProject(
                    updatedProject,
                  );

                  return remoteUpdateResult.fold(
                    (failure) => Left(failure),
                    (_) => Right(downloadUrl),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to upload cover art: $e'));
    }
  }
}
