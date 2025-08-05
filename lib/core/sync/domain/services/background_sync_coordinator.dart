import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Coordinates unified background sync operations without blocking the UI
///
/// This coordinator manages the complete offline-first sync architecture:
/// 1. UPSTREAM SYNC: Pending local changes → Remote (via PendingOperationsManager)
/// 2. DOWNSTREAM SYNC: Remote data → Local cache (via SyncDataManager)
///
/// It prevents duplicate sync operations and ensures sync happens intelligently
/// based on network conditions. Operations are non-blocking and fire-and-forget.
@lazySingleton
class BackgroundSyncCoordinator {
  final NetworkStateManager _networkStateManager;
  final SyncDataManager _syncDataManager;
  final PendingOperationsManager _pendingOperationsManager;

  // Track ongoing background sync operations
  final Set<String> _ongoingSyncs = {};

  // Subscription to network changes for auto-sync
  StreamSubscription<bool>? _networkSubscription;

  BackgroundSyncCoordinator(
    this._networkStateManager,
    this._syncDataManager,
    this._pendingOperationsManager,
  ) {
    _initializeNetworkListener();
  }

  /// Triggers a background sync operation if conditions are met
  ///
  /// This is the main method called by repositories when implementing
  /// the cache-aside pattern. It ensures sync happens in background
  /// without blocking data access.
  Future<void> triggerBackgroundSync({
    String syncKey = 'general',
    bool force = false,
  }) async {
    // Skip if sync is already in progress for this key
    if (_ongoingSyncs.contains(syncKey) && !force) {
      return;
    }

    // Skip if no network connection
    if (!await _networkStateManager.isConnected) {
      return;
    }

    // Mark this sync operation as ongoing
    _ongoingSyncs.add(syncKey);

    try {
      // Perform background sync (fire and forget)
      unawaited(_performBackgroundSync(syncKey));
    } catch (e) {
      // Remove from ongoing syncs if immediate error
      _ongoingSyncs.remove(syncKey);
    }
  }

  /// Triggers only UPSTREAM sync (pending operations) without downstream
  ///
  /// Use this when you only need to push local changes to the server
  /// without pulling fresh data. Much more efficient for simple operations
  /// like creating/updating projects.
  Future<void> triggerUpstreamSync({
    String syncKey = 'upstream_only',
    bool force = false,
  }) async {
    // Skip if sync is already in progress for this key
    if (_ongoingSyncs.contains(syncKey) && !force) {
      return;
    }

    // Skip if no network connection
    if (!await _networkStateManager.isConnected) {
      return;
    }

    // Mark this sync operation as ongoing
    _ongoingSyncs.add(syncKey);

    try {
      // Perform only upstream sync (fire and forget)
      unawaited(_performUpstreamSync(syncKey));
    } catch (e) {
      // Remove from ongoing syncs if immediate error
      _ongoingSyncs.remove(syncKey);
    }
  }

  /// Triggers sync when network connectivity is restored
  ///
  /// This method is automatically called when the device
  /// regains network connectivity after being offline.
  Future<void> triggerConnectivitySync() async {
    await triggerBackgroundSync(syncKey: 'connectivity_restored', force: true);
  }

  /// Force a full background sync regardless of current state
  ///
  /// Useful for pull-to-refresh or user-initiated sync operations
  Future<void> forceBackgroundSync() async {
    await triggerBackgroundSync(syncKey: 'forced', force: true);
  }

  /// Check if any background sync is currently in progress
  bool get hasPendingSync => _ongoingSyncs.isNotEmpty;

  /// Get list of currently ongoing sync operations
  List<String> get ongoingSyncKeys => _ongoingSyncs.toList();

  /// Initialize network connectivity listener for auto-sync
  void _initializeNetworkListener() {
    _networkSubscription = _networkStateManager.onConnectivityChanged.listen((
      bool isConnected,
    ) async {
      if (isConnected) {
        // Network restored - trigger sync after a brief delay
        // to allow network to stabilize
        await Future.delayed(const Duration(milliseconds: 1500));
        await triggerConnectivitySync();
      }
    });
  }

