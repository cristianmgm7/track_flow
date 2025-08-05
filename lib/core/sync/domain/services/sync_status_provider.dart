import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart';
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
/// - Handle sync logic (that's SyncDataManager/PendingOperationsManager's job)
@injectable
class SyncStatusProvider {
  final SyncDataManager _syncDataManager;
  final PendingOperationsManager _pendingOperationsManager;

  SyncStatusProvider({
    required SyncDataManager syncDataManager,
    required PendingOperationsManager pendingOperationsManager,
  }) : _syncDataManager = syncDataManager,
       _pendingOperationsManager = pendingOperationsManager;

  /// Get the current sync state for UI display
  ///
  /// This provides information about:
  /// - Whether sync is in progress
  /// - Sync progress percentage
  /// - Any sync errors
  Future<SyncState> getCurrentSyncState() async {
    final result = await _syncDataManager.getCurrentSyncState();
    return result.fold(
      (failure) => SyncState.error('Failed to get sync state'),
      (syncState) => syncState,
    );
  }

  /// Watch sync state changes for reactive UI updates
  ///
  /// BLoCs can listen to this stream to update UI indicators:
  /// - Show/hide loading spinners
  /// - Update progress bars
  /// - Display sync status messages
  Stream<SyncState> watchSyncState() {
    return _syncDataManager.watchSyncState();
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

  /// Check if sync is currently active
  ///
  /// Convenience method for BLoCs to quickly check sync status
  /// without having to parse the full SyncState object
  Future<bool> get isSyncing async {
    final state = await getCurrentSyncState();
    return state.status == SyncStatus.syncing;
  }

  /// Check if there are pending operations
  ///
  /// Useful for showing offline indicators or "unsaved changes" warnings
  Future<bool> get hasPendingOperations async {
    final count = await getPendingOperationsCount();
    return count > 0;
  }

  /// Get a combined status that considers both downstream sync and pending operations
  ///
  /// This provides a holistic view of sync status:
  /// - If downloading: "Syncing..."
  /// - If has pending: "X items to sync"
  /// - If all good: "Up to date"
  Future<String> get statusMessage async {
    final syncState = await getCurrentSyncState();
    final pendingCount = await getPendingOperationsCount();

    if (syncState.status == SyncStatus.syncing) {
      return 'Syncing... ${(syncState.progress * 100).toInt()}%';
    }

    if (syncState.status == SyncStatus.error) {
      return 'Sync error';
    }

    if (pendingCount > 0) {
      return '$pendingCount item${pendingCount == 1 ? '' : 's'} to sync';
    }

    return 'Up to date';
  }
}
