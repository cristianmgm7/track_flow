enum CacheStatus { notCached, caching, cached, corrupted }

class AudioSourceResult {
  final String path;
  final AudioSourceType type;
  final bool isBackgroundCaching;

  const AudioSourceResult({
    required this.path,
    required this.type,
    this.isBackgroundCaching = false,
  });
}

enum AudioSourceType { cache, streaming }
