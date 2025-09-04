import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart'
    as cache;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';

@injectable
class DeleteCachedAudioUseCase {
  DeleteCachedAudioUseCase(this._storageRepository);

  final AudioStorageRepository _storageRepository;

  Future<Either<Failure, Unit>> call(AudioTrackId trackId) async {
    try {
      final result = await _storageRepository.deleteAudioFile(trackId);
      return result.fold(
        (cacheFailure) => Left(_toFailure(cacheFailure)),
        (unit) => Right(unit),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to delete cached audio: $e'));
    }
  }

  Failure _toFailure(cache.CacheFailure failure) =>
      ServerFailure(failure.message);
}
