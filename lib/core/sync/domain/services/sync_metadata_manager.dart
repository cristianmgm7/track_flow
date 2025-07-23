import 'package:injectable/injectable.dart';

/// Manages sync metadata and timestamps for incremental synchronization
///
/// This service is responsible for tracking when entities were last synced
/// to enable efficient incremental sync operations. It stores timestamps
/// per entity type and user to support multi-user scenarios.
///
/// Key responsibilities:
/// - Track last sync timestamps per entity type/user
/// - Determine if sync is needed based on minimum intervals
/// - Provide sync statistics and monitoring capabilities
/// - Support entity-specific sync tracking
@lazySingleton
class SyncMetadataManager {
  // In-memory cache for sync timestamps
  // Structure: entityType_userId -> DateTime
  final Map<String, DateTime> _lastSyncTimes = {};

  // Minimum intervals between syncs (in minutes)
  static const Map<String, int> _syncIntervals = {
    'projects': 5, // 5 minutes for projects
    'audio_tracks': 10, // 10 minutes for tracks
    'audio_comments': 15, // 15 minutes for comments
    'user_profile': 30, // 30 minutes for profile
    'collaborators': 20, // 20 minutes for collaborators
  };

  /// Get the last sync timestamp for a specific entity type and user
  ///
  /// Returns null if no sync has been performed yet for this combination.
  DateTime? getLastSyncTime(String entityType, String userId) {
    final key = _buildKey(entityType, userId);
    return _lastSyncTimes[key];
  }

  /// Update the last sync timestamp for a specific entity type and user
  ///
  /// This should be called after a successful sync operation completes.
  void updateLastSyncTime(
    String entityType,
    String userId, {
    DateTime? timestamp,
  }) {
    final key = _buildKey(entityType, userId);
    _lastSyncTimes[key] = timestamp ?? DateTime.now();
  }

  /// Check if sync should be performed based on minimum intervals
  ///
  /// Returns true if:
  /// - No previous sync has been performed
  /// - Minimum interval has passed since last sync
  /// - Force parameter is true
  bool shouldSync(String entityType, String userId, {bool force = false}) {
    if (force) return true;

    final lastSync = getLastSyncTime(entityType, userId);
    if (lastSync == null) return true;

    final minInterval = _syncIntervals[entityType] ?? 10; // Default 10 minutes
    final now = DateTime.now();
    final timeSinceLastSync = now.difference(lastSync);

    return timeSinceLastSync.inMinutes >= minInterval;
  }

  /// Get all entity types that need sync for a specific user
  ///
  /// Returns a list of entity types that should be synced based on
  /// their minimum intervals or if they've never been synced.
  List<String> getEntityTypesNeedingSync(String userId, {bool force = false}) {
    return _syncIntervals.keys
        .where((entityType) => shouldSync(entityType, userId, force: force))
        .toList();
  }

  /// Get sync statistics for monitoring and debugging
  ///
  /// Returns information about sync times, intervals, and status
  /// for all tracked entity types for a specific user.
  Map<String, dynamic> getSyncStatistics(String userId) {
    final stats = <String, dynamic>{};

    for (final entityType in _syncIntervals.keys) {
      final lastSync = getLastSyncTime(entityType, userId);
      final needsSync = shouldSync(entityType, userId);
      final minInterval = _syncIntervals[entityType]!;

      stats[entityType] = {
        'lastSyncTime': lastSync?.toIso8601String(),
        'needsSync': needsSync,
        'minIntervalMinutes': minInterval,
        'timeSinceLastSyncMinutes':
            lastSync != null
                ? DateTime.now().difference(lastSync).inMinutes
                : null,
      };
    }

    return stats;
  }

  /// Reset sync metadata for a specific entity type and user
  ///
  /// This will force the next sync to be a full sync.
  /// Useful for testing or when data integrity issues are detected.
  void resetSyncTime(String entityType, String userId) {
    final key = _buildKey(entityType, userId);
    _lastSyncTimes.remove(key);
  }

  /// Reset all sync metadata for a specific user
  ///
  /// This will force all entity types to perform full sync on next attempt.
  /// Typically used during logout or user switching.
  void resetAllSyncTimes(String userId) {
    final keysToRemove =
        _lastSyncTimes.keys.where((key) => key.endsWith('_$userId')).toList();

    for (final key in keysToRemove) {
      _lastSyncTimes.remove(key);
    }
  }

  /// Get the minimum sync interval for an entity type
  ///
  /// Returns the configured minimum interval in minutes,
  /// or a default value if not configured.
  int getSyncInterval(String entityType) {
    return _syncIntervals[entityType] ?? 10;
  }

  /// Check if any entity type needs sync for a user
  ///
  /// Returns true if at least one entity type should be synced.
  bool hasEntityNeedingSync(String userId, {bool force = false}) {
    return getEntityTypesNeedingSync(userId, force: force).isNotEmpty;
  }

  /// Build internal key for storing sync metadata
  String _buildKey(String entityType, String userId) {
    return '${entityType}_$userId';
  }

  /// Get all tracked entity types
  List<String> get supportedEntityTypes => _syncIntervals.keys.toList();

  /// Clear all sync metadata (for testing purposes)
  void clearAll() {
    _lastSyncTimes.clear();
  }
}
