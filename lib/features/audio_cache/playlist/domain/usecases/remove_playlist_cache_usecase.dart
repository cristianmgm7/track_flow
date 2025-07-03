import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/audio_storage_repository.dart';
import '../../../../../core/entities/unique_id.dart';

@injectable
class RemovePlaylistCacheUseCase {
  final AudioStorageRepository _audioStorageRepository;

  RemovePlaylistCacheUseCase(this._audioStorageRepository);

  /// Remove all tracks from a playlist cache
  Future<Either<CacheFailure, Unit>> call(List<String> trackIds) async {
    if (trackIds.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track IDs list cannot be empty',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }

    try {
      final audioTrackIds = trackIds.map((id) => AudioTrackId.fromUniqueString(id)).toList();
      final result = await _audioStorageRepository.deleteMultipleAudioFiles(
        audioTrackIds,
      );
      return result.fold(
        (failure) => Left(failure),
        (deletedIds) => const Right(unit),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing playlist cache: $e',
          field: 'cache_operation',
          value: {'trackIds': trackIds},
        ),
      );
    }
  }

  /// Remove a single track from playlist cache
  Future<Either<CacheFailure, Unit>> removeTrack(String trackId) async {
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
      return await _audioStorageRepository.deleteAudioFile(AudioTrackId.fromUniqueString(trackId));
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message:
              'Unexpected error while removing track from playlist cache: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }
}
