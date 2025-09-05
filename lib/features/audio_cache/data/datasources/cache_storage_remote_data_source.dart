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
}

@LazySingleton(as: CacheStorageRemoteDataSource)
class CacheStorageRemoteDataSourceImpl implements CacheStorageRemoteDataSource {
  // Keep dependency to ease future enhancements; suppress unused warning
  // ignore: unused_field
  final FirebaseStorage _storage;

  // Track active downloads for cleanup
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

        // Track active download

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
          onDone: () => downloadCompleter.complete(),
          onError: (error) => downloadCompleter.completeError(error),
        );
        _downloadSubscriptions[downloadId] = subscription;

        // Wait for download completion or cancellation
        await downloadCompleter.future;
        await sink.close();

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

  /// Cleanup resources
  void dispose() {
    for (final sub in _downloadSubscriptions.values) {
      sub.cancel();
    }
    for (final sink in _downloadSinks.values) {
      sink.close();
    }
    for (final client in _downloadClients.values) {
      try {
        client.close();
      } catch (_) {}
    }
    _downloadSubscriptions.clear();
    _downloadSinks.clear();
    _downloadFiles.clear();
    _downloadClients.clear();
  }
}
