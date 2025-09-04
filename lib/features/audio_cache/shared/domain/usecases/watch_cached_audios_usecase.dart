import 'package:injectable/injectable.dart';

import '../entities/cached_audio.dart';
import '../repositories/audio_storage_repository.dart';

@injectable
class WatchCachedAudiosUseCase {
  WatchCachedAudiosUseCase(this._storageRepository);

  final AudioStorageRepository _storageRepository;

  /// Reactive stream of all cached audios.
  /// Emits immediately and on every change.
  Stream<List<CachedAudio>> call() {
    return _storageRepository.watchAllCachedAudios();
  }
}
