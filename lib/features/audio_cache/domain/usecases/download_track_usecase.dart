import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';

@injectable
class DownloadTrackUseCase {
  final AudioCacheRepository _repository;

  DownloadTrackUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String trackUrl,
    required String trackName,
    Function(double)? onProgress,
  }) async {
    try {
      final localPath = await _repository.getCachedAudioPath(
        trackUrl,
        onProgress: onProgress,
      );
      return Right(localPath);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}