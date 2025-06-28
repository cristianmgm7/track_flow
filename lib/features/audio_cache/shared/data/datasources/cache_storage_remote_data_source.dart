import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';

abstract class CacheStorageRemoteDataSource {
  /// Download audio file from remote storage with progress tracking
  Future<Either<CacheFailure, File>> downloadAudio({
    required String audioUrl,
    required String localFilePath,
    required Function(DownloadProgress) onProgress,
  });

  /// Cancel an active download
  Future<Either<CacheFailure, Unit>> cancelDownload(String downloadId);

  /// Get download URL for a given audio reference
  Future<Either<CacheFailure, String>> getDownloadUrl(String audioReference);

  /// Verify if remote audio exists
  Future<Either<CacheFailure, bool>> audioExists(String audioReference);

  /// Get audio metadata from remote storage
  Future<Either<CacheFailure, Map<String, dynamic>>> getAudioMetadata(String audioReference);
}

@LazySingleton(as: CacheStorageRemoteDataSource)
class CacheStorageRemoteDataSourceImpl implements CacheStorageRemoteDataSource {
  final FirebaseStorage _storage;
  
  // Track active downloads for cancellation
  final Map<String, DownloadTask> _activeDownloads = {};

  CacheStorageRemoteDataSourceImpl(this._storage);

  @override
  Future<Either<CacheFailure, File>> downloadAudio({
    required String audioUrl,
    required String localFilePath,
    required Function(DownloadProgress) onProgress,
  }) async {
    try {
      // Parse Firebase Storage URL to get reference
      final uri = Uri.parse(audioUrl);
      final pathSegments = uri.pathSegments;
      
      // Extract the file path from Firebase Storage URL
      // Expected format: /v0/b/{bucket}/o/{path}
      if (pathSegments.length < 4 || pathSegments[0] != 'v0' || pathSegments[1] != 'b') {
        return Left(
          NetworkCacheFailure(
            message: 'Invalid Firebase Storage URL format',
            statusCode: 400,
          ),
        );
      }

      // Reconstruct the storage path
      final storagePath = Uri.decodeComponent(pathSegments.skip(3).join('/'));
      final ref = _storage.ref(storagePath);
      
      final file = File(localFilePath);
      final downloadTask = ref.writeToFile(file);
      
      // Generate download ID for tracking
      final downloadId = '${DateTime.now().millisecondsSinceEpoch}_${file.path.hashCode}';
      _activeDownloads[downloadId] = downloadTask;

      // Listen to progress
      final progressSubscription = downloadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = DownloadProgress(
            trackId: downloadId,
            state: _mapTaskState(snapshot.state),
            downloadedBytes: snapshot.bytesTransferred,
            totalBytes: snapshot.totalBytes,
          );
          onProgress(progress);
        },
        onError: (error) {
          final failedProgress = DownloadProgress.failed(downloadId, error.toString());
          onProgress(failedProgress);
        },
      );

      try {
        await downloadTask;
        
        // Verify file was downloaded successfully
        if (await file.exists()) {
          final completedProgress = DownloadProgress.completed(downloadId, await file.length());
          onProgress(completedProgress);
          return Right(file);
        } else {
          return Left(
            DownloadCacheFailure(
              message: 'Download completed but file not found',
              trackId: downloadId,
            ),
          );
        }
      } finally {
        // Cleanup
        progressSubscription.cancel();
        _activeDownloads.remove(downloadId);
      }
      
    } catch (e) {
      return Left(
        NetworkCacheFailure(
          message: 'Failed to download audio: $e',
          statusCode: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String downloadId) async {
    try {
      final downloadTask = _activeDownloads[downloadId];
      if (downloadTask != null) {
        await downloadTask.cancel();
        _activeDownloads.remove(downloadId);
        return const Right(unit);
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'No active download found with ID: $downloadId',
            field: 'downloadId',
            value: downloadId,
          ),
        );
      }
    } catch (e) {
      return Left(
        NetworkCacheFailure(
          message: 'Failed to cancel download: $e',
          statusCode: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getDownloadUrl(String audioReference) async {
    try {
      final ref = _storage.ref(audioReference);
      final downloadUrl = await ref.getDownloadURL();
      return Right(downloadUrl);
    } catch (e) {
      return Left(
        NetworkCacheFailure(
          message: 'Failed to get download URL: $e',
          statusCode: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(String audioReference) async {
    try {
      final ref = _storage.ref(audioReference);
      final metadata = await ref.getMetadata();
      return Right(metadata.size != null && metadata.size! > 0);
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return const Right(false);
      }
      return Left(
        NetworkCacheFailure(
          message: 'Failed to check if audio exists: $e',
          statusCode: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, dynamic>>> getAudioMetadata(
    String audioReference,
  ) async {
    try {
      final ref = _storage.ref(audioReference);
      final metadata = await ref.getMetadata();
      
      return Right({
        'size': metadata.size,
        'contentType': metadata.contentType,
        'md5Hash': metadata.md5Hash,
        'cacheControl': metadata.cacheControl,
        'contentDisposition': metadata.contentDisposition,
        'contentEncoding': metadata.contentEncoding,
        'contentLanguage': metadata.contentLanguage,
        'customMetadata': metadata.customMetadata,
        'generation': metadata.generation,
        'metageneration': metadata.metageneration,
        'name': metadata.name,
        'fullPath': metadata.fullPath,
        'bucket': metadata.bucket,
        'timeCreated': metadata.timeCreated?.toIso8601String(),
        'updated': metadata.updated?.toIso8601String(),
      });
    } catch (e) {
      return Left(
        NetworkCacheFailure(
          message: 'Failed to get audio metadata: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Map Firebase Storage TaskState to our DownloadState
  DownloadState _mapTaskState(TaskState state) {
    switch (state) {
      case TaskState.running:
        return DownloadState.downloading;
      case TaskState.paused:
        return DownloadState.downloading; // Treat paused as downloading for now
      case TaskState.success:
        return DownloadState.completed;
      case TaskState.canceled:
        return DownloadState.cancelled;
      case TaskState.error:
        return DownloadState.failed;
    }
  }

  /// Cleanup method to cancel all active downloads
  void dispose() {
    for (final task in _activeDownloads.values) {
      task.cancel();
    }
    _activeDownloads.clear();
  }
}