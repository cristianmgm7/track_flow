import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/data/services/sync_service.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';

/// Coordinates background sync operations without blocking the UI
///
/// This service manages non-blocking sync operations that are triggered
/// when data is accessed (cache-aside pattern) or when network connectivity
/// is restored. It prevents duplicate sync operations and ensures sync
/// happens intelligently based on network conditions.
@lazySingleton
class BackgroundSyncCoordinator {
  final NetworkStateManager _networkStateManager;
  final SyncService _syncService;
  final PendingOperationsManager _pendingOperationsManager;

  // Track ongoing background sync operations
  final Set<String> _ongoingSyncs = {};

  // Subscription to network changes for auto-sync
  StreamSubscription<bool>? _networkSubscription;

  BackgroundSyncCoordinator(
    this._networkStateManager,
    this._syncService,
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

  /// Perform the actual background sync operation
  Future<void> _performBackgroundSync(String syncKey) async {
    try {
      // Only proceed if we have good network connection
      if (!await _networkStateManager.hasGoodConnection()) {
        return;
      }

      // 1. Process pending operations first
      await _pendingOperationsManager.processPendingOperations();

      // 2. Perform the sync using SyncService
      await _syncService.triggerBackgroundSync();
    } catch (e) {
      // Log error but don't throw - this is background operation
      // TODO: Replace with proper logging framework
      // print('BackgroundSyncCoordinator: Background sync failed for $syncKey: $e');
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
    // Log error but don't propagate - TODO: Use proper logging
    // print('Unawaited future error: $error');
  });
}
