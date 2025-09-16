import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../failures/cache_failure.dart';
import '../repositories/audio_storage_repository.dart';

@injectable
class RemoveTrackCacheUseCase {
  final AudioStorageRepository _audioStorageRepository;

  RemoveTrackCacheUseCase(this._audioStorageRepository);

  /// Remove a track or specific version from cache
  Future<Either<CacheFailure, Unit>> call({
    required String trackId,
    String? versionId,
  }) async {
    // Validate inputs
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
      if (versionId != null && versionId.isNotEmpty) {
        return await _audioStorageRepository.deleteAudioVersionFile(
          AudioTrackId.fromUniqueString(trackId),
          TrackVersionId.fromUniqueString(versionId),
        );
      }
      return await _audioStorageRepository.deleteAudioFile(
        AudioTrackId.fromUniqueString(trackId),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing track from cache: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }
}
