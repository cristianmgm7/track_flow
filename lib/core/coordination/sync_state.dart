/// Represents the current state of data synchronization in the app
enum SyncStatus {
  /// App has not started syncing data yet
  initial,
  
  /// Data synchronization is in progress
  syncing,
  
  /// Data synchronization completed successfully
  complete,
  
  /// Data synchronization failed
  error,
}

/// Detailed information about the sync state
class SyncState {
  final SyncStatus status;
  final double progress;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const SyncState({
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
    this.lastSyncTime,
  });

  /// Creates an initial sync state
  static const SyncState initial = SyncState(status: SyncStatus.initial);

  /// Creates a syncing state with progress
  static SyncState syncing(double progress) => SyncState(
        status: SyncStatus.syncing,
        progress: progress,
      );

  /// Creates a completed sync state
  static SyncState complete() => SyncState(
        status: SyncStatus.complete,
        progress: 1.0,
        lastSyncTime: DateTime.now(),
      );

  /// Creates an error sync state
  static SyncState error(String message) => SyncState(
        status: SyncStatus.error,
        errorMessage: message,
      );

  /// Returns true if sync is complete and data is ready
  bool get isComplete => status == SyncStatus.complete;

  /// Returns true if sync is currently in progress
  bool get isSyncing => status == SyncStatus.syncing;

  /// Returns true if sync failed
  bool get hasError => status == SyncStatus.error;

  /// Returns true if sync hasn't started yet
  bool get isInitial => status == SyncStatus.initial;

  @override
  String toString() {
    return 'SyncState(status: $status, progress: $progress, error: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncState &&
        other.status == status &&
        other.progress == progress &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return status.hashCode ^ progress.hashCode ^ errorMessage.hashCode;
  }
}