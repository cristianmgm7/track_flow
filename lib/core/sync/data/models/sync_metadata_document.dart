import 'package:isar/isar.dart';
import 'package:trackflow/core/sync/domain/entities/sync_metadata.dart';

part 'sync_metadata_document.g.dart';

/// Isar embedded document for sync metadata
@embedded
class SyncMetadataDocument {
  /// Version number for optimistic locking
  late int version;
  
  /// Timestamp when entity was last modified locally
  late DateTime lastModified;
  
  /// Timestamp when entity was last successfully synced
  DateTime? lastSyncTime;
  
  /// Whether this entity needs to be synced to remote
  late bool needsSync;
  
  /// Current sync status as string
  late String syncStatus;
  
  /// Number of sync retry attempts
  late int retryCount;
  
  /// Error message if sync failed
  String? syncError;

  SyncMetadataDocument();

  /// Create from domain entity
  factory SyncMetadataDocument.fromDomain(SyncMetadata metadata) {
    return SyncMetadataDocument()
      ..version = metadata.version
      ..lastModified = metadata.lastModified
      ..lastSyncTime = metadata.lastSyncTime
      ..needsSync = metadata.needsSync
      ..syncStatus = metadata.syncStatus.name
      ..retryCount = metadata.retryCount
      ..syncError = metadata.syncError;
  }

  /// Create initial sync metadata document
  factory SyncMetadataDocument.initial() {
    return SyncMetadataDocument()
      ..version = 1
      ..lastModified = DateTime.now()
      ..needsSync = true
      ..syncStatus = SyncStatus.pending.name
      ..retryCount = 0;
  }

  /// Create for entity from remote
  factory SyncMetadataDocument.fromRemote({
    required int version,
    required DateTime lastModified,
  }) {
    return SyncMetadataDocument()
      ..version = version
      ..lastModified = lastModified
      ..lastSyncTime = DateTime.now()
      ..needsSync = false
      ..syncStatus = SyncStatus.synced.name
      ..retryCount = 0;
  }

  /// Convert to domain entity
  SyncMetadata toDomain() {
    return SyncMetadata(
      version: version,
      lastModified: lastModified,
      lastSyncTime: lastSyncTime,
      needsSync: needsSync,
      syncStatus: _parseSyncStatus(syncStatus),
      retryCount: retryCount,
      syncError: syncError,
    );
  }

  /// Update with domain changes
  void updateFromDomain(SyncMetadata metadata) {
    version = metadata.version;
    lastModified = metadata.lastModified;
    lastSyncTime = metadata.lastSyncTime;
    needsSync = metadata.needsSync;
    syncStatus = metadata.syncStatus.name;
    retryCount = metadata.retryCount;
    syncError = metadata.syncError;
  }

  /// Parse sync status from string
  SyncStatus _parseSyncStatus(String status) {
    return SyncStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => SyncStatus.pending,
    );
  }

  /// Mark as modified and needing sync
  void markAsModified() {
    version = version + 1;
    lastModified = DateTime.now();
    needsSync = true;
    syncStatus = SyncStatus.pending.name;
    syncError = null;
    retryCount = 0;
  }

  /// Mark sync as successful
  void markAsSynced({int? newVersion}) {
    version = newVersion ?? version;
    lastSyncTime = DateTime.now();
    needsSync = false;
    syncStatus = SyncStatus.synced.name;
    syncError = null;
    retryCount = 0;
  }

  /// Mark sync as failed
  void markAsFailed(String error) {
    syncStatus = SyncStatus.error.name;
    syncError = error;
    retryCount = retryCount + 1;
  }

  /// Mark entity as having conflict
  void markAsConflicted(String error) {
    syncStatus = SyncStatus.conflict.name;
    syncError = error;
  }
}