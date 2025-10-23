import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class UploadTrackCoverArtParams {
  final AudioTrackId trackId;
  final File imageFile;

  UploadTrackCoverArtParams({
    required this.trackId,
    required this.imageFile,
  });
}

@lazySingleton
class UploadTrackCoverArtUseCase {
  final AudioTrackRepository _audioTrackRepository;
  final ImageStorageRepository _imageStorageRepository;
  final DirectoryService _directoryService;

  UploadTrackCoverArtUseCase(
    this._audioTrackRepository,
    this._imageStorageRepository,
    this._directoryService,
  );

  Future<Either<Failure, String>> call(UploadTrackCoverArtParams params) async {
    try {
      // 1. Get current track by ID
      // Note: Repository getTrackById returns AudioTrackDocument, need to get entity
      // For simplicity, we'll work with the entity through a different approach
      // In practice, you'd have a getTrackEntityById method

      // 2. Generate local file path for PERSISTENT storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPathResult = await _directoryService.getFilePath(
        DirectoryType.trackCovers,
        '${params.trackId.value}_cover_$timestamp.webp',
      );

      return await localPathResult.fold(
        (failure) async => Left(failure),
        (localPath) async {
          // 3. Copy to PERSISTENT local cache FIRST (offline-first)
          // This ensures the file survives even if the picker temp file is deleted
          final localFile = File(localPath);
          await localFile.parent.create(recursive: true);
          await params.imageFile.copy(localPath);

          // 4. Get current track and update with local path immediately
          final getTrackResult = await _audioTrackRepository.getTrackById(params.trackId);

          return await getTrackResult.fold(
            (failure) async => Left(failure),
            (currentTrack) async {
              // 5. Update track with local path immediately (makes image available offline instantly)
              final trackWithLocalPath = currentTrack.copyWith(
                coverLocalPath: localPath,
              );

              final localUpdateResult = await _audioTrackRepository.updateTrack(trackWithLocalPath);

              if (localUpdateResult.isLeft()) {
                return localUpdateResult.fold(
                  (failure) => Left(failure),
                  (_) => throw StateError('Unreachable'),
                );
              }

              // 6. Upload to Firebase Storage from the PERSISTENT local copy
              // Use localFile instead of params.imageFile to avoid temp file issues
              final storagePath = 'cover_art_tracks/${params.trackId.value}/cover_$timestamp.webp';
              final uploadResult = await _imageStorageRepository.uploadImage(
                imageFile: localFile,
                storagePath: storagePath,
                metadata: {
                  'trackId': params.trackId.value,
                  'uploadedAt': DateTime.now().toIso8601String(),
                },
                quality: 85,
              );

              return await uploadResult.fold(
                (failure) async => Left(failure),
                (downloadUrl) async {
                  // 7. Update track with remote URL
                  final updatedTrack = trackWithLocalPath.copyWith(
                    coverUrl: downloadUrl,
                  );

                  final remoteUpdateResult = await _audioTrackRepository.updateTrack(updatedTrack);

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
      return Left(ServerFailure('Failed to upload track cover art: $e'));
    }
  }
}
