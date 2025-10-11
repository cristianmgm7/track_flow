import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/audio/domain/audio_file_repository.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/utils/audio_format_utils.dart';
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart';
import 'package:trackflow/features/audio_cache/data/models/cached_audio_document_unified.dart';
import 'package:trackflow/features/audio_cache/domain/entities/cached_audio.dart';
import 'package:trackflow/features/audio_cache/domain/entities/download_progress.dart';

@LazySingleton(as: AudioFileRepository)
class UnifiedAudioService implements AudioFileRepository {
  final FirebaseStorage _storage;
  final http.Client _httpClient;
  final DirectoryService _directoryService;
  final CacheStorageLocalDataSource _localDataSource;

  UnifiedAudioService(
    this._storage,
    this._directoryService,
    this._localDataSource, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<Either<Failure, String>> uploadAudioFile({
    required File audioFile,
    required String storagePath,
    Map<String, String>? metadata,
    void Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // Extract file extension
      final fileExtension = AudioFormatUtils.getFileExtension(audioFile.path);

      // Create storage reference
      final ref = _storage.ref().child(storagePath);

      // Configure upload task
      final uploadTask = ref.putFile(
        audioFile,
        SettableMetadata(
          contentType: AudioFormatUtils.getContentType(fileExtension),
          customMetadata: metadata,
        ),
      );

      // Track progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = DownloadProgress(
            trackId: metadata?['trackId'] ?? 'unknown',
            state: DownloadState.downloading,
            downloadedBytes: snapshot.bytesTransferred,
            totalBytes: snapshot.totalBytes,
          );
          onProgress(progress);
        });
      }

      // Execute upload
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Notify completion
      if (onProgress != null) {
        onProgress(DownloadProgress.completed(
          metadata?['trackId'] ?? 'unknown',
          snapshot.totalBytes,
        ));
      }

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ServerFailure('Upload failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadAudioFile({
    required String storageUrl,
    required String localPath,
    String? trackId,
    String? versionId,
    void Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // Check cache first if trackId provided
      if (trackId != null) {
        final cachedPathResult = await getCachedAudioPath(
          trackId: trackId,
          versionId: versionId,
        );

        final cachedPath = cachedPathResult.fold(
          (_) => null,
          (path) => path,
        );

        if (cachedPath != null) {
          // File is cached, return immediately
          if (onProgress != null) {
            final file = File(cachedPath);
            final size = await file.length();
            onProgress(DownloadProgress.completed(trackId, size));
          }
          return Right(cachedPath);
        }
      }

      // Not cached, download from remote
      final downloadId = trackId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Ensure parent directory exists
      final file = File(localPath);
      await file.parent.create(recursive: true);

      // Parse URL
      final uri = Uri.tryParse(storageUrl);
      if (uri == null) {
        return Left(NetworkFailure('Invalid storage URL: $storageUrl'));
      }

      // Send HTTP request
      final request = http.Request('GET', uri);
      final response = await _httpClient.send(request);

      // Validate response
      if (response.statusCode != 200) {
        return Left(NetworkFailure(
          'Download failed with status ${response.statusCode}',
        ));
      }

      // Get total bytes
      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      // Notify download started
      if (onProgress != null) {
        onProgress(DownloadProgress(
          trackId: downloadId,
          state: DownloadState.downloading,
          downloadedBytes: 0,
          totalBytes: totalBytes,
        ));
      }

      // Stream to file
      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        // Report progress
        if (onProgress != null) {
          onProgress(DownloadProgress(
            trackId: downloadId,
            state: DownloadState.downloading,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
          ));
        }
      }

      await sink.close();

      // Verify file exists
      if (!await file.exists()) {
        return Left(StorageFailure('Download completed but file not found'));
      }

      // Cache metadata if trackId provided
      if (trackId != null && versionId != null) {
        await _cacheDownloadedFile(
          trackId: trackId,
          versionId: versionId,
          localPath: localPath,
          originalUrl: storageUrl,
        );
      }

      // Notify completion
      if (onProgress != null) {
        final fileSize = await file.length();
        onProgress(DownloadProgress.completed(downloadId, fileSize));
      }

      return Right(localPath);
    } on FirebaseException catch (e) {
      if (onProgress != null) {
        onProgress(DownloadProgress.failed(
          trackId ?? 'unknown',
          e.message ?? 'Download failed',
        ));
      }
      return Left(ServerFailure(e.message ?? 'Download failed'));
    } catch (e) {
      if (onProgress != null) {
        onProgress(DownloadProgress.failed(
          trackId ?? 'unknown',
          e.toString(),
        ));
      }
      return Left(ServerFailure('Download failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAudioFile({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Delete failed'));
    } catch (e) {
      return Left(ServerFailure('Delete failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> fileExists({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.getMetadata();
      return const Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const Right(false);
      }
      return Left(ServerFailure(e.message ?? 'Existence check failed'));
    } catch (e) {
      return Left(ServerFailure('Existence check failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedAudioPath({
    required String trackId,
    String? versionId,
  }) async {
    try {
      final result = await _localDataSource.getCachedAudioPath(
        trackId,
        versionId: versionId,
      );

      return await result.fold(
        (failure) async => Right(null), // Not cached is not an error
        (relativePath) async {
          final absPathResult = await _directoryService.getAbsolutePath(
            relativePath,
            DirectoryType.audioCache,
          );
          return absPathResult.fold(
            (_) => Right(null),
            (absolutePath) => Right(absolutePath),
          );
        },
      );
    } catch (e) {
      return Right(null); // Treat errors as not cached
    }
  }

  @override
  Future<Either<Failure, bool>> isAudioCached({
    required String trackId,
    String? versionId,
  }) async {
    try {
      // First check DB presence
      final dbResult = await _localDataSource.audioExists(
        trackId,
        versionId: versionId,
      );

      return await dbResult.fold(
        (failure) async => Right(false), // Treat cache failures as not cached
        (present) async {
          if (!present) return Right(false);
          // Resolve absolute path and confirm file exists
          final cachedPathResult = await getCachedAudioPath(
            trackId: trackId,
            versionId: versionId,
          );
          return cachedPathResult.fold(
            (_) async => Right(false),
            (absolutePath) async {
              if (absolutePath == null) return Right(false);
              final file = File(absolutePath);
              return Right(await file.exists());
            },
          );
        },
      );
    } catch (e) {
      return Right(false); // Treat errors as not cached
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache({
    required String trackId,
    String? versionId,
  }) async {
    try {
      await _localDataSource.deleteAudioFile(trackId, versionId: versionId);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to clear cache: $e'));
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }

  /// Private helper: Cache downloaded file metadata
  Future<void> _cacheDownloadedFile({
    required String trackId,
    required String versionId,
    required String localPath,
    required String originalUrl,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return;

      // Get file info
      final fileSize = await file.length();

      // Get relative path
      final relativePath = _directoryService.getRelativePath(
        localPath,
        DirectoryType.audioCache,
      );

      // Create document
      final document = CachedAudioDocumentUnified()
        ..trackId = trackId
        ..versionId = versionId
        ..relativePath = relativePath
        ..fileSizeBytes = fileSize
        ..cachedAt = DateTime.now()
        ..lastAccessed = DateTime.now()
        ..checksum = '' // Will be calculated async
        ..quality = AudioQuality.medium
        ..status = CacheStatus.cached
        ..downloadAttempts = 0
        ..originalUrl = originalUrl;

      // Store in database
      await _localDataSource.storeUnifiedCachedAudio(document);
    } catch (e) {
      // Log but don't fail the download
      AppLogger.debug('Failed to cache metadata: $e');
    }
  }
}
