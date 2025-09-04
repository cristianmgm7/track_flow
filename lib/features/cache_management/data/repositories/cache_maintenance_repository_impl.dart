import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/data/models/cached_audio_document_unified.dart';

import '../../../audio_cache/domain/entities/cache_validation_result.dart';
import '../../../audio_cache/domain/entities/cached_audio.dart';
import '../../../audio_cache/domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_maintenance_repository.dart';
import '../datasources/cache_management_local_data_source.dart';

@LazySingleton(as: CacheMaintenanceRepository)
class CacheMaintenanceRepositoryImpl implements CacheMaintenanceRepository {
  final CacheManagementLocalDataSource _localDataSource;
  static const String _cacheSubDirectory = 'audio_cache';

  CacheMaintenanceRepositoryImpl({
    required CacheManagementLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<CacheFailure, CacheValidationResult>>
  validateCacheConsistency() async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        int totalFiles = audios.length;
        int validFiles = 0;
        int corruptedFiles = 0;
        int orphanedFiles = 0;
        int missingMetadata = 0;
        int inconsistentSizes = 0;
        final List<String> issues = [];

        for (final audio in audios) {
          try {
            final file = File(audio.filePath);

            if (!await file.exists()) {
              orphanedFiles++;
              issues.add('File missing: ${audio.filePath}');
              continue;
            }

            final actualSize = await file.length();
            if (actualSize != audio.fileSizeBytes) {
              inconsistentSizes++;
              issues.add(
                'Size mismatch for ${audio.trackId}: expected ${audio.fileSizeBytes}, got $actualSize',
              );
              continue;
            }

            final integrityResult = await _localDataSource.verifyFileIntegrity(
              audio.trackId,
              audio.checksum,
            );
            integrityResult.fold(
              (failure) {
                corruptedFiles++;
                issues.add('Integrity check failed for ${audio.trackId}');
              },
              (isValid) {
                if (isValid) {
                  validFiles++;
                } else {
                  corruptedFiles++;
                  issues.add('File corrupted: ${audio.trackId}');
                }
              },
            );
          } catch (e) {
            issues.add('Error validating ${audio.trackId}: $e');
          }
        }

        return Right(
          CacheValidationResult(
            totalFiles: totalFiles,
            validFiles: validFiles,
            corruptedFiles: corruptedFiles,
            orphanedFiles: orphanedFiles,
            missingMetadata: missingMetadata,
            inconsistentSizes: inconsistentSizes,
            issues: issues,
          ),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate cache consistency: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> validateCacheEntry(
    AudioTrackId trackId,
  ) async {
    try {
      final audioResult = await _localDataSource.getCachedAudio(trackId.value);
      return await audioResult.fold((failure) => Left(failure), (audio) async {
        if (audio == null) {
          return const Right(false);
        }

        final file = File(audio.filePath);
        if (!await file.exists()) {
          return const Right(false);
        }

        final actualSize = await file.length();
        if (actualSize != audio.fileSizeBytes) {
          return const Right(false);
        }

        final integrityResult = await _localDataSource.verifyFileIntegrity(
          audio.trackId,
          audio.checksum,
        );
        return integrityResult.fold(
          (failure) => const Right(false),
          (isValid) => Right(isValid),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate cache entry: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> validateCacheMetadata() async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();
      return audiosResult.fold((failure) => Left(failure), (audios) {
        // Check that all metadata entries have required fields
        for (final audio in audios) {
          if (audio.trackId.isEmpty ||
              audio.filePath.isEmpty ||
              audio.checksum.isEmpty ||
              audio.fileSizeBytes <= 0) {
            return const Right(false);
          }
        }
        return const Right(true);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate cache metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> cleanupOrphanedFiles() async {
    try {
      int cleanedFiles = 0;
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return const Right(0);
      }

      final files = cacheDir.listSync().whereType<File>();
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        final validFilePaths = audios.map((audio) => audio.filePath).toSet();

        for (final file in files) {
          if (!validFilePaths.contains(file.path)) {
            // This file doesn't have corresponding metadata - it's orphaned
            try {
              await file.delete();
              cleanedFiles++;
            } catch (e) {
              // Continue with other files if one fails to delete
            }
          }
        }

        return Right(cleanedFiles);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup orphaned files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> cleanupInvalidMetadata() async {
    try {
      int cleanedEntries = 0;
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        for (final audio in audios) {
          final file = File(audio.filePath);
          if (!await file.exists()) {
            // Metadata exists but file doesn't - remove metadata
            await _localDataSource.deleteAudioFile(audio.trackId);
            cleanedEntries++;
          }
        }

        return Right(cleanedEntries);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup invalid metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles() async {
    try {
      int cleanedFiles = 0;
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return const Right(0);
      }

      final files = cacheDir.listSync().whereType<File>();

      for (final file in files) {
        // Check for temporary file extensions
        if (file.path.endsWith('.tmp') ||
            file.path.endsWith('.part') ||
            file.path.endsWith('.download') ||
            file.path.contains('temp_')) {
          try {
            await file.delete();
            cleanedFiles++;
          } catch (e) {
            // Continue with other files
          }
        }
      }

      return Right(cleanedFiles);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup temporary files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> cleanupOldEntries({
    Duration? maxAge,
    int? maxEntries,
  }) async {
    try {
      int cleanedEntries = 0;
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        final now = DateTime.now();
        final ageLimit = maxAge ?? const Duration(days: 30);

        // Sort by cache date (oldest first)
        final sortedAudios = List<CachedAudio>.from(audios)
          ..sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

        // Clean up by age
        if (maxAge != null) {
          for (final audio in sortedAudios) {
            if (now.difference(audio.cachedAt) > ageLimit) {
              await _localDataSource.deleteAudioFile(audio.trackId);
              cleanedEntries++;
            }
          }
        }

        // Clean up by count (keep only the newest maxEntries)
        if (maxEntries != null && sortedAudios.length > maxEntries) {
          final entriesToRemove = sortedAudios.length - maxEntries;
          for (int i = 0; i < entriesToRemove; i++) {
            await _localDataSource.deleteAudioFile(sortedAudios[i].trackId);
            cleanedEntries++;
          }
        }

        return Right(cleanedEntries);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup old entries: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> rebuildCacheIndex() async {
    try {
      // Rebuild cache index by scanning files and updating database
      int rebuiltEntries = 0;

      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return const Right(0);
      }

      final files = cacheDir.listSync().whereType<File>();

      for (final file in files) {
        try {
          // Skip temporary files
          if (file.path.endsWith('.tmp') ||
              file.path.endsWith('.part') ||
              file.path.endsWith('.download')) {
            continue;
          }

          // Extract trackId from filename (assuming specific naming convention)
          final filename = file.path.split('/').last;
          if (filename.contains('_')) {
            final trackId = filename.split('_').first;

            // Check if this file has corresponding database entry
            final existsResult = await _localDataSource.audioExists(trackId);
            final exists = existsResult.fold(
              (failure) => false,
              (exists) => exists,
            );

            if (!exists) {
              // File exists but no database entry - create one
              final fileSize = await file.length();
              final bytes = await file.readAsBytes();
              final checksum = sha1.convert(bytes).toString();

              final cachedAudio = CachedAudio(
                trackId: trackId,
                filePath: file.path,
                fileSizeBytes: fileSize,
                cachedAt: DateTime.now(),
                checksum: checksum,
                quality: AudioQuality.medium,
                status: CacheStatus.cached,
              );

              await _localDataSource.storeCachedAudio(
                CachedAudioDocumentUnified.fromCachedAudio(cachedAudio),
              );
              rebuiltEntries++;
            }
          }
        } catch (e) {
          // Skip problematic files
          continue;
        }
      }

      return Right(rebuiltEntries);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to rebuild cache index: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> rebuildCacheMetadata() async {
    try {
      // This is essentially the same as rebuildCacheIndex for this implementation
      return await rebuildCacheIndex();
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to rebuild cache metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> scanAndUpdateCacheRegistry() async {
    try {
      return await rebuildCacheIndex();
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to scan and update cache registry: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> migrateCacheStructure() async {
    try {
      // Basic cache migration implementation
      // In a real app, this would handle version migrations, file structure changes, etc.

      int migratedFiles = 0;
      final cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        final files = cacheDir.listSync().whereType<File>();

        for (final file in files) {
          // Example: rename old cache files to new format
          if (file.path.contains('old_cache_')) {
            final newName = file.path.replaceAll('old_cache_', 'cache_');
            await file.rename(newName);
            migratedFiles++;
          }
        }
      }

      return Right(migratedFiles);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to migrate cache structure: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> migrateCacheMetadata() async {
    try {
      // This would handle metadata format migrations
      // For now, just return 0 as no migration is needed
      return const Right(0);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to migrate cache metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> isMigrationNeeded() async {
    try {
      // Check if any old format files exist
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return const Right(false);
      }

      final files = cacheDir.listSync().whereType<File>();

      for (final file in files) {
        if (file.path.contains('old_cache_')) {
          return const Right(true);
        }
      }

      return const Right(false);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check if migration is needed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> optimizeCacheLayout() async {
    try {
      // This could reorganize files for better performance
      // For now, just return success
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to optimize cache layout: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> defragmentCacheStorage() async {
    try {
      // This could reorganize storage for better performance
      // For now, just return success
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to defragment cache storage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> compressCacheMetadata() async {
    try {
      // This could compress metadata for space savings
      // For now, just return success
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to compress cache metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, dynamic>>>
  getCacheHealthStats() async {
    try {
      final validationResult = await validateCacheConsistency();
      return validationResult.fold((failure) => Left(failure), (result) {
        final Map<String, dynamic> stats = {
          'totalFiles': result.totalFiles,
          'validFiles': result.validFiles,
          'corruptedFiles': result.corruptedFiles,
          'orphanedFiles': result.orphanedFiles,
          'missingMetadata': result.missingMetadata,
          'inconsistentSizes': result.inconsistentSizes,
          'healthScore':
              result.validFiles /
              (result.totalFiles > 0 ? result.totalFiles : 1),
          'issueCount': result.issues.length,
        };
        return Right(stats);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache health stats: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, double>> checkCacheIntegrityScore() async {
    try {
      final validationResult = await validateCacheConsistency();
      return validationResult.fold((failure) => Left(failure), (result) {
        final score =
            result.totalFiles > 0 ? result.validFiles / result.totalFiles : 1.0;
        return Right(score);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check cache integrity score: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> generateMaintenanceReport() async {
    try {
      final validationResult = await validateCacheConsistency();
      return validationResult.fold((failure) => Left(failure), (result) {
        final report = StringBuffer();
        report.writeln('=== Cache Maintenance Report ===');
        report.writeln('Generated: ${DateTime.now().toIso8601String()}');
        report.writeln('');
        report.writeln('Cache Statistics:');
        report.writeln('- Total Files: ${result.totalFiles}');
        report.writeln('- Valid Files: ${result.validFiles}');
        report.writeln('- Corrupted Files: ${result.corruptedFiles}');
        report.writeln('- Orphaned Files: ${result.orphanedFiles}');
        report.writeln('- Missing Metadata: ${result.missingMetadata}');
        report.writeln('- Inconsistent Sizes: ${result.inconsistentSizes}');
        report.writeln('');

        final healthScore =
            result.totalFiles > 0
                ? (result.validFiles / result.totalFiles * 100).toStringAsFixed(
                  2,
                )
                : '100.00';
        report.writeln('Health Score: $healthScore%');
        report.writeln('');

        if (result.issues.isNotEmpty) {
          report.writeln('Issues Found:');
          for (final issue in result.issues) {
            report.writeln('- $issue');
          }
        } else {
          report.writeln('No issues found.');
        }

        return Right(report.toString());
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to generate maintenance report: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheSubDirectory');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }
}
