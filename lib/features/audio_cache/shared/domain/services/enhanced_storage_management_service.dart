import 'package:dartz/dartz.dart';
import '../entities/cached_audio.dart';
import '../failures/cache_failure.dart';
import '../value_objects/storage_limit.dart';

/// Enhanced storage management service with shared infrastructure support
/// Extends existing functionality while maintaining backward compatibility
abstract class EnhancedStorageManagementService {
  // ===============================================
  // CORE STORAGE OPERATIONS - ENHANCED
  // ===============================================

  /// Get enhanced storage statistics with detailed breakdown
  Future<Either<CacheFailure, EnhancedStorageStats>> getStorageStats();

  /// Get available storage space with caching optimizations
  Future<Either<CacheFailure, int>> getAvailableStorageBytes();

  /// Get total device storage capacity
  Future<Either<CacheFailure, int>> getTotalStorageBytes();

  /// Get cache directory usage breakdown
  Future<Either<CacheFailure, CacheDirectoryStats>> getCacheDirectoryStats();

  /// Check if storage cleanup is needed based on policy
  Future<Either<CacheFailure, bool>> isCleanupNeeded();

  /// Predict when cleanup will be needed
  Future<Either<CacheFailure, Duration?>> estimateCleanupTimeNeeded();

  // ===============================================
  // ADVANCED CLEANUP OPERATIONS
  // ===============================================

  /// Perform comprehensive cleanup with detailed results
  Future<Either<CacheFailure, EnhancedCleanupResult>> performCleanup({
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.intelligent,
    int? targetFreeBytes,
    double? targetFreePercentage,
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool respectReferences = true,
  });

  /// Clean up corrupted files with detailed reporting
  Future<Either<CacheFailure, CorruptionCleanupResult>> cleanupCorruptedFiles();

  /// Remove orphaned files that have no metadata references
  Future<Either<CacheFailure, OrphanCleanupResult>> cleanupOrphanedFiles();

  /// Remove files based on age and access patterns
  Future<Either<CacheFailure, AgeBasedCleanupResult>> cleanupByAge({
    Duration maxAge = const Duration(days: 30),
    Duration maxUnusedAge = const Duration(days: 7),
  });

  /// Free up specific amount of space using intelligent selection
  Future<Either<CacheFailure, SpaceOptimizationResult>> freeUpSpace(
    int targetFreeBytes, {
    bool respectReferences = true,
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.leastAccessed,
  });

  /// Remove cache for specific tracks with reference validation
  Future<Either<CacheFailure, Unit>> removeCachedTracks(
    List<String> trackIds, {
    bool respectReferences = true,
    bool forceRemove = false,
  });

  /// Clear all cache with safety checks
  Future<Either<CacheFailure, Unit>> clearAllCache({
    bool skipReferenceCheck = false,
    bool createBackup = false,
  });

  // ===============================================
  // CACHE MANAGEMENT & MONITORING
  // ===============================================

  /// Get detailed information about all cached tracks
  Future<Either<CacheFailure, List<EnhancedCachedTrackInfo>>> getCachedTracks({
    CacheSortOption sortBy = CacheSortOption.lastAccessed,
    bool ascending = false,
    int? limit,
    CacheFilterOptions? filter,
  });

  /// Get cached tracks that match specific criteria
  Future<Either<CacheFailure, List<String>>> getTracksMatchingCriteria(
    CacheSearchCriteria criteria,
  );

  /// Get tracks that are candidates for removal
  Future<Either<CacheFailure, List<CacheRemovalCandidate>>>
  getRemovalCandidates({
    int maxCandidates = 50,
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.leastAccessed,
  });

  /// Analyze cache usage patterns
  Future<Either<CacheFailure, CacheUsageAnalysis>> analyzeCacheUsage();

  // ===============================================
  // STORAGE LIMITS & POLICIES
  // ===============================================

  /// Set storage limit with enhanced options
  Future<Either<CacheFailure, Unit>> setStorageLimit(
    StorageLimit limit, {
    StorageLimitPolicy policy = StorageLimitPolicy.softLimit,
    double warningThreshold = 0.8, // 80%
    double criticalThreshold = 0.95, // 95%
  });

  /// Get current storage limit configuration
  Future<Either<CacheFailure, StorageLimitConfig>> getStorageLimitConfig();

  /// Check current storage limit status
  Future<Either<CacheFailure, StorageLimitStatus>> getStorageLimitStatus();

  /// Set automatic cleanup policy
  Future<Either<CacheFailure, Unit>> setAutoCleanupPolicy(
    AutoCleanupPolicy policy,
  );

  /// Get current automatic cleanup policy
  Future<Either<CacheFailure, AutoCleanupPolicy>> getAutoCleanupPolicy();

  // ===============================================
  // REACTIVE MONITORING
  // ===============================================

  /// Watch storage statistics with configurable update intervals
  Stream<EnhancedStorageStats> watchStorageStats({
    Duration updateInterval = const Duration(minutes: 1),
  });

  /// Watch for storage limit violations
  Stream<StorageLimitViolation> watchStorageLimitViolations();

  /// Watch cache directory changes
  Stream<CacheDirectoryChange> watchCacheDirectoryChanges();

  /// Watch cleanup operations
  Stream<CleanupOperation> watchCleanupOperations();

  // ===============================================
  // VALIDATION & MAINTENANCE
  // ===============================================

  /// Validate cache integrity comprehensively
  Future<Either<CacheFailure, CacheIntegrityReport>> validateCacheIntegrity();

  /// Repair corrupted cache entries
  Future<Either<CacheFailure, CacheRepairResult>> repairCache();

  /// Optimize cache structure and indexing
  Future<Either<CacheFailure, CacheOptimizationResult>> optimizeCache();

  /// Backup cache metadata
  Future<Either<CacheFailure, String>> backupCacheMetadata();

  /// Restore cache metadata from backup
  Future<Either<CacheFailure, Unit>> restoreCacheMetadata(String backupPath);
}

// ===============================================
// ENHANCED DATA STRUCTURES
// ===============================================

/// Enhanced storage statistics with detailed breakdown
class EnhancedStorageStats {
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
}

/// Enhanced cached track information
class EnhancedCachedTrackInfo {
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
}

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

enum CacheSortOption {
  lastAccessed,
  downloadDate,
  fileSize,
  trackName,
  referenceCount,
  accessCount,
}

enum StorageLimitPolicy {
  softLimit, // Warning when approaching limit
  hardLimit, // Prevent new downloads when limit reached
  autoCleanup, // Automatically cleanup when limit reached
  intelligentManagement, // AI-based management
}

// Additional enums and classes would continue here...
// This is a comprehensive foundation for the enhanced storage service
