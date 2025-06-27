import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/audio_cache/domain/services/storage_management_service.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';

@Injectable(as: StorageManagementService)
class StorageManagementServiceImpl implements StorageManagementService {
  static const String _storageLimitKey = 'storage_limit_bytes';
  static const String _lastCleanupKey = 'last_cleanup_timestamp';
  static const String _cachedTracksMetaKey = 'cached_tracks_metadata';

  final GetCachedAudioPath getCachedAudioPath;
  final AudioCacheRepository audioCacheRepository;
  final Directory cacheDirectory;

  final StreamController<StorageStats> _storageStatsController =
      StreamController<StorageStats>.broadcast();

  StorageStats? _lastStats;
  Timer? _periodicStatsTimer;

  StorageManagementServiceImpl(
    this.getCachedAudioPath,
    this.audioCacheRepository,
    this.cacheDirectory,
  ) {
    _startPeriodicStatsUpdate();
  }

  void _startPeriodicStatsUpdate() {
    _periodicStatsTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateStorageStats(),
    );
  }

  @override
  Stream<StorageStats> get storageStatsStream => _storageStatsController.stream;

  @override
  Future<StorageStats> getStorageStats() async {
    try {
      final totalCacheSize = await _calculateCacheSize();
      final availableSpace = await getAvailableStorageBytes();
      final totalSpace = await getTotalStorageBytes();
      final cachedTracks = await getCachedTracks();
      final corruptedCount = cachedTracks.where((t) => t.isCorrupted).length;
      final lastCleanup = await _getLastCleanupTime();

      final stats = StorageStats(
        totalCacheSize: totalCacheSize,
        availableSpace: availableSpace,
        totalSpace: totalSpace,
        cachedTracksCount: cachedTracks.length,
        corruptedFilesCount: corruptedCount,
        lastCleanup: lastCleanup,
      );

      _lastStats = stats;
      _storageStatsController.add(stats);

      return stats;
    } catch (e) {
      // Return default stats on error
      final now = DateTime.now();
      return StorageStats(
        totalCacheSize: 0,
        availableSpace: 0,
        totalSpace: 0,
        cachedTracksCount: 0,
        corruptedFilesCount: 0,
        lastCleanup: now,
      );
    }
  }

  @override
  Future<int> getAvailableStorageBytes() async {
    try {
      final stat = await cacheDirectory.stat();
      // This is a simplified approach - in real implementation you'd use
      // platform-specific methods to get actual available space
      return 1000000000; // 1GB placeholder
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getTotalStorageBytes() async {
    try {
      // Placeholder - in real implementation use platform-specific methods
      return 10000000000; // 10GB placeholder
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> cleanupCorruptedFiles() async {
    try {
      final cachedTracks = await getCachedTracks();
      final corruptedTracks = cachedTracks.where((t) => t.isCorrupted).toList();

      for (final track in corruptedTracks) {
        await _removeTrackFile(track.trackUrl);
      }

      await _updateLastCleanupTime();
      await _updateStorageStats();
    } catch (e) {
      // Handle cleanup errors gracefully
    }
  }

  @override
  Future<int> cleanupOldestFiles(int targetBytes) async {
    try {
      final cachedTracks = await getCachedTracks();

      // Sort by last accessed time (oldest first)
      cachedTracks.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

      int bytesFreed = 0;
      final tracksToRemove = <String>[];

      for (final track in cachedTracks) {
        if (bytesFreed >= targetBytes) break;

        tracksToRemove.add(track.trackUrl);
        bytesFreed += track.fileSizeBytes;
      }

      await removeCachedTracks(tracksToRemove);
      await _updateLastCleanupTime();
      await _updateStorageStats();

      return bytesFreed;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      if (await cacheDirectory.exists()) {
        await for (final entity in cacheDirectory.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }

      await _clearCachedTracksMetadata();
      await _updateLastCleanupTime();
      await _updateStorageStats();
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<void> removeCachedTracks(List<String> trackUrls) async {
    try {
      for (final trackUrl in trackUrls) {
        await _removeTrackFile(trackUrl);
      }

      await _updateStorageStats();
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<List<CachedTrackInfo>> getCachedTracks() async {
    try {
      final tracks = <CachedTrackInfo>[];

      if (await cacheDirectory.exists()) {
        await for (final entity in cacheDirectory.list()) {
          if (entity is File && entity.path.endsWith('.mp3')) {
            final stat = await entity.stat();
            final trackInfo = await _createTrackInfoFromFile(entity, stat);
            if (trackInfo != null) {
              tracks.add(trackInfo);
            }
          }
        }
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> setStorageLimit(int limitBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageLimitKey, limitBytes);
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<int> getStorageLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_storageLimitKey) ?? -1; // -1 means unlimited
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<bool> isCleanupNeeded() async {
    try {
      final stats = await getStorageStats();
      final storageLimit = await getStorageLimit();

      // Check if we're low on space
      if (stats.isLowOnSpace) return true;

      // Check if we've exceeded storage limit
      if (storageLimit > 0 && stats.totalCacheSize > storageLimit) return true;

      // Check if there are corrupted files
      if (stats.corruptedFilesCount > 0) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CleanupResult> performAutoCleanup() async {
    final startTime = DateTime.now();
    int bytesFreed = 0;
    int filesRemoved = 0;
    int corruptedFilesRemoved = 0;
    final removedTrackUrls = <String>[];

    try {
      final stats = await getStorageStats();

      // First, remove corrupted files
      final cachedTracks = await getCachedTracks();
      final corruptedTracks = cachedTracks.where((t) => t.isCorrupted).toList();

      for (final track in corruptedTracks) {
        await _removeTrackFile(track.trackUrl);
        bytesFreed += track.fileSizeBytes;
        corruptedFilesRemoved++;
        removedTrackUrls.add(track.trackUrl);
      }

      // Check if we need more cleanup
      final storageLimit = await getStorageLimit();
      if (storageLimit > 0) {
        final currentCacheSize = stats.totalCacheSize - bytesFreed;
        if (currentCacheSize > storageLimit) {
          final targetBytes = currentCacheSize - storageLimit;
          final additionalFreed = await cleanupOldestFiles(targetBytes);
          bytesFreed += additionalFreed;
        }
      }

      await _updateLastCleanupTime();
      await _updateStorageStats();
    } catch (e) {
      // Handle cleanup errors
    }

    final duration = DateTime.now().difference(startTime);

    return CleanupResult(
      bytesFreed: bytesFreed,
      filesRemoved: filesRemoved,
      corruptedFilesRemoved: corruptedFilesRemoved,
      cleanupDuration: duration,
      removedTrackUrls: removedTrackUrls,
    );
  }

  Future<int> _calculateCacheSize() async {
    try {
      int totalSize = 0;

      if (await cacheDirectory.exists()) {
        await for (final entity in cacheDirectory.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime> _getLastCleanupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastCleanupKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      // Handle error gracefully
    }
    return DateTime.now().subtract(const Duration(days: 30));
  }

  Future<void> _updateLastCleanupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastCleanupKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> _updateStorageStats() async {
    try {
      await getStorageStats();
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> _removeTrackFile(String trackUrl) async {
    try {
      final cachedPath = await getCachedAudioPath(trackUrl);
      final file = File(cachedPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<CachedTrackInfo?> _createTrackInfoFromFile(
    File file,
    FileStat stat,
  ) async {
    try {
      // Extract track info from filename or metadata
      // This is a simplified approach - in real implementation you'd
      // have a proper mapping system
      final filename = file.path.split('/').last;
      final trackUrl = filename.replaceAll('.mp3', '');

      return CachedTrackInfo(
        trackUrl: trackUrl,
        trackId: trackUrl, // Simplified mapping
        trackName: filename,
        fileSizeBytes: stat.size,
        lastAccessed: stat.accessed,
        cachedAt: stat.modified,
        isCorrupted: await _isFileCorrupted(file),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> _isFileCorrupted(File file) async {
    try {
      // Simple corruption check - file size > 0
      final stat = await file.stat();
      return stat.size == 0;
    } catch (e) {
      return true;
    }
  }

  Future<void> _clearCachedTracksMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedTracksMetaKey);
    } catch (e) {
      // Handle error gracefully
    }
  }

  void dispose() {
    _periodicStatsTimer?.cancel();
    _storageStatsController.close();
  }
}
