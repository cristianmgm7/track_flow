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

      // 2. Generate local file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPathResult = await _directoryService.getFilePath(
        DirectoryType.trackCovers,
        '${params.trackId.value}_cover_$timestamp.webp',
      );

      return await localPathResult.fold(
        (failure) async => Left(failure),
        (localPath) async {
          // 3. Copy to local cache FIRST (offline-first)
          await params.imageFile.copy(localPath);

          // 4. Upload to Firebase Storage
          final storagePath = 'cover_art_tracks/${params.trackId.value}/cover_$timestamp.webp';
          final uploadResult = await _imageStorageRepository.uploadImage(
            imageFile: params.imageFile,
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
              // 5. Create updated track with both URLs
              // We need to get the current track first
              final getTrackResult = await _audioTrackRepository.getTrackById(params.trackId);

              return await getTrackResult.fold(
                (failure) async => Left(failure),
                (currentTrack) async {
                  // 6. Update track with both local and remote URLs
                  final updatedTrack = currentTrack.copyWith(
                    coverUrl: downloadUrl,
                    coverLocalPath: localPath,
                  );

                  final updateResult = await _audioTrackRepository.updateTrack(updatedTrack);

                  return updateResult.fold(
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
