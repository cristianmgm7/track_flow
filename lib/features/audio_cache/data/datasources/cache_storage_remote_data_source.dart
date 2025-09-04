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
  final Map<String, StreamSubscription<List<int>>> _downloadSubscriptions = {};
  final Map<String, IOSink> _downloadSinks = {};
  final Map<String, File> _downloadFiles = {};
  final Map<String, http.Client> _downloadClients = {};

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

        // Determine extension from Content-Type header or URL path
        final contentType = response.headers['content-type'] ?? '';
        final detectedExt =
            _extensionFromContentType(contentType) ??
            _extensionFromUrl(uri.path) ??
            '.mp3';

        // Adjust local file path to use detected extension
        final targetFile = File(
          file.path.replaceAll(RegExp(r'\.[^/.]+$'), detectedExt),
        );
        final sink = targetFile.openWrite();

        // Track resources for cancellation
        _downloadSinks[downloadId] = sink;
        _downloadFiles[downloadId] = targetFile;
        _downloadClients[downloadId] = client;

        // Listen to response stream with progress tracking
        final subscription = response.stream.listen(
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
        _downloadSubscriptions[downloadId] = subscription;

        // Wait for download completion or cancellation
        await downloadCompleter.future;
        await sink.close();

        final isCancelled = _cancelledDownloads[downloadId] == true;
        if (isCancelled) {
          // Delete partial file if cancelled
          if (await targetFile.exists()) {
            await targetFile.delete();
          }
          return Left(
            DownloadCacheFailure(
              message: 'Download was cancelled',
              trackId: downloadId,
            ),
          );
        }

        // Verify file was downloaded successfully
        if (await targetFile.exists() && await targetFile.length() > 0) {
          final completedProgress = DownloadProgress.completed(
            downloadId,
            await targetFile.length(),
          );
          onProgress(completedProgress);
          return Right(targetFile);
        } else {
          return Left(
            DownloadCacheFailure(
              message: 'Download completed but file is empty or missing',
              trackId: downloadId,
            ),
          );
        }
      } finally {
        try {
          client.close();
        } catch (_) {}
        _activeDownloads.remove(downloadId);
        _cancelledDownloads.remove(downloadId);
        try {
          await _downloadSubscriptions.remove(downloadId)?.cancel();
        } catch (_) {}
        try {
          await _downloadSinks.remove(downloadId)?.close();
        } catch (_) {}
        _downloadFiles.remove(downloadId);
        _downloadClients.remove(downloadId);
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

  String? _extensionFromContentType(String contentType) {
    final type = contentType.split(';').first.trim().toLowerCase();
    switch (type) {
      case 'audio/mpeg':
      case 'audio/mp3':
        return '.mp3';
      case 'audio/mp4':
      case 'audio/aac':
      case 'audio/x-m4a':
      case 'audio/m4a':
        return '.m4a';
      case 'audio/wav':
      case 'audio/x-wav':
        return '.wav';
      case 'audio/ogg':
      case 'application/ogg':
        return '.ogg';
      case 'audio/flac':
        return '.flac';
      default:
        return null;
    }
  }

  String? _extensionFromUrl(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    // Basic sanity check
    if (ext.length > 5) return null; // avoid query strings, etc.
    return ext;
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String downloadId) async {
    try {
      final isActive = _activeDownloads[downloadId];
      if (isActive == true) {
        // Mark as cancelled
        _cancelledDownloads[downloadId] = true;
        // Cancel subscription and close sink
        try {
          await _downloadSubscriptions.remove(downloadId)?.cancel();
        } catch (_) {}
        try {
          await _downloadSinks.remove(downloadId)?.close();
        } catch (_) {}
        try {
          _downloadClients.remove(downloadId)?.close();
        } catch (_) {}
        // Delete partial file if any
        final partial = _downloadFiles.remove(downloadId);
        if (partial != null && await partial.exists()) {
          try {
            await partial.delete();
          } catch (_) {}
        }
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
