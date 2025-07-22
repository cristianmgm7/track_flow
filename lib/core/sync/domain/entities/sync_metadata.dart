import 'package:equatable/equatable.dart';

/// Sync metadata attached to entities for conflict resolution
/// 
/// Contains version information and sync status to handle
/// offline changes and conflicts when syncing with remote.
class SyncMetadata extends Equatable {
  /// Version number for optimistic locking
  final int version;
  
  /// Timestamp when entity was last modified locally
  final DateTime lastModified;
  
  /// Timestamp when entity was last successfully synced
  final DateTime? lastSyncTime;
  
  /// Whether this entity needs to be synced to remote
  final bool needsSync;
  
  /// Current sync status
  final SyncStatus syncStatus;
  
  /// Number of sync retry attempts
  final int retryCount;
  
  /// Error message if sync failed
  final String? syncError;

  const SyncMetadata({
    required this.version,
    required this.lastModified,
    this.lastSyncTime,
    required this.needsSync,
    required this.syncStatus,
    this.retryCount = 0,
    this.syncError,
  });

  /// Create initial sync metadata for new entity
  factory SyncMetadata.initial() {
    return SyncMetadata(
      version: 1,
      lastModified: DateTime.now(),
      needsSync: true,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Create sync metadata for entity received from remote
  factory SyncMetadata.fromRemote({
    required int version,
    required DateTime lastModified,
  }) {
    return SyncMetadata(
      version: version,
      lastModified: lastModified,
      lastSyncTime: DateTime.now(),
      needsSync: false,
      syncStatus: SyncStatus.synced,
    );
  }

  /// Mark entity as modified and needing sync
  SyncMetadata markAsModified() {
    return copyWith(
      version: version + 1,
      lastModified: DateTime.now(),
      needsSync: true,
      syncStatus: SyncStatus.pending,
      syncError: null,
      retryCount: 0,
    );
  }

  /// Mark sync as successful
  SyncMetadata markAsSynced({int? newVersion}) {
    return copyWith(
      version: newVersion ?? version,
      lastSyncTime: DateTime.now(),
      needsSync: false,
      syncStatus: SyncStatus.synced,
      syncError: null,
      retryCount: 0,
    );
  }

  /// Mark sync as failed
  SyncMetadata markAsFailed(String error) {
    return copyWith(
      syncStatus: SyncStatus.error,
      syncError: error,
      retryCount: retryCount + 1,
    );
  }

  /// Mark entity as having conflict
  SyncMetadata markAsConflicted(String error) {
    return copyWith(
      syncStatus: SyncStatus.conflict,
      syncError: error,
    );
  }

  SyncMetadata copyWith({
    int? version,
    DateTime? lastModified,
    DateTime? lastSyncTime,
    bool? needsSync,
    SyncStatus? syncStatus,
    int? retryCount,
    String? syncError,
  }) {
    return SyncMetadata(
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      needsSync: needsSync ?? this.needsSync,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  List<Object?> get props => [
        version,
        lastModified,
        lastSyncTime,
        needsSync,
        syncStatus,
        retryCount,
        syncError,
      ];
}

/// Sync status enumeration
enum SyncStatus {
  /// Entity is pending sync to remote
  pending,
  
  /// Entity is currently being synced
  syncing,
  
  /// Entity is successfully synced
  synced,
  
  /// Sync failed with error
  error,
  
  /// Sync conflict detected
  conflict,
  
  /// Entity is merged from conflict resolution
  merged,
}

/// Extension to get display string for sync status
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.merged:
        return 'Merged';
    }
  }
  
  bool get isErrorState => this == SyncStatus.error || this == SyncStatus.conflict;
  bool get needsAttention => isErrorState;
  bool get canRetry => this == SyncStatus.error;
}