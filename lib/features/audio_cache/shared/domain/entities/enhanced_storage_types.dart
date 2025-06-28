import 'package:equatable/equatable.dart';
import '../value_objects/storage_limit.dart';
import 'cached_audio.dart';

// ===============================================
// ENHANCED STORAGE STATISTICS
// ===============================================

/// Enhanced storage statistics with detailed breakdown
class EnhancedStorageStats extends Equatable {
  const EnhancedStorageStats({
    required this.totalCacheSize,
    required this.availableSpace,
    required this.totalSpace,
    required this.cachedTracksCount,
    required this.corruptedFilesCount,
    required this.orphanedFilesCount,
    required this.lastCleanup,
    required this.cacheEfficiency,
    required this.averageFileSize,
    required this.largestFile,
    required this.oldestFile,
    required this.newestFile,
    required this.duplicateFiles,
    required this.compressionRatio,
  });

  final int totalCacheSize;
  final int availableSpace;
  final int totalSpace;
  final int cachedTracksCount;
  final int corruptedFilesCount;
  final int orphanedFilesCount;
  final DateTime lastCleanup;
  final double cacheEfficiency; // 0.0 to 1.0
  final int averageFileSize;
  final int largestFile;
  final DateTime oldestFile;
  final DateTime newestFile;
  final int duplicateFiles;
  final double compressionRatio;

  double get cacheUsagePercentage =>
      totalSpace > 0 ? totalCacheSize / totalSpace : 0.0;
  double get availablePercentage =>
      totalSpace > 0 ? availableSpace / totalSpace : 0.0;

  bool get isLowOnSpace => availablePercentage < 0.1;
  bool get isCriticallyLow => availablePercentage < 0.05;
  bool get needsOptimization => cacheEfficiency < 0.7 || duplicateFiles > 0;

  @override
  List<Object?> get props => [
    totalCacheSize,
    availableSpace,
    totalSpace,
    cachedTracksCount,
    corruptedFilesCount,
    orphanedFilesCount,
    lastCleanup,
    cacheEfficiency,
    averageFileSize,
    largestFile,
    oldestFile,
    newestFile,
    duplicateFiles,
    compressionRatio,
  ];
}

/// Cache directory statistics
class CacheDirectoryStats extends Equatable {
  const CacheDirectoryStats({
    required this.totalSize,
    required this.fileCount,
    required this.subdirectoryCount,
  });

  final int totalSize;
  final int fileCount;
  final int subdirectoryCount;

  @override
  List<Object?> get props => [totalSize, fileCount, subdirectoryCount];
}

/// Enhanced cached track information
class EnhancedCachedTrackInfo extends Equatable {
  const EnhancedCachedTrackInfo({
    required this.cachedAudio,
    required this.referenceCount,
    required this.lastAccessed,
    required this.accessCount,
    required this.downloadDate,
    required this.isCorrupted,
    required this.compressionRatio,
    required this.estimatedDiskUsage,
    this.playbackHistory,
    this.tags,
  });

  final CachedAudio cachedAudio;
  final int referenceCount;
  final DateTime lastAccessed;
  final int accessCount;
  final DateTime downloadDate;
  final bool isCorrupted;
  final double compressionRatio;
  final int estimatedDiskUsage;
  final List<DateTime>? playbackHistory;
  final Map<String, String>? tags;

  Duration get age => DateTime.now().difference(downloadDate);
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessed);

  bool get isFrequentlyUsed => accessCount > 10;
  bool get isRecentlyUsed => timeSinceLastAccess.inDays < 7;
  bool get isCandidate =>
      !isFrequentlyUsed && !isRecentlyUsed && referenceCount <= 1;

  @override
  List<Object?> get props => [
    cachedAudio,
    referenceCount,
    lastAccessed,
    accessCount,
    downloadDate,
    isCorrupted,
    compressionRatio,
    estimatedDiskUsage,
    playbackHistory,
    tags,
  ];
}

// ===============================================
// CLEANUP RESULTS
// ===============================================

/// Enhanced cleanup result with detailed information
class EnhancedCleanupResult extends Equatable {
  const EnhancedCleanupResult({
    required this.totalFilesRemoved,
    required this.totalSpaceFreed,
    required this.corruptedFilesRemoved,
    required this.orphanedFilesRemoved,
    required this.temporaryFilesRemoved,
    required this.oldestFilesRemoved,
    required this.duplicateFilesRemoved,
    required this.strategy,
    required this.duration,
    required this.errors,
  });

  final int totalFilesRemoved;
  final int totalSpaceFreed;
  final int corruptedFilesRemoved;
  final int orphanedFilesRemoved;
  final int temporaryFilesRemoved;
  final int oldestFilesRemoved;
  final int duplicateFilesRemoved;
  final EnhancedCleanupStrategy strategy;
  final Duration duration;
  final List<String> errors;

