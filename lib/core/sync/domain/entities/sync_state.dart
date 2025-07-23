import 'package:equatable/equatable.dart';

/// Represents the current state of data synchronization
///
/// This entity is responsible ONLY for sync information.
/// It does NOT contain any user session data or logic.
class SyncState extends Equatable {
  final SyncStatus status;
  final double progress;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int totalOperations;
  final int completedOperations;

  const SyncState({
    required this.status,
    this.progress = 0.0,
    this.lastSyncTime,
    this.errorMessage,
    this.totalOperations = 0,
    this.completedOperations = 0,
  });

  /// Creates an initial sync state
  static const SyncState initial = SyncState(status: SyncStatus.initial);

  /// Creates a syncing state with progress
  static SyncState syncing(
    double progress, {
    int totalOperations = 0,
    int completedOperations = 0,
  }) => SyncState(
    status: SyncStatus.syncing,
    progress: progress,
    totalOperations: totalOperations,
    completedOperations: completedOperations,
  );

  /// Creates a completed sync state
  static SyncState complete({DateTime? lastSyncTime}) => SyncState(
    status: SyncStatus.complete,
    progress: 1.0,
    lastSyncTime: lastSyncTime ?? DateTime.now(),
    totalOperations: 0,
    completedOperations: 0,
  );

  /// Creates an error sync state
  static SyncState error(String message) =>
      SyncState(status: SyncStatus.error, errorMessage: message);

  /// Returns true if sync is complete and data is ready
  bool get isComplete => status == SyncStatus.complete;

  /// Returns true if sync is currently in progress
  bool get isSyncing => status == SyncStatus.syncing;

  /// Returns true if sync failed
  bool get hasError => status == SyncStatus.error;

  /// Returns true if sync hasn't started yet
  bool get isInitial => status == SyncStatus.initial;

  /// Returns the percentage of operations completed
  double get completionPercentage {
    if (totalOperations == 0) return progress;
    return completedOperations / totalOperations;
  }

  /// Copy with method for state mutations
  SyncState copyWith({
    SyncStatus? status,
    double? progress,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? totalOperations,
    int? completedOperations,
  }) {
    return SyncState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      totalOperations: totalOperations ?? this.totalOperations,
      completedOperations: completedOperations ?? this.completedOperations,
    );
  }

  @override
  String toString() {
    return 'SyncState(status: $status, progress: $progress, error: $errorMessage)';
  }

  @override
  List<Object?> get props => [
    status,
    progress,
    lastSyncTime,
    errorMessage,
    totalOperations,
    completedOperations,
  ];
}

/// Represents the possible states of data synchronization
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
