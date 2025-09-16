import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../failures/cache_failure.dart';
import '../repositories/audio_storage_repository.dart';

@injectable
class GetCachedTrackPathUseCase {
  final AudioStorageRepository _audioStorageRepository;

  GetCachedTrackPathUseCase(this._audioStorageRepository);

  /// Get cached track file path if exists
  ///
  /// [trackId] - Unique identifier for the track
  /// [versionId] - Optional identifier for the track version
  ///
  /// Returns absolute file path or failure if not found
  Future<Either<CacheFailure, String?>> call({
    required String trackId,
    String? versionId,
  }) async {
    if (trackId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }

    try {
      final result = await _audioStorageRepository.getCachedAudioPath(
        AudioTrackId.fromUniqueString(trackId),
        versionId:
            versionId != null && versionId.isNotEmpty
                ? TrackVersionId.fromUniqueString(versionId)
                : null,
      );

      return result.fold(
        (failure) => Left(failure),
        (filePath) => Right(filePath),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting cached track path: $e',
          field: 'get_path_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }
}