  /// Perform the actual unified background sync operation
  ///
  /// This method executes the complete offline-first sync cycle:
  /// 1. UPSTREAM: Push pending local changes to remote
  /// 2. DOWNSTREAM: Pull fresh data from remote to local cache
  Future<void> _performBackgroundSync(String syncKey) async {
    try {
      // Only proceed if we have good network connection
      if (!await _networkStateManager.hasGoodConnection()) {
        AppLogger.warning(
          'Skipping sync ($syncKey) - poor network connection',
          tag: 'BackgroundSyncCoordinator',
        );
        return;
      }

      AppLogger.sync('INIT', 'Starting background sync', syncKey: syncKey);

      // PHASE 1: UPSTREAM SYNC - Push pending local changes first
      // This ensures local changes are preserved before pulling fresh data
      AppLogger.sync(
        'UPSTREAM',
        'Starting upstream sync (pending operations)',
        syncKey: syncKey,
      );
      final upstreamStartTime = DateTime.now();

      await _pendingOperationsManager.processPendingOperations();

      final upstreamDuration = DateTime.now().difference(upstreamStartTime);
      AppLogger.sync(
        'UPSTREAM',
        'Upstream sync completed',
        syncKey: syncKey,
        duration: upstreamDuration.inMilliseconds,
      );

      // PHASE 2: DOWNSTREAM SYNC - Pull fresh data from remote
      // This updates local cache with latest remote data
      AppLogger.sync(
        'DOWNSTREAM',
        'Starting downstream sync (remote → local)',
        syncKey: syncKey,
      );
      final downstreamStartTime = DateTime.now();

      final syncResult = await _syncDataManager.performIncrementalSync();

      final downstreamDuration = DateTime.now().difference(downstreamStartTime);

      // Log sync result (but don't throw on failure - this is background)
      syncResult.fold(
        (failure) {
          AppLogger.sync(
            'DOWNSTREAM',
            'Downstream sync failed: ${failure.message}',
            syncKey: syncKey,
            duration: downstreamDuration.inMilliseconds,
          );
        },
        (_) {
          AppLogger.sync(
            'DOWNSTREAM',
            'Downstream sync completed',
            syncKey: syncKey,
            duration: downstreamDuration.inMilliseconds,
          );
          AppLogger.sync(
            'COMPLETE',
            'Full background sync completed successfully',
            syncKey: syncKey,
          );
        },
      );
    } catch (e) {
      // Log error but don't throw - this is background operation
      AppLogger.error(
        'Background sync failed: $e',
        tag: 'BackgroundSyncCoordinator',
        error: e,
      );
      // TODO: Send to error monitoring service
      // ErrorMonitoringService.reportError(e, context: 'background_sync_failure', syncKey: syncKey);
    } finally {
      // Always remove from ongoing syncs
      _ongoingSyncs.remove(syncKey);
    }
  }

  /// Perform only UPSTREAM sync (pending operations)
  ///
  /// This method is used to push local changes to the server
  /// without pulling fresh data.
  Future<void> _performUpstreamSync(String syncKey) async {
    try {
      // Only proceed if we have good network connection
      if (!await _networkStateManager.hasGoodConnection()) {
        AppLogger.warning(
          'Skipping upstream sync ($syncKey) - poor network connection',
          tag: 'BackgroundSyncCoordinator',
        );
        return;
      }

      AppLogger.sync('INIT', 'Starting upstream sync only', syncKey: syncKey);

      // PHASE 1: UPSTREAM SYNC - Push pending local changes first
      // This ensures local changes are preserved before pulling fresh data
      AppLogger.sync(
        'UPSTREAM',
        'Starting upstream sync (pending operations)',
        syncKey: syncKey,
      );
      final upstreamStartTime = DateTime.now();

      await _pendingOperationsManager.processPendingOperations();

      final upstreamDuration = DateTime.now().difference(upstreamStartTime);
      AppLogger.sync(
        'UPSTREAM',
        'Upstream sync completed',
        syncKey: syncKey,
        duration: upstreamDuration.inMilliseconds,
      );
      AppLogger.sync(
        'COMPLETE',
        'Upstream sync only completed successfully',
        syncKey: syncKey,
      );
    } catch (e) {
      // Log error but don't throw - this is background operation
      AppLogger.error(
        'Upstream sync failed: $e',
        tag: 'BackgroundSyncCoordinator',
        error: e,
      );
      // TODO: Send to error monitoring service
      // ErrorMonitoringService.reportError(e, context: 'upstream_sync_failure', syncKey: syncKey);
    } finally {
      // Always remove from ongoing syncs
      _ongoingSyncs.remove(syncKey);
    }
  }

  /// Clean up resources
  void dispose() {
    _networkSubscription?.cancel();
    _ongoingSyncs.clear();
  }
}

/// Helper extension to fire-and-forget futures safely
extension FireAndForget on Future {
  void get unawaited => catchError((error) {
    // Log error but don't propagate
    AppLogger.warning('Unawaited future error: $error', tag: 'FireAndForget');
  });
}
