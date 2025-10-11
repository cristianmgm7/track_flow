import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/services/firebase_audio_upload_service.dart';
import 'package:trackflow/core/utils/file_system_utils.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart' as cache_failures;

/// Coordinates audio storage operations for audio comments
/// Bridges recording module outputs with comment storage requirements
@injectable
class AudioCommentStorageCoordinator {
  final FirebaseAudioUploadService _uploadService;
  final AudioStorageRepository _audioStorageRepository;

  AudioCommentStorageCoordinator(
    this._uploadService,
    this._audioStorageRepository,
  );

  /// Upload audio comment file to Firebase Storage
  ///
  /// Constructs appropriate storage path and uploads with metadata
  /// Path format: audio_comments/{projectId}/{versionId}/{commentId}.m4a
  Future<Either<Failure, String>> uploadCommentAudio({
    required String localPath,
    required ProjectId projectId,
    required TrackVersionId versionId,
    required AudioCommentId commentId,
  }) async {
    final file = File(localPath);

    // Check if file existsa
    if (!await file.exists()) {
      return Left(StorageFailure('Audio file not found at: $localPath'));
    }

    final storagePath = _buildStoragePath(projectId, versionId, commentId);

    final metadata = {
      'projectId': projectId.value,
      'versionId': versionId.value,
      'commentId': commentId.value,
      'type': 'audio_comment',
    };

    return await _uploadService.uploadAudioFile(
      audioFile: file,
      storagePath: storagePath,
      metadata: metadata,
    );
  }

  /// Delete audio comment file from Firebase Storage
  Future<Either<Failure, Unit>> deleteCommentAudio({
    required String storageUrl,
  }) async {
    return await _uploadService.deleteAudioFile(storageUrl: storageUrl);
  }

  /// Store recording in audio cache system
  ///
  /// Uses existing AudioStorageRepository for consistency
  /// Moves temp recording file to permanent cache location
  ///
  /// Note: We use projectId as trackId and commentId as versionId
  /// to leverage the existing cache hierarchy
  Future<Either<cache_failures.CacheFailure, String>> storeRecordingInCache({
    required String tempPath,
    required AudioTrackId trackId,  // Using projectId as trackId
    required TrackVersionId versionId,  // Using commentId as versionId
  }) async {
    final audioFile = File(tempPath);

    // Check if temp file exists
    if (!await audioFile.exists()) {
      return Left(cache_failures.StorageCacheFailure(
        message: 'Temporary recording file not found',
        type: cache_failures.StorageFailureType.fileNotFound,
      ));
    }

    // Use existing audio cache storage
    final result = await _audioStorageRepository.storeAudio(
      trackId,
      versionId,
      audioFile,
    );

    return result.fold(
      (failure) => Left(failure),
      (cachedAudio) async {
        // Delete temp file after successful cache
        await FileSystemUtils.deleteFileIfExists(tempPath);
        return Right(cachedAudio.filePath);
      },
    );
  }

  /// Build Firebase Storage path for audio comment
  String _buildStoragePath(
    ProjectId projectId,
    TrackVersionId versionId,
    AudioCommentId commentId,
  ) {
    return 'audio_comments/${projectId.value}/${versionId.value}/${commentId.value}.m4a';
  }

  /// Check if audio comment exists in local cache
  Future<Either<cache_failures.CacheFailure, bool>> isCommentAudioCached({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    return await _audioStorageRepository.audioVersionExists(trackId, versionId);
  }

  /// Get local cache path for audio comment if it exists
  Future<Either<cache_failures.CacheFailure, String>> getCachedCommentAudioPath({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    return await _audioStorageRepository.getCachedAudioPath(
      trackId,
      versionId: versionId,
    );
  }

  /// Download and cache audio comment from Firebase Storage
  /// This is used when other users want to play an audio comment
  ///
  /// Flow:
  /// 1. Check if already cached locally
  /// 2. If not, download from Firebase Storage
  /// 3. Store in local cache with proper structure
  /// 4. Return local path
  Future<Either<Failure, String>> downloadAndCacheCommentAudio({
    required String storageUrl,
    required ProjectId projectId,
    required AudioCommentId commentId,
  }) async {
    // Use projectId as trackId and commentId as versionId for cache structure
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

    // Download to temporary location first
    final tempDir = Directory.systemTemp;
    final tempPath = '${tempDir.path}/temp_comment_${commentId.value}.m4a';

    final downloadResult = await _uploadService.downloadAudioFile(
      storageUrl: storageUrl,
      localPath: tempPath,
    );

    return await downloadResult.fold(
      (failure) async => Left(failure),
      (downloadedPath) async {
        // Move to permanent cache
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
            await FileSystemUtils.deleteFileIfExists(tempPath);
            return Right(cachedAudio.filePath);
          },
        );
      },
    );
  }
}
