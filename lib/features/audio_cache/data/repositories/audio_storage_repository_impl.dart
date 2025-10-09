import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/audio_storage_repository.dart';
import '../datasources/cache_storage_local_data_source.dart';
import '../models/cached_audio_document_unified.dart';

@LazySingleton(as: AudioStorageRepository)
class AudioStorageRepositoryImpl implements AudioStorageRepository {
  final CacheStorageLocalDataSource _localDataSource;

  AudioStorageRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<CacheFailure, CachedAudio>> storeAudio(
    AudioTrackId trackId,
    TrackVersionId versionId,
    File audioFile,
  ) async {
    try {
      // Create file path using trackId/versionId structure
      final cacheDir = await _getCacheDirectory();
      final trackDir = Directory('${cacheDir.path}/${trackId.value}');
      if (!await trackDir.exists()) {
        await trackDir.create(recursive: true);
      }

      final ext = _extractExtension(audioFile.path) ?? '.mp3';
      final filename = '${versionId.value}$ext';
      final finalPath = '${trackDir.path}/$filename';

      final destinationFile = await audioFile.copy(finalPath);

      // Verify file and calculate checksum (streaming)
      final fileSize = await destinationFile.length();
      final checksumDigest = await sha1.bind(destinationFile.openRead()).first;
      final checksum = checksumDigest.toString();

      // Create unified document with both file and metadata information
      // Guardar ruta relativa para persistencia entre sesiones
      final relativePath = _getRelativePath(destinationFile.path);

      final unifiedDocument =
          CachedAudioDocumentUnified()
            ..trackId = trackId.value
            ..versionId = versionId.value
            ..relativePath =
                relativePath // Guardar ruta relativa
            ..fileSizeBytes = fileSize
            ..cachedAt = DateTime.now()
            ..checksum = checksum
            ..quality = AudioQuality.medium
            ..status = CacheStatus.cached
            ..lastAccessed = DateTime.now()
            ..downloadAttempts = 0
            ..lastDownloadAttempt = null
            ..failureReason = null
            ..originalUrl = '';

      // Store unified document in local database
      final storeResult = await _localDataSource.storeUnifiedCachedAudio(
        unifiedDocument,
      );

      return storeResult.fold((failure) => Left(failure), (unifiedDoc) async {
        // Convert back to CachedAudio for return
        final cachedAudio = await unifiedDoc.toCachedAudio();
        return Right(cachedAudio);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to store audio: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  String? _extractExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    if (ext.length > 5) return null;
    return ext;
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/trackflow/audio');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Convert absolute path to relative path for persistence
  String _getRelativePath(String absolutePath) {
    try {
      // Extraer la parte relativa después de '/trackflow/audio/'
      final trackflowIndex = absolutePath.indexOf('/trackflow/audio/');
      if (trackflowIndex != -1) {
        return absolutePath.substring(
          trackflowIndex + '/trackflow/audio/'.length,
        );
      }
      // Fallback: devolver el path original si no se puede convertir
      return absolutePath;
    } catch (e) {
      return absolutePath;
    }
  }

  /// Validate and clean corrupted cache entries
  /// This should be called at app startup
  @override
  Future<Either<CacheFailure, int>> validateAndCleanCache() async {
    try {
      final docs = await _localDataSource.watchAllCachedAudios().first;
      int cleanedCount = 0;

      for (final doc in docs) {
        try {
          // Check if file exists at expected location
          final exists = await doc.validateFileExists();

          if (!exists) {
            // File doesn't exist, remove specific version entry
            await _localDataSource.deleteAudioFile(
              doc.trackId,
              versionId: doc.versionId,
            );
            cleanedCount++;
          }
        } catch (e) {
          // Error validating file, remove specific version entry
          await _localDataSource.deleteAudioFile(
            doc.trackId,
            versionId: doc.versionId,
          );
          cleanedCount++;
        }
      }

      return Right(cleanedCount);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate and clean cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
  }) async {
    try {
      // Try to get from database first
      final result = await _localDataSource.getCachedAudioPath(
        trackId.value,
        versionId: versionId?.value,
      );

      return result.fold((failure) {
        // Fallback to file system search for legacy compatibility
        return _getCachedAudioPathFromFileSystem(trackId, versionId);
      }, (path) => Right(path));
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached audio path: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Either<CacheFailure, String>> _getCachedAudioPathFromFileSystem(
    AudioTrackId trackId,
    TrackVersionId? versionId,
  ) async {
    try {
      // Generate expected file path based on new structure
      final cacheDir = await _getCacheDirectory();
      final trackDir = Directory('${cacheDir.path}/${trackId.value}');

      if (!await trackDir.exists()) {
        return Left(
          StorageCacheFailure(
            message: 'Track cache directory not found: ${trackId.value}',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      // Try different extensions
      final extensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'];

      if (versionId != null) {
        // Look for specific version file
        for (final ext in extensions) {
          final filePath = '${trackDir.path}/${versionId.value}$ext';
          final file = File(filePath);
          if (await file.exists()) {
            return Right(filePath);
          }
        }
      } else {
        // Look for any cached file in track directory (legacy compatibility)
        try {
          final files = await trackDir.list().toList();
          for (final file in files) {
            if (file is File) {
              final fileName = file.path.split('/').last;
              // Check if it's an audio file
              for (final ext in extensions) {
                if (fileName.endsWith(ext)) {
                  return Right(file.path);
                }
              }
            }
          }
        } catch (e) {
          // Directory might not exist or have permission issues
          return Left(
            StorageCacheFailure(
              message: 'Failed to access cache directory: $e',
              type: StorageFailureType.diskError,
            ),
          );
        }
      }

      // File not found
      final versionMsg =
          versionId != null
              ? 'version ${versionId.value}'
              : 'track ${trackId.value}';
      return Left(
        StorageCacheFailure(
          message: 'Cached audio file not found for $versionMsg',
          type: StorageFailureType.fileNotFound,
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached audio path: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(AudioTrackId trackId) async {
    return await _localDataSource.audioExists(trackId.value);
  }

  // New method to check if specific version exists
  @override
  Future<Either<CacheFailure, bool>> audioVersionExists(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    return await _localDataSource.audioExists(
      trackId.value,
      versionId: versionId.value,
    );
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    AudioTrackId trackId,
  ) async {
    final result = await _localDataSource.getCachedAudio(trackId.value);
    return result.fold(
      (failure) => Left(failure),
      (doc) async => Right(doc != null ? await doc.toCachedAudio() : null),
    );
  }

  // New method to get cached audio by version
  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudioByVersion(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    final result = await _localDataSource.getCachedAudio(
      trackId.value,
      versionId: versionId.value,
    );
    return result.fold(
      (failure) => Left(failure),
      (doc) async => Right(doc != null ? await doc.toCachedAudio() : null),
    );
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(
    AudioTrackId trackId,
  ) async {
    return await _localDataSource.deleteAudioFile(trackId.value);
  }

  // New method to delete specific version
  @override
  Future<Either<CacheFailure, Unit>> deleteAudioVersionFile(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    return await _localDataSource.deleteAudioFile(
      trackId.value,
      versionId: versionId.value,
    );
  }

  // Removed batch operations to simplify repository

  @override
  Stream<int> watchStorageUsage() {
    return _localDataSource.watchAllCachedAudios().map((docs) {
      int totalSize = 0;
      for (final d in docs) {
        totalSize += d.fileSizeBytes;
      }
      return totalSize;
    });
  }

  @override
  Stream<List<CachedAudio>> watchAllCachedAudios() {
    return _localDataSource.watchAllCachedAudios().asyncMap((docs) async {
      final cachedAudios = <CachedAudio>[];
      for (final doc in docs) {
        final cachedAudio = await doc.toCachedAudio();
        cachedAudios.add(cachedAudio);
      }
      return cachedAudios;
    });
  }

  @override
  Future<Either<CacheFailure, int>> getStorageUsage() async {
    try {
      final docs = await _localDataSource.watchAllCachedAudios().first;
      int totalSize = 0;
      for (final d in docs) {
        totalSize += d.fileSizeBytes;
      }
      return Right(totalSize);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get storage usage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorage() async {
    try {
      // Get system available storage
      // This is a simplified implementation - in production you'd want to
      // check actual disk space available
      const maxCacheSize = 1024 * 1024 * 1024; // 1GB max cache size

      final usageResult = await getStorageUsage();
      return usageResult.fold(
        (failure) => Left(failure),
        (currentUsage) => Right(maxCacheSize - currentUsage),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get available storage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<bool> watchTrackCacheStatus(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
  }) {
    return _localDataSource.watchTrackCacheStatus(
      trackId.value,
      versionId: versionId?.value,
    );
  }

  // No longer needed; extension is handled at download time
}
