import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/audio/domain/audio_file_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';

/// Use case to get or download audio comment for playback
///
/// This handles the caching logic:
/// 1. Check if audio is already cached locally
/// 2. If not, download from Firebase Storage and cache it
/// 3. Return local file path for playback
@injectable
class GetCachedAudioCommentUseCase {
  final AudioStorageRepository _audioStorageRepository;
  final AudioFileRepository _audioFileRepository;

  GetCachedAudioCommentUseCase(
    this._audioStorageRepository,
    this._audioFileRepository,
  );

  /// Get local path for audio comment (download if necessary)
  ///
  /// [projectId] - Project containing the comment
  /// [commentId] - Audio comment ID
  /// [storageUrl] - Firebase Storage URL (needed if not cached)
  ///
  /// Returns local file path on success
  Future<Either<Failure, String>> call({
    required ProjectId projectId,
    required AudioCommentId commentId,
    required String storageUrl,
  }) async {
    // Use projectId as trackId for cache structure
    final trackId = AudioTrackId.fromUniqueString(projectId.value);
    final versionId = TrackVersionId.fromUniqueString(commentId.value);

    // Check if already cached
    final cacheCheck = await _audioStorageRepository.audioVersionExists(
      trackId,
      versionId,
    );

    final alreadyCached = cacheCheck.fold(
      (_) => false,
      (exists) => exists,
    );

    if (alreadyCached) {
      // Return cached path
      return await _audioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      ).then(
        (either) => either.fold(
          (failure) => Left(StorageFailure(failure.message)),
          (path) => Right(path),
        ),
      );
    }

    // Download and cache
    // 1. Download to temporary location first
    final tempDir = Directory.systemTemp;
    final tempPath = '${tempDir.path}/temp_comment_${commentId.value}.m4a';

    final downloadResult = await _audioFileRepository.downloadAudioFile(
      storageUrl: storageUrl,
      localPath: tempPath,
      trackId: projectId.value,
      versionId: versionId.value,
      onProgress: (progress) {
        // Progress updates could be emitted to a stream if needed
      },
    );

    return await downloadResult.fold(
      (failure) async => Left(failure),
      (downloadedPath) async {
        // 2. Move to permanent cache
        final tempFile = File(downloadedPath);
        final cacheResult = await _audioStorageRepository.storeAudio(
          trackId,
          versionId,
          tempFile,
        );

        return cacheResult.fold(
          (failure) => Left(StorageFailure(failure.message)),
          (cachedAudio) async {
            // Clean up temp file
            try {
              await tempFile.delete();
            } catch (_) {
              // Ignore cleanup errors
            }
            return Right(cachedAudio.filePath);
          },
        );
      },
    );
  }
}
