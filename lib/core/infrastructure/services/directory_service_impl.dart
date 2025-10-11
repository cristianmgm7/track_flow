import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';

@LazySingleton(as: DirectoryService)
class DirectoryServiceImpl implements DirectoryService {
  // Cache for directory paths to avoid repeated async calls
  final Map<DirectoryType, String> _directoryCache = {};

  @override
  Future<Either<Failure, Directory>> getDirectory(DirectoryType type) async {
    try {
      // Check cache first
      if (_directoryCache.containsKey(type)) {
        final dir = Directory(_directoryCache[type]!);
        if (await dir.exists()) {
          return Right(dir);
        }
      }

      // Get base directory based on type
      final String basePath;
      switch (type) {
        case DirectoryType.audioCache:
          final appDir = await getApplicationDocumentsDirectory();
          basePath = '${appDir.path}/trackflow/audio';
          break;
        case DirectoryType.localAvatars:
          final appDir = await getApplicationDocumentsDirectory();
          basePath = '${appDir.path}/local_avatars';
          break;
        case DirectoryType.temporary:
          final tempDir = await getTemporaryDirectory();
          basePath = tempDir.path;
          break;
        case DirectoryType.documents:
          final appDir = await getApplicationDocumentsDirectory();
          basePath = appDir.path;
          break;
      }

      // Create directory if needed
      final dir = Directory(basePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Cache the path
      _directoryCache[type] = basePath;

      return Right(dir);
    } catch (e) {
      return Left(StorageFailure('Failed to get directory: $e'));
    }
  }

  @override
  Future<Either<Failure, Directory>> getSubdirectory(
    DirectoryType type,
    String subPath,
  ) async {
    try {
      final baseResult = await getDirectory(type);
      return baseResult.fold(
        (failure) => Left(failure),
        (baseDir) async {
          final subDir = Directory('${baseDir.path}/$subPath');
          if (!await subDir.exists()) {
            await subDir.create(recursive: true);
          }
          return Right(subDir);
        },
      );
    } catch (e) {
      return Left(StorageFailure('Failed to get subdirectory: $e'));
    }
  }

  @override
  Future<Either<Failure, Directory>> ensureDirectoryExists(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return Right(dir);
    } catch (e) {
      return Left(StorageFailure('Failed to ensure directory exists: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getFilePath(
    DirectoryType type,
    String relativePath,
  ) async {
    try {
      final dirResult = await getDirectory(type);
      return dirResult.fold(
        (failure) => Left(failure),
        (dir) async {
          final filePath = '${dir.path}/$relativePath';
          final file = File(filePath);

          // Ensure parent directory exists
          if (!await file.parent.exists()) {
            await file.parent.create(recursive: true);
          }

          return Right(filePath);
        },
      );
    } catch (e) {
      return Left(StorageFailure('Failed to get file path: $e'));
    }
  }

  @override
  String getRelativePath(String absolutePath, DirectoryType type) {
    try {
      // Get the cached base path
      final basePath = _directoryCache[type];
      if (basePath == null) {
        return absolutePath; // Fallback to absolute if not cached
      }

      // Extract relative path
      if (absolutePath.contains(basePath)) {
        final relativePath = absolutePath.substring(basePath.length);
        // Remove leading slash if present
        return relativePath.startsWith('/')
            ? relativePath.substring(1)
            : relativePath;
      }

      return absolutePath; // Fallback to absolute if not under base
    } catch (e) {
      return absolutePath; // Fallback on error
    }
  }

  @override
  Future<Either<Failure, String>> getAbsolutePath(
    String relativePath,
    DirectoryType type,
  ) async {
    try {
      final dirResult = await getDirectory(type);
      return dirResult.fold(
        (failure) => Left(failure),
        (dir) => Right('${dir.path}/$relativePath'),
      );
    } catch (e) {
      return Left(StorageFailure('Failed to get absolute path: $e'));
    }
  }

  /// Clear the directory cache (useful for testing)
  void clearCache() {
    _directoryCache.clear();
  }
}
