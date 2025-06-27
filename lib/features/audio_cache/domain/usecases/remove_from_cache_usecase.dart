import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/services/storage_management_service.dart';

@injectable
class RemoveFromCacheUseCase {
  final StorageManagementService _storageService;

  RemoveFromCacheUseCase(this._storageService);

  Future<Either<Failure, Unit>> call(String trackUrl) async {
    try {
      await _storageService.removeCachedTracks([trackUrl]);
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}