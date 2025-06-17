import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/data/datasources/audio_cache_local_data_source.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';

@LazySingleton(as: AudioCacheRepository)
class AudioCacheRepositoryImpl implements AudioCacheRepository {
  final AudioCacheLocalDataSource localDataSource;

  AudioCacheRepositoryImpl(this.localDataSource);

  @override
  Future<String> getCachedAudioPath(
    String remoteUrl, {
    void Function(double progress)? onProgress,
  }) async {
    if (await localDataSource.isCached(remoteUrl)) {
      return await localDataSource.getLocalPath(remoteUrl);
    } else {
      return await localDataSource.downloadAndCache(
        remoteUrl,
        onProgress: onProgress,
      );
    }
  }
}
