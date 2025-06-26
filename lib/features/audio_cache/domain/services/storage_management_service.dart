import 'dart:async';

/// Service for managing storage space and cached audio files
abstract class StorageManagementService {
  /// Gets current storage usage statistics
  Future<StorageStats> getStorageStats();
  
  /// Gets available storage space on device
  Future<int> getAvailableStorageBytes();
  
  /// Gets total device storage
  Future<int> getTotalStorageBytes();
  
  /// Cleans up corrupted cache files
  Future<void> cleanupCorruptedFiles();
  
  /// Removes oldest cached files to free up space
  Future<int> cleanupOldestFiles(int targetBytes);
  
  /// Removes all cached files
  Future<void> clearAllCache();
  
  /// Removes cache for specific tracks
  Future<void> removeCachedTracks(List<String> trackUrls);
  
  /// Gets list of cached track URLs sorted by access time
  Future<List<CachedTrackInfo>> getCachedTracks();
  
  /// Sets storage limit preference
  Future<void> setStorageLimit(int limitBytes);
  
  /// Gets current storage limit preference
  Future<int> getStorageLimit();
  
  /// Checks if storage cleanup is needed
  Future<bool> isCleanupNeeded();
  
  /// Performs automatic cleanup based on settings
  Future<CleanupResult> performAutoCleanup();
  
  /// Stream that emits storage stats changes
  Stream<StorageStats> get storageStatsStream;
}

class StorageStats {
  final int totalCacheSize;
  final int availableSpace;
  final int totalSpace;
  final int cachedTracksCount;
  final int corruptedFilesCount;
  final DateTime lastCleanup;

  const StorageStats({
    required this.totalCacheSize,
    required this.availableSpace,
    required this.totalSpace,
    required this.cachedTracksCount,
    required this.corruptedFilesCount,
    required this.lastCleanup,
  });

  double get cacheUsagePercentage => totalSpace > 0 ? totalCacheSize / totalSpace : 0.0;
  double get availablePercentage => totalSpace > 0 ? availableSpace / totalSpace : 0.0;
  
  bool get isLowOnSpace => availablePercentage < 0.1; // Less than 10%
  bool get isCriticallyLow => availablePercentage < 0.05; // Less than 5%
}

class CachedTrackInfo {
  final String trackUrl;
  final String trackId;
  final String trackName;
  final int fileSizeBytes;
  final DateTime lastAccessed;
  final DateTime cachedAt;
  final bool isCorrupted;

  const CachedTrackInfo({
    required this.trackUrl,
    required this.trackId,
    required this.trackName,
    required this.fileSizeBytes,
    required this.lastAccessed,
    required this.cachedAt,
    required this.isCorrupted,
  });
}

class CleanupResult {
  final int bytesFreed;
  final int filesRemoved;
  final int corruptedFilesRemoved;
  final Duration cleanupDuration;
  final List<String> removedTrackUrls;

  const CleanupResult({
    required this.bytesFreed,
    required this.filesRemoved,
    required this.corruptedFilesRemoved,
    required this.cleanupDuration,
    required this.removedTrackUrls,
  });
}

enum StorageCleanupStrategy {
  oldestFirst,
  largestFirst,
  leastAccessed,
  corruptedOnly,
}

enum StorageLimitMode {
  unlimited,
  limited,
  percentage,
  emergency,
}