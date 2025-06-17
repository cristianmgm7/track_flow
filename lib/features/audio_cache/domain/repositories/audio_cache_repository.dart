abstract class AudioCacheRepository {
  Future<String> getCachedAudioPath(
    String remoteUrl, {
    void Function(double progress)? onProgress,
  });
}
