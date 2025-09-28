import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';

/// Generic interface for incremental synchronization services
///
/// This interface defines the contract for services that can perform
/// incremental data synchronization with remote sources. Each entity type
/// (Projects, AudioTracks, etc.) should have its own implementation.
///
/// The service focuses specifically on incremental sync operations,
/// avoiding the need to download all data every time.
///
/// Key responsibilities:
/// - Fetch only modified data since last sync
/// - Provide lightweight checks for data changes
/// - Handle server timestamp coordination
/// - Support metadata-only queries for efficiency
abstract class IncrementalSyncService<T> {
  /// Get all items modified since the specified timestamp
  ///
  /// This is the core incremental sync method. It should query the remote
  /// source for entities that have been modified (created, updated, or deleted)
  /// since the provided timestamp.
  ///
  /// [lastSyncTime] - Timestamp of the last successful sync
  /// [userId] - User ID for user-specific data filtering
  ///
  /// Returns:
  /// - Success: List of modified DTOs since lastSyncTime
  /// - Failure: Network, server, or other sync-related failures
  Future<Either<Failure, List<T>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  );

  /// Get the current server timestamp
  ///
  /// This method fetches the authoritative server timestamp to ensure
  /// proper synchronization and avoid clock drift issues between
  /// client and server.
  ///
  /// Returns:
  /// - Success: Current server timestamp
  /// - Failure: Network or server errors
  Future<Either<Failure, DateTime>> getServerTimestamp();

  /// Get metadata for entities (without full content)
  ///
  /// This method fetches only metadata (ID, timestamps, versions) for
  /// entities modified since the specified time. Useful for conflict
  /// detection and lightweight sync operations.
  ///
  /// [lastSyncTime] - Timestamp of the last successful sync
  /// [userId] - User ID for user-specific data filtering
  ///
  /// Returns:
  /// - Success: List of entity metadata
  /// - Failure: Network, server, or other sync-related failures
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  );

  /// Get items that have been deleted since the specified timestamp
  ///
  /// Many systems maintain a separate deleted items collection or use
  /// soft deletes. This method should fetch items that have been deleted
  /// since the last sync to properly remove them from local cache.
  ///
  /// [lastSyncTime] - Timestamp of the last successful sync
  /// [userId] - User ID for user-specific data filtering
  ///
  /// Returns:
  /// - Success: List of IDs of deleted items
  /// - Failure: Network or server errors
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  );

  /// Perform complete incremental sync operation (Fetch + Cache)
  ///
  /// This is the main method that use cases should call for incremental sync.
  /// It handles the entire sync pipeline including local cache updates.
  ///
  /// [lastSyncTime] - Timestamp of the last successful sync
  /// [userId] - User ID for user-specific data filtering
  ///
  /// Returns:
  /// - Success: IncrementalSyncResult with sync statistics
  /// - Failure: Network, server, or cache errors
  Future<Either<Failure, IncrementalSyncResult<T>>> performIncrementalSync(
    DateTime lastSyncTime,
    String userId,
  );

  /// Perform complete full sync operation (Fetch + Cache)
  ///
  /// Fallback method that replaces entire local cache with fresh remote data.
  /// Used when incremental sync fails or no previous sync exists.
  ///
  /// [userId] - User ID for user-specific data filtering
  ///
  /// Returns:
  /// - Success: IncrementalSyncResult with sync statistics
  /// - Failure: Network, server, or cache errors
  Future<Either<Failure, IncrementalSyncResult<T>>> performFullSync(
    String userId,
  );

  /// Get sync statistics for monitoring and debugging
  ///
  /// Returns useful information about the sync service capabilities
  /// and current state for monitoring purposes.
  ///
  /// [userId] - User ID for user-specific statistics
  ///
  /// Returns:
  /// - Success: Map with sync statistics and service info
  /// - Failure: Service or data retrieval errors
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  );
}

/// Lightweight metadata for sync operations
///
/// This class represents minimal information about an entity
/// for sync operations without loading the full entity data.
class EntityMetadata {
  /// Unique identifier of the entity
  final String id;

  /// When the entity was last modified
  final DateTime lastModified;

  /// Version number for optimistic locking
  final int version;

  /// ETag for HTTP caching (if supported)
  final String? etag;

  /// Whether the entity has been deleted
  final bool isDeleted;

  /// Type of the entity (e.g., 'project', 'audio_track')
  final String entityType;

  const EntityMetadata({
    required this.id,
    required this.lastModified,
    required this.version,
    required this.entityType,
    this.etag,
    this.isDeleted = false,
  });

  /// Create metadata from a DTO or entity
  factory EntityMetadata.fromMap(Map<String, dynamic> data, String entityType) {
    return EntityMetadata(
      id: data['id'] ?? '',
      lastModified:
          data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'])
              : DateTime.now(),
      version: data['version'] ?? 1,
      etag: data['etag'],
      isDeleted: data['isDeleted'] ?? false,
      entityType: entityType,
    );
  }

  /// Convert to map for storage or transmission
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastModified': lastModified.toIso8601String(),
      'version': version,
      'etag': etag,
      'isDeleted': isDeleted,
      'entityType': entityType,
    };
  }

  @override
  String toString() {
    return 'EntityMetadata(id: $id, lastModified: $lastModified, version: $version, entityType: $entityType)';
  }
}
