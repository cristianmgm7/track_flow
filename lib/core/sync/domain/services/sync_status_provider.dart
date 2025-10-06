import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';

/// Provides read-only access to sync status for UI components
///
/// This service is designed specifically for BLoCs and UI components
/// that need to display sync status but should NOT trigger sync operations.
///
/// Key responsibilities:
/// - Expose current sync state for UI display
/// - Stream sync state changes for reactive UI
/// - Provide pending operations count for indicators
///
/// What it does NOT do:
/// - Trigger sync operations (that's BackgroundSyncCoordinator's job)
/// - Handle sync logic (that's SyncCoordinator/PendingOperationsManager's job)
@injectable
class SyncStatusProvider {
  final SyncCoordinator _syncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  // Stream controller for sync state
  final BehaviorSubject<SyncState> _syncStateController =
      BehaviorSubject<SyncState>.seeded(SyncState.initial);

  SyncStatusProvider({
    required SyncCoordinator syncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _syncCoordinator = syncCoordinator,
       _pendingOperationsManager = pendingOperationsManager {
    // Initialize with initial state
    _syncStateController.add(SyncState.initial);
  }

  /// Get count of pending operations for UI badges/indicators
  ///
  /// Useful for showing:
  /// - "X items pending sync" messages
  /// - Offline indicator badges
  /// - Queue status in settings
  Future<int> getPendingOperationsCount() async {
    return await _pendingOperationsManager.getPendingOperationsCount();
  }

  /// Check if there are pending operations
  ///
  /// Useful for showing offline indicators or "unsaved changes" warnings
  Future<bool> get hasPendingOperations async {
    final count = await getPendingOperationsCount();
    return count > 0;
  }

  /// Watch sync state changes for reactive UI updates
  ///
  /// Returns a stream that emits sync state changes
  Stream<SyncState> watchSyncState() {
    return _syncStateController.stream;
  }

  /// Update sync state (called by sync coordinator when sync status changes)
  void updateSyncState(SyncState state) {
    _syncStateController.add(state);
  }

  /// Clean up resources
  void dispose() {
    _syncStateController.close();
  }
}
