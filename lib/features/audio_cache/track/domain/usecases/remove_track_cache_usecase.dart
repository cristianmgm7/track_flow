import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/audio_storage_repository.dart';

@injectable
class RemoveTrackCacheUseCase {
  final AudioStorageRepository _audioStorageRepository;

  RemoveTrackCacheUseCase(this._audioStorageRepository);

  /// Remove a track from cache
  Future<Either<CacheFailure, Unit>> call(String trackId) async {
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