  String get summary => 
      'Removed $totalFilesRemoved files, freed ${_formatBytes(totalSpaceFreed)}';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  List<Object?> get props => [
    totalFilesRemoved,
    totalSpaceFreed,
    corruptedFilesRemoved,
    orphanedFilesRemoved,
    temporaryFilesRemoved,
    oldestFilesRemoved,
    duplicateFilesRemoved,
    strategy,
    duration,
    errors,
  ];
}

/// Corruption cleanup result
class CorruptionCleanupResult extends Equatable {
  const CorruptionCleanupResult({
    required this.filesRemoved,
    required this.spaceFreed,
    required this.corruptionTypes,
  });

  final int filesRemoved;
  final int spaceFreed;
  final List<String> corruptionTypes;

  @override
  List<Object?> get props => [filesRemoved, spaceFreed, corruptionTypes];
}

/// Orphan cleanup result
class OrphanCleanupResult extends Equatable {
  const OrphanCleanupResult({
    required this.filesRemoved,
    required this.spaceFreed,
    required this.orphanTypes,
  });

  final int filesRemoved;
  final int spaceFreed;
  final List<String> orphanTypes;

  @override
  List<Object?> get props => [filesRemoved, spaceFreed, orphanTypes];
}

/// Age-based cleanup result
class AgeBasedCleanupResult extends Equatable {
  const AgeBasedCleanupResult({
    required this.filesRemoved,
    required this.spaceFreed,
    required this.oldestRemoved,
    required this.averageAge,
  });

  final int filesRemoved;
  final int spaceFreed;
  final Duration oldestRemoved;
  final Duration averageAge;

  @override
  List<Object?> get props => [filesRemoved, spaceFreed, oldestRemoved, averageAge];
}

/// Space optimization result
class SpaceOptimizationResult extends Equatable {
  const SpaceOptimizationResult({
    required this.targetBytes,
    required this.actualBytesFreed,
    required this.filesRemoved,
    required this.strategy,
    required this.referencesRespected,
  });

  final int targetBytes;
  final int actualBytesFreed;
  final int filesRemoved;
  final EnhancedCleanupStrategy strategy;
  final bool referencesRespected;

  @override
  List<Object?> get props => [
    targetBytes,
    actualBytesFreed,
    filesRemoved,
    strategy,
    referencesRespected,
  ];
}

// ===============================================
// STORAGE CONFIGURATION TYPES
// ===============================================

/// Storage limit configuration
class StorageLimitConfig extends Equatable {
  const StorageLimitConfig({
    required this.limit,
    required this.policy,
    required this.warningThreshold,
    required this.criticalThreshold,
  });

  final StorageLimit limit;
  final StorageLimitPolicy policy;
  final double warningThreshold;
  final double criticalThreshold;

  @override
  List<Object?> get props => [limit, policy, warningThreshold, criticalThreshold];
}

/// Storage limit status
class StorageLimitStatus extends Equatable {
  const StorageLimitStatus({
    required this.currentUsage,
    required this.usagePercentage,
    required this.remainingBytes,
    required this.isWarning,
    required this.isCritical,
    required this.isExceeded,
  });

  final int currentUsage;
  final double usagePercentage;
  final int remainingBytes;
  final bool isWarning;
  final bool isCritical;
  final bool isExceeded;

  @override
  List<Object?> get props => [
    currentUsage,
    usagePercentage,
    remainingBytes,
    isWarning,
    isCritical,
    isExceeded,
  ];
}

// ===============================================
// FILTERING AND SEARCH TYPES
// ===============================================

/// Cache filter options
class CacheFilterOptions extends Equatable {
  const CacheFilterOptions({
    this.minFileSize,
    this.maxFileSize,
    this.minAge,
    this.maxAge,
    this.quality,
    this.status,
    this.hasReferences,
  });

  final int? minFileSize;
  final int? maxFileSize;
  final Duration? minAge;
  final Duration? maxAge;
  final AudioQuality? quality;
  final CacheStatus? status;
  final bool? hasReferences;

  @override
  List<Object?> get props => [
    minFileSize,
    maxFileSize,
    minAge,
    maxAge,
    quality,
    status,
    hasReferences,
  ];
}

/// Cache search criteria
class CacheSearchCriteria extends Equatable {
  const CacheSearchCriteria({
    this.trackIdPattern,
    this.minAccessCount,
    this.maxDaysSinceAccess,
    this.filter,
  });

  final String? trackIdPattern;
  final int? minAccessCount;
  final int? maxDaysSinceAccess;
  final CacheFilterOptions? filter;

  @override
  List<Object?> get props => [
    trackIdPattern,
    minAccessCount,
    maxDaysSinceAccess,
    filter,
  ];
}

/// Cache removal candidate
class CacheRemovalCandidate extends Equatable {
  const CacheRemovalCandidate({
    required this.trackId,
    required this.reason,
    required this.priority,
    required this.spaceSaving,
    required this.riskScore,
  });

  final String trackId;
  final String reason;
  final double priority; // 0.0 to 1.0
  final int spaceSaving;
  final double riskScore; // 0.0 to 1.0

  @override
  List<Object?> get props => [trackId, reason, priority, spaceSaving, riskScore];
}

