import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';

@LazySingleton()
class GetCachedAudioPath {
  final AudioCacheRepository repository;

  GetCachedAudioPath(this.repository);

  Future<String> call(
    String remoteUrl, {
    void Function(double progress)? onProgress,
  }) async {
    return await repository.getCachedAudioPath(
      remoteUrl,
      onProgress: onProgress,
    );
  }
}
