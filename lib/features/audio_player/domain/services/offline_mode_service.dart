import 'dart:async';

/// Service for detecting and managing offline mode behavior
/// Provides network connectivity monitoring and offline-first strategy coordination
abstract class OfflineModeService {
  /// Stream that emits connectivity status changes
  Stream<ConnectivityStatus> get connectivityStream;
  
  /// Current connectivity status
  ConnectivityStatus get currentConnectivity;
  
  /// Checks if the device is currently online
  bool get isOnline;
  
  /// Checks if the device is currently offline
  bool get isOffline;
  
  /// Gets the offline mode preference
  Future<OfflineMode> getOfflineMode();
  
  /// Sets the offline mode preference
  Future<void> setOfflineMode(OfflineMode mode);
  
  /// Enables offline-only mode (disables streaming)
  Future<void> enableOfflineOnlyMode();
  
  /// Disables offline-only mode (allows streaming)
  Future<void> disableOfflineOnlyMode();
  
  /// Checks if offline-only mode is enabled
  Future<bool> isOfflineOnlyModeEnabled();
  
  /// Gets network quality information
  Future<NetworkQuality> getNetworkQuality();
  
  /// Sets bandwidth usage preference
  Future<void> setBandwidthPreference(BandwidthPreference preference);
  
  /// Gets current bandwidth usage preference
  Future<BandwidthPreference> getBandwidthPreference();
  
  /// Triggers manual connectivity check
  Future<ConnectivityStatus> checkConnectivity();
  
  /// Gets data usage statistics
  Future<DataUsageStats> getDataUsageStats();
  
  /// Resets data usage statistics
  Future<void> resetDataUsageStats();
}

enum ConnectivityStatus {
  online,
  offline,
  limited, // Poor connection
  unknown,
}

enum OfflineMode {
  auto,        // Automatically switch based on connectivity
  offlineFirst, // Prefer cached content, fallback to streaming
  onlineFirst,  // Prefer streaming, fallback to cached
  offlineOnly,  // Only use cached content
}

enum NetworkQuality {
  excellent,   // High speed, unlimited data
  good,        // Good speed, sufficient data
  limited,     // Slow speed or limited data
  poor,        // Very slow or minimal data
  offline,     // No connection
}

enum BandwidthPreference {
  unlimited,   // No restrictions
  wifi,        // Only download/stream on WiFi
  limited,     // Minimize data usage
  emergency,   // Only critical operations
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
  double get downloadRatio => totalBytes > 0 ? totalBytesDownloaded / totalBytes : 0.0;
  double get streamingRatio => totalBytes > 0 ? totalBytesStreamed / totalBytes : 0.0;
}