/// Cache usage analysis
class CacheUsageAnalysis extends Equatable {
  const CacheUsageAnalysis({
    required this.totalTracks,
    required this.totalSize,
    required this.averageFileSize,
    required this.usagePatterns,
    required this.recommendations,
  });

  final int totalTracks;
  final int totalSize;
  final int averageFileSize;
  final Map<String, dynamic> usagePatterns;
  final List<String> recommendations;

  @override
  List<Object?> get props => [
    totalTracks,
    totalSize,
    averageFileSize,
    usagePatterns,
    recommendations,
  ];
}

// ===============================================
// MONITORING AND EVENT TYPES
// ===============================================

/// Storage limit violation
class StorageLimitViolation extends Equatable {
  const StorageLimitViolation._({
    required this.type,
    required this.currentUsage,
    required this.limit,
    required this.timestamp,
  });

  final String type;
  final int currentUsage;
  final int limit;
  final DateTime timestamp;

  factory StorageLimitViolation.warning({
    required int currentUsage,
    required int limit,
  }) {
    return StorageLimitViolation._(
      type: 'warning',
      currentUsage: currentUsage,
      limit: limit,
      timestamp: DateTime.now(),
    );
  }

  factory StorageLimitViolation.critical({
    required int currentUsage,
    required int limit,
  }) {
    return StorageLimitViolation._(
      type: 'critical',
      currentUsage: currentUsage,
      limit: limit,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [type, currentUsage, limit, timestamp];
}

/// Cache directory change event
class CacheDirectoryChange extends Equatable {
  const CacheDirectoryChange({
    required this.type,
    required this.path,
    required this.timestamp,
  });

  final String type;
  final String path;
  final DateTime timestamp;

  @override
  List<Object?> get props => [type, path, timestamp];
}

/// Cleanup operation event
class CleanupOperation extends Equatable {
  const CleanupOperation._({
    required this.type,
    this.strategy,
    this.result,
    this.error,
    required this.timestamp,
  });

  final String type;
  final String? strategy;
  final String? result;
  final String? error;
  final DateTime timestamp;

  factory CleanupOperation.started({required String strategy}) {
    return CleanupOperation._(
      type: 'started',
      strategy: strategy,
      timestamp: DateTime.now(),
    );
  }

  factory CleanupOperation.completed({required String result}) {
    return CleanupOperation._(
      type: 'completed',
      result: result,
      timestamp: DateTime.now(),
    );
  }

  factory CleanupOperation.failed({required String error}) {
    return CleanupOperation._(
      type: 'failed',
      error: error,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [type, strategy, result, error, timestamp];
}

// ===============================================
// MAINTENANCE AND REPAIR TYPES
// ===============================================

/// Cache integrity report
class CacheIntegrityReport extends Equatable {
  const CacheIntegrityReport({
    required this.totalFiles,
    required this.validFiles,
    required this.issues,
    required this.recommendations,
  });

  final int totalFiles;
  final int validFiles;
  final List<String> issues;
  final List<String> recommendations;

  @override
  List<Object?> get props => [totalFiles, validFiles, issues, recommendations];
}

/// Cache repair result
class CacheRepairResult extends Equatable {
  const CacheRepairResult({
    required this.repairedFiles,
    required this.unreparableFiles,
    required this.actions,
  });

  final int repairedFiles;
  final int unreparableFiles;
  final List<String> actions;

  @override
  List<Object?> get props => [repairedFiles, unreparableFiles, actions];
}

/// Cache optimization result
class CacheOptimizationResult extends Equatable {
  const CacheOptimizationResult({
    required this.optimizationsApplied,
    required this.spaceRecovered,
    required this.performanceImprovement,
  });

  final List<String> optimizationsApplied;
  final int spaceRecovered;
  final double performanceImprovement;

  @override
  List<Object?> get props => [
    optimizationsApplied,
    spaceRecovered,
    performanceImprovement,
  ];
}

// ===============================================
// ENUMS
// ===============================================

/// Enhanced cleanup strategies
enum EnhancedCleanupStrategy {
  intelligent, // AI-based selection considering usage patterns
  leastAccessed, // Remove least recently accessed files
  oldestFirst, // Remove oldest files first
  largestFirst, // Remove largest files first
  lowestPriority, // Remove files with lowest reference count
  duplicates, // Remove duplicate content
  corruptedOnly, // Remove only corrupted files
  orphanedOnly, // Remove only orphaned files
  combinedAge, // Combine age and access patterns
}

/// Cache sort options
enum CacheSortOption {
  lastAccessed,
  downloadDate,
  fileSize,
  trackName,
  referenceCount,
  accessCount,
}

/// Storage limit policies
enum StorageLimitPolicy {
  softLimit, // Warning when approaching limit
  hardLimit, // Prevent new downloads when limit reached
  autoCleanup, // Automatically cleanup when limit reached
  intelligentManagement, // AI-based management
}

/// Auto cleanup policy
enum AutoCleanupPolicy {
  conservative,
  aggressive,
  disabled,
}