enum ConnectivityStatus {
  online,
  offline,
  limited, // Poor connection
  unknown,
}

enum OfflineMode {
  auto, // Automatically switch based on connectivity
  offlineFirst, // Prefer cached content, fallback to streaming
  onlineFirst, // Prefer streaming, fallback to cached
  offlineOnly, // Only use cached content
}

enum NetworkQuality {
  excellent, // High speed, unlimited data
  good, // Good speed, sufficient data
  limited, // Slow speed or limited data
  poor, // Very slow or minimal data
  offline, // No connection
}

enum BandwidthPreference {
  unlimited, // No restrictions
  wifi, // Only download/stream on WiFi
  limited, // Minimize data usage
  emergency, // Only critical operations
}

class DataUsageStats {
  final int totalBytesDownloaded;
  final int totalBytesStreamed;
  final int sessionsCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, int> dailyUsage;

  const DataUsageStats({
    required this.totalBytesDownloaded,
    required this.totalBytesStreamed,
    required this.sessionsCount,
    required this.periodStart,
    required this.periodEnd,
    required this.dailyUsage,
  });

  int get totalBytes => totalBytesDownloaded + totalBytesStreamed;
  double get downloadRatio =>
      totalBytes > 0 ? totalBytesDownloaded / totalBytes : 0.0;
  double get streamingRatio =>
      totalBytes > 0 ? totalBytesStreamed / totalBytes : 0.0;
}
