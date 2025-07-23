import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

/// Use case for synchronizing projects from remote to local cache
///
/// ✅ CLEAN ARCHITECTURE VERSION that follows industry best practices:
/// - Only depends on domain abstractions (no datasources)
/// - Uses intelligent sync decisions via SyncMetadataManager
/// - Leverages complete IncrementalSyncService for all sync operations
/// - Implements patterns used by Notion, Figma, Linear, and other offline-first apps
///
/// Key improvements:
/// ✅ No Clean Architecture violations
/// ✅ Separation of concerns: use case only handles business logic
/// ✅ Infrastructure concerns handled by services
/// ✅ Supports both incremental and full sync modes
/// ✅ Intelligent sync intervals to avoid excessive network usage
/// ✅ Comprehensive error handling and fallback strategies
@lazySingleton
class SyncProjectsUseCase {
  final IncrementalSyncService<ProjectDTO> _incrementalSyncService;
  final SyncMetadataManager _syncMetadataManager;
  final SessionService _sessionService;

  SyncProjectsUseCase(
    this._incrementalSyncService,
    this._syncMetadataManager,
    this._sessionService,
  );

  /// Execute projects synchronization with intelligent sync decisions
  ///
  /// This method implements the complete offline-first sync pattern:
  /// 1. Validates user session
  /// 2. Checks if sync is needed based on intervals
  /// 3. Attempts incremental sync first (efficient)
  /// 4. Falls back to full sync if needed
  /// 5. Updates sync metadata on successful completion
  /// 6. Preserves local data integrity on failures
  Future<void> call({bool force = false}) async {
    // 1. Get current user session
    final sessionResult = await _sessionService.getCurrentSession();
    final session = sessionResult.fold((failure) => null, (session) => session);

    if (session?.currentUser?.id.value == null) {
      return;
    }

    final userId = session!.currentUser!.id.value;

    // 2. Check if sync is needed based on configured intervals
    if (!force && !_syncMetadataManager.shouldSync('projects', userId)) {
      return;
    }

    try {
      // 3. Determine sync strategy and execute
      final lastSyncTime = _syncMetadataManager.getLastSyncTime(
        'projects',
        userId,
      );

      if (lastSyncTime != null && !force) {
        // Attempt incremental sync first
        final incrementalResult = await _attemptIncrementalSync(
          lastSyncTime,
          userId,
        );

        if (incrementalResult) {
          // Incremental sync succeeded
          _syncMetadataManager.updateLastSyncTime('projects', userId);
          return;
        }
      }

      // 4. Fallback to full sync
      await _performFullSync(userId);
      _syncMetadataManager.updateLastSyncTime('projects', userId);
    } catch (e) {
      // Don't update sync metadata on failure - ensures retry on next attempt
      rethrow;
    }
  }

  /// Attempt incremental synchronization
  ///
  /// Returns true if incremental sync succeeded, false if fallback needed.
  /// This method implements the efficient sync pattern used by modern
  /// offline-first applications.
  Future<bool> _attemptIncrementalSync(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      final result = await _incrementalSyncService.performIncrementalSync(
        lastSyncTime,
        userId,
      );

      return result.fold(
        (failure) {
          // Incremental sync failed - will fallback to full sync
          return false;
        },
        (syncResult) {
          // Incremental sync succeeded
          return true;
        },
      );
    } catch (e) {
      // Exception during incremental sync - fallback to full sync
      return false;
    }
  }

  /// Perform full synchronization
  ///
  /// This is the fallback method that replaces the entire local cache
  /// with fresh data from remote. Used when:
  /// - No previous sync exists
  /// - Incremental sync fails
  /// - Force flag is set
  Future<void> _performFullSync(String userId) async {
    final result = await _incrementalSyncService.performFullSync(userId);

    result.fold(
      (failure) => throw Exception('Full sync failed: ${failure.message}'),
      (syncResult) {
        // Full sync completed successfully
        // SyncMetadataManager will be updated by the caller
      },
    );
  }

  /// Get sync statistics for monitoring and debugging
  ///
  /// Returns comprehensive information about sync status for the current user
  Future<Map<String, dynamic>?> getSyncStatistics() async {
    final sessionResult = await _sessionService.getCurrentSession();
    return sessionResult.fold((failure) => null, (session) async {
      final userId = session.currentUser?.id.value;
      if (userId == null) return null;

      // Combine metadata and service statistics
      final metadataStats = _syncMetadataManager.getSyncStatistics(userId);
      final serviceStatsResult = await _incrementalSyncService
          .getSyncStatistics(userId);

      final serviceStats = serviceStatsResult.fold(
        (failure) => <String, dynamic>{},
        (stats) => stats,
      );

      return {
        'metadata': metadataStats,
        'service': serviceStats,
        'combinedAt': DateTime.now().toIso8601String(),
      };
    });
  }

  /// Force reset sync metadata (for testing/debugging)
  ///
  /// This will force the next sync to be a full sync regardless of intervals
  Future<void> resetSyncMetadata() async {
    final sessionResult = await _sessionService.getCurrentSession();
    sessionResult.fold((failure) => null, (session) {
      final userId = session.currentUser?.id.value;
      if (userId != null) {
        _syncMetadataManager.resetSyncTime('projects', userId);
      }
    });
  }

  /// Check if sync should be performed for current user
  ///
  /// Returns true if sync is needed based on intervals and metadata
  Future<bool> shouldSync({bool force = false}) async {
    if (force) return true;

    final sessionResult = await _sessionService.getCurrentSession();
    return sessionResult.fold((failure) => false, (session) {
      final userId = session.currentUser?.id.value;
      if (userId == null) return false;

      return _syncMetadataManager.shouldSync('projects', userId);
    });
  }

  /// Get last sync information for monitoring
  Future<Map<String, dynamic>?> getLastSyncInfo() async {
    final sessionResult = await _sessionService.getCurrentSession();
    return sessionResult.fold((failure) => null, (session) {
      final userId = session.currentUser?.id.value;
      if (userId == null) return null;

      final lastSync = _syncMetadataManager.getLastSyncTime('projects', userId);
      final interval = _syncMetadataManager.getSyncInterval('projects');
      final shouldSyncNow = _syncMetadataManager.shouldSync('projects', userId);

      return {
        'lastSyncTime': lastSync?.toIso8601String(),
        'intervalMinutes': interval,
        'shouldSync': shouldSyncNow,
        'userId': userId,
      };
    });
  }
}
