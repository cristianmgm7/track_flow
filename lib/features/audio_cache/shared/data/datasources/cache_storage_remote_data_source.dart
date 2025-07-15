import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

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
  Future<Either<CacheFailure, Map<String, dynamic>>> getAudioMetadata(
    String audioReference,
  );
}

@LazySingleton(as: CacheStorageRemoteDataSource)
class CacheStorageRemoteDataSourceImpl implements CacheStorageRemoteDataSource {
  final FirebaseStorage _storage;

  // Track active downloads for cancellation
  final Map<String, bool> _activeDownloads = {};
  final Map<String, bool> _cancelledDownloads = {};

  CacheStorageRemoteDataSourceImpl(this._storage);

  @override
  Future<Either<CacheFailure, File>> downloadAudio({
    required String audioUrl,
    required String localFilePath,
    required Function(DownloadProgress) onProgress,
  }) async {
    try {
      // Validate the URL
      final uri = Uri.tryParse(audioUrl);
      if (uri == null || !uri.hasScheme) {
        return Left(
          NetworkCacheFailure(
            message: 'Invalid audio URL format: $audioUrl',
            statusCode: 400,
          ),
        );
      }

      // Generate download ID for tracking
      final downloadId =
          '${DateTime.now().millisecondsSinceEpoch}_${uri.pathSegments.last.hashCode}';

      final file = File(localFilePath);

      // Ensure parent directory exists
      await file.parent.create(recursive: true);

      // Create HTTP client for download
      final client = http.Client();

      try {
        // Start the request
        final request = http.Request('GET', uri);
        final response = await client.send(request);

        if (response.statusCode != 200) {
          return Left(
            NetworkCacheFailure(
              message: 'Failed to download audio: HTTP ${response.statusCode}',
              statusCode: response.statusCode,
            ),
          );
        }

        final totalBytes = response.contentLength ?? 0;
        int downloadedBytes = 0;

        // Track this download for cancellation
        final downloadCompleter = Completer<void>();

        // Store cancellation info
        _activeDownloads[downloadId] = true;

        // Open file for writing
        final sink = file.openWrite();

        // Listen to response stream with progress tracking
        response.stream.listen(
          (List<int> chunk) {
            // Check if download was cancelled
            if (_cancelledDownloads[downloadId] == true) return;

            downloadedBytes += chunk.length;
            sink.add(chunk);

            // Report progress
            final progress = DownloadProgress(
              trackId: downloadId,
              state: DownloadState.downloading,
              downloadedBytes: downloadedBytes,
              totalBytes: totalBytes,
            );
            onProgress(progress);
          },
          onDone: () {
            if (_cancelledDownloads[downloadId] != true) {
              downloadCompleter.complete();
            }
          },
          onError: (error) {
            if (_cancelledDownloads[downloadId] != true) {
              downloadCompleter.completeError(error);
            }
          },
        );

        // Wait for download completion or cancellation
        await downloadCompleter.future;
        await sink.close();

        final isCancelled = _cancelledDownloads[downloadId] == true;
        if (isCancelled) {
          // Delete partial file if cancelled
          if (await file.exists()) {
            await file.delete();
          }
          return Left(
            DownloadCacheFailure(
              message: 'Download was cancelled',
              trackId: downloadId,
            ),
          );
        }

        // Verify file was downloaded successfully
        if (await file.exists() && await file.length() > 0) {
          final completedProgress = DownloadProgress.completed(
            downloadId,
            await file.length(),
          );
          onProgress(completedProgress);
          return Right(file);
        } else {
          return Left(
            DownloadCacheFailure(
              message: 'Download completed but file is empty or missing',
              trackId: downloadId,
            ),
          );
        }
      } finally {
        client.close();
        _activeDownloads.remove(downloadId);
        _cancelledDownloads.remove(downloadId);
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
      final isActive = _activeDownloads[downloadId];
      if (isActive == true) {
        // Mark as cancelled
        _cancelledDownloads[downloadId] = true;
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
  Future<Either<CacheFailure, String>> getDownloadUrl(
    String audioReference,
  ) async {
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

  /// Cleanup method to cancel all active downloads
  void dispose() {
    // Mark all active downloads as cancelled
    for (final downloadId in _activeDownloads.keys) {
      _cancelledDownloads[downloadId] = true;
    }
    _activeDownloads.clear();
    _cancelledDownloads.clear();
  }
}
