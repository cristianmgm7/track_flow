import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_key_repository.dart';
import '../../domain/value_objects/cache_key.dart';
import '../datasources/cache_storage_local_data_source.dart';

@LazySingleton(as: CacheKeyRepository)
class CacheKeyRepositoryImpl implements CacheKeyRepository {
  final CacheStorageLocalDataSource _localDataSource;

  CacheKeyRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  CacheKey generateCacheKey(String trackId, String audioUrl) {
    return _localDataSource.generateCacheKey(trackId, audioUrl);
  }

  @override
  CacheKey generateCacheKeyWithParams(
    String trackId,
    String audioUrl,
    Map<String, String> parameters,
  ) {
    // Create a composite key with additional parameters
    final baseKey = _localDataSource.generateCacheKey(trackId, audioUrl);
    
    // Extend the cache key with parameters
    // This is a simplified implementation - in production you'd want to
    // properly encode parameters into the key structure
    final paramString = parameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return CacheKey.composite(
      trackId,
      '${baseKey.checksum}_$paramString',
    );
  }

  @override
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key) async {
    return await _localDataSource.getFilePathFromCacheKey(key);
  }

  @override
  Future<Either<CacheFailure, String>> getDirectoryPathFromCacheKey(
    CacheKey key,
  ) async {
    try {
      final filePathResult = await getFilePathFromCacheKey(key);
      return filePathResult.fold(
        (failure) => Left(failure),
        (filePath) {
          final directory = filePath.substring(0, filePath.lastIndexOf('/'));
          return Right(directory);
        },
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get directory path from cache key: $e',
          field: 'cacheKey',
          value: key.toString(),
        ),
      );
    }
  }

  @override
  bool isValidCacheKey(CacheKey key) {
    return key.isComposite && key.trackId != null && key.checksum != null;
  }

  @override
  Either<CacheFailure, Map<String, String>> parseCacheKey(CacheKey key) {
    try {
      if (!isValidCacheKey(key)) {
        return Left(
          ValidationCacheFailure(
            message: 'Invalid cache key format',
            field: 'cacheKey',
            value: key.toString(),
          ),
        );
      }

      final Map<String, String> components = {
        'trackId': key.trackId ?? '',
        'checksum': key.checksum ?? '',
        'value': key.value,
      };

      // Parse additional parameters if they exist in the checksum
      final checksum = key.checksum ?? '';
      if (checksum.contains('_')) {
        final parts = checksum.split('_');
        if (parts.length > 1) {
          final paramString = parts.sublist(1).join('_');
          if (paramString.contains('&')) {
            for (final param in paramString.split('&')) {
              if (param.contains('=')) {
                final keyValue = param.split('=');
                if (keyValue.length == 2) {
                  components[keyValue[0]] = keyValue[1];
                }
              }
            }
          }
        }
      }

      return Right(components);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to parse cache key: $e',
          field: 'cacheKey',
          value: key.toString(),
        ),
      );
    }
  }

  @override
  CacheKey generateTempCacheKey(String trackId) {
    return CacheKey.composite(
      trackId,
      'temp_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  bool isTempCacheKey(CacheKey key) {
    return key.checksum?.startsWith('temp_') ?? false;
  }

  @override
  String cacheKeyToStorageId(CacheKey key) {
    if (key.isComposite) {
      return '${key.trackId}_${key.checksum}';
    } else {
      return key.value;
    }
  }

  @override
  Either<CacheFailure, CacheKey> storageIdToCacheKey(String storageId) {
    try {
      if (storageId.contains('_')) {
        final parts = storageId.split('_');
        if (parts.length >= 2) {
          final trackId = parts[0];
          final checksum = parts.sublist(1).join('_');
          
          return Right(
            CacheKey.composite(trackId, checksum),
          );
        }
      }

      // Simple key format - use fromUrl for single value keys
      return Right(CacheKey.fromUrl(storageId));
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to convert storage ID to cache key: $e',
          field: 'storageId',
          value: storageId,
        ),
      );
    }
  }
}