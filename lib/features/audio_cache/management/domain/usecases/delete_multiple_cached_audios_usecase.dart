import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/shared/domain/failures/cache_failure.dart'
    as cache;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart';

@injectable
class DeleteMultipleCachedAudiosUseCase {
  DeleteMultipleCachedAudiosUseCase(this._storageRepository);

  final AudioStorageRepository _storageRepository;

  Future<Either<Failure, List<AudioTrackId>>> call(
    List<AudioTrackId> trackIds,
  ) async {
    try {
      final result = await _storageRepository.deleteMultipleAudioFiles(
        trackIds,
      );
      return result.fold(
        (cacheFailure) => Left(_toFailure(cacheFailure)),
        (deleted) => Right(deleted),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to delete multiple cached audios: $e'));
    }
  }

  Failure _toFailure(cache.CacheFailure failure) =>
      ServerFailure(failure.message);
}
