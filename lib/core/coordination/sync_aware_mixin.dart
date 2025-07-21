import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/coordination/sync_state_manager.dart';
import 'package:trackflow/core/coordination/sync_state.dart';

/// Mixin for BLoCs that need to be aware of sync state
/// 
/// This mixin provides utilities for BLoCs to:
/// - Know when data sync is complete before loading data
/// - React to sync state changes
/// - Prevent race conditions with data loading
mixin SyncAwareMixin<Event, State> on Bloc<Event, State> {
  SyncStateManager? _syncStateManager;
  StreamSubscription<SyncState>? _syncSubscription;

  /// Initialize sync awareness with the provided SyncStateManager
  void initializeSyncAwareness(SyncStateManager syncStateManager) {
    _syncStateManager = syncStateManager;
  }

  /// Returns true if sync is complete and data is ready to use
  bool get isSyncComplete => _syncStateManager?.isSyncComplete ?? false;

  /// Returns true if sync is currently in progress
  bool get isSyncing => _syncStateManager?.isSyncing ?? false;

  /// Returns the current sync state
  SyncState? get syncState => _syncStateManager?.currentState;

  /// Waits for sync to complete before executing the given action
  /// 
  /// If sync is already complete, executes immediately
  /// If sync is in progress, waits for completion
  /// If sync fails, the future completes with an error
  Future<void> waitForSyncThenExecute(Future<void> Function() action) async {
    final syncManager = _syncStateManager;
    if (syncManager == null) {
      // No sync manager, execute immediately
      await action();
      return;
    }

    if (syncManager.isSyncComplete) {
      // Already synced, execute immediately
      await action();
      return;
    }

    if (!syncManager.isSyncing) {
      // Not syncing and not complete, trigger sync first
      await syncManager.initializeIfNeeded();
    }

    // Wait for sync completion
    final completer = Completer<void>();
    late StreamSubscription<SyncState> subscription;
    
    subscription = syncManager.syncState.listen(
      (state) {
        if (state.isComplete) {
          subscription.cancel();
          completer.complete();
        } else if (state.hasError) {
          subscription.cancel();
          completer.completeError(
            Exception('Sync failed: ${state.errorMessage}'),
          );
        }
      },
      onError: (error) {
        subscription.cancel();
        completer.completeError(error);
      },
    );

    await completer.future;
    await action();
  }

  /// Listens to sync state changes and executes callbacks accordingly
  void listenToSyncState({
    void Function()? onSyncStarted,
    void Function(double progress)? onSyncProgress,
    void Function()? onSyncCompleted,
    void Function(String error)? onSyncError,
  }) {
    _syncSubscription?.cancel();
    
    if (_syncStateManager == null) return;

    _syncSubscription = _syncStateManager!.syncState.listen(
      (state) {
        switch (state.status) {
          case SyncStatus.initial:
            break;
          case SyncStatus.syncing:
            if (state.progress == 0.1) {
              onSyncStarted?.call();
            }
            onSyncProgress?.call(state.progress);
            break;
          case SyncStatus.complete:
            onSyncCompleted?.call();
            break;
          case SyncStatus.error:
            onSyncError?.call(state.errorMessage ?? 'Unknown sync error');
            break;
        }
      },
      onError: (error) {
        onSyncError?.call('Sync stream error: $error');
      },
    );
  }

  /// Stops listening to sync state changes
  void stopSyncListening() {
    _syncSubscription?.cancel();
    _syncSubscription = null;
  }

  @override
  Future<void> close() {
    stopSyncListening();
    return super.close();
  }
}