/// Result of an incremental sync operation
///
/// This class encapsulates the results of an incremental sync,
/// including the synced data and metadata about the operation.
class IncrementalSyncResult<T> {
  /// Items that were added or updated
  final List<T> modifiedItems;

  /// IDs of items that were deleted
  final List<String> deletedItemIds;

  /// Server timestamp when sync was performed
  final DateTime serverTimestamp;

  /// Whether this was a full sync (fallback) or incremental
  final bool wasFullSync;

  /// Number of items processed
  final int totalProcessed;

  const IncrementalSyncResult({
    required this.modifiedItems,
    required this.deletedItemIds,
    required this.serverTimestamp,
    this.wasFullSync = false,
    required this.totalProcessed,
  });

  /// Check if any changes were found
  bool get hasChanges => modifiedItems.isNotEmpty || deletedItemIds.isNotEmpty;

  /// Get total number of changes
  int get totalChanges => modifiedItems.length + deletedItemIds.length;

  @override
  String toString() {
    return 'IncrementalSyncResult(modified: ${modifiedItems.length}, deleted: ${deletedItemIds.length}, total: $totalProcessed, fullSync: $wasFullSync)';
  }
}
