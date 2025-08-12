import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart';

@injectable
class WatchStorageUsageUseCase {
  WatchStorageUsageUseCase(this._storageRepository);

  final AudioStorageRepository _storageRepository;

  Stream<int> call() {
    return _storageRepository.watchStorageUsage();
  }
}
