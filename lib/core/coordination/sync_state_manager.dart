import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/coordination/startup_resource_manager.dart';
import 'package:trackflow/core/coordination/sync_state.dart';

/// Manages the state of data synchronization across the app
///
/// This class provides a centralized way to coordinate data syncing
/// and allows other parts of the app to know when sync is complete.
/// It prevents duplicate sync operations and provides progress updates.
@lazySingleton
class SyncStateManager {
  final StartupResourceManager _startupManager;

  // Use BehaviorSubject to always have the latest state available
  final BehaviorSubject<SyncState> _syncStateController =
      BehaviorSubject.seeded(SyncState.initial);

  // Completer to track ongoing sync operations
  Completer<void>? _syncCompleter;

  SyncStateManager(this._startupManager);

  /// Stream of sync state changes
  Stream<SyncState> get syncState => _syncStateController.stream.distinct();

  /// Current sync state
  SyncState get currentState => _syncStateController.value;

  /// Returns true if sync is complete and data is ready to use
  bool get isSyncComplete => currentState.isComplete;

  /// Returns true if sync is currently in progress
  bool get isSyncing => currentState.isSyncing;

  /// Returns true if sync has failed
  bool get hasSyncError => currentState.hasError;

  /// Initializes app data if not already complete or in progress
  /// Returns immediately if sync is already complete
  /// Returns the existing future if sync is already in progress
  Future<void> initializeIfNeeded() async {
    print('🔄 [SyncStateManager] initializeIfNeeded() called');
    print('🔄 [SyncStateManager] Current state: ${currentState.status}');
    print('🔄 [SyncStateManager] isSyncComplete: $isSyncComplete');
    print('🔄 [SyncStateManager] isSyncing: $isSyncing');

    // If sync is already in progress, wait for it to complete
    if (isSyncing && _syncCompleter != null) {
      print('🔄 [SyncStateManager] Sync already in progress, waiting...');
      return _syncCompleter!.future;
    }

    // For hot reload scenarios or fresh starts, always sync
    // Only skip if we have a recent successful sync (within last 2 minutes)
    if (isSyncComplete) {
      final lastSyncTime = currentState.lastSyncTime;
      if (lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
        if (timeSinceLastSync.inMinutes < 2) {
          print(
            '🔄 [SyncStateManager] Sync already complete and recent, skipping',
          );
          return; // Skip if recent sync
        }
      }
    }

    print('🔄 [SyncStateManager] Starting new sync operation');
    // Start new sync operation
    return _performSync();
  }

  /// Forces a fresh sync regardless of current state
  Future<void> forceSync() async {
    print('🔄 [SyncStateManager] forceSync() called');
    return _performSync();
  }

  /// Performs the actual sync operation
  Future<void> _performSync() async {
    print('🔄 [SyncStateManager] _performSync() started');

    // Create new completer for this sync operation
    _syncCompleter = Completer<void>();

    try {
      // Emit syncing state
      print('🔄 [SyncStateManager] Emitting syncing state with 0.1 progress');
      _syncStateController.add(SyncState.syncing(0.1));

      // Perform the actual data sync with progress updates
      print(
        '🔄 [SyncStateManager] Calling StartupResourceManager.initializeAppData()',
      );
      await _startupManager.initializeAppData(
        onProgress: (progress) {
          print(
            '🔄 [SyncStateManager] Progress update: ${(progress * 100).toInt()}%',
          );
          // Update progress during sync
          _syncStateController.add(SyncState.syncing(progress));
        },
      );

      // Emit complete state
      print('🔄 [SyncStateManager] Sync completed successfully');
      _syncStateController.add(SyncState.complete());

      // Complete the future
      _syncCompleter!.complete();
    } catch (e) {
      // Emit error state
      print('❌ [SyncStateManager] Sync failed: $e');
      final errorMessage = 'Sync failed: ${e.toString()}';
      _syncStateController.add(SyncState.error(errorMessage));

      // Complete with error
      _syncCompleter!.completeError(e);

      // Re-throw to allow calling code to handle the error
      rethrow;
    } finally {
      // Clean up completer
      print('🔄 [SyncStateManager] Cleaning up completer');
      _syncCompleter = null;
    }
  }

  /// Resets sync state to initial (useful for testing or logout)
  void reset() {
    print('🔄 [SyncStateManager] reset() called');
    _syncCompleter?.complete();
    _syncCompleter = null;
    _syncStateController.add(SyncState.initial);
  }

  /// Disposes resources
  void dispose() {
    print('🔄 [SyncStateManager] dispose() called');
    _syncCompleter?.complete();
    _syncStateController.close();
  }
}
