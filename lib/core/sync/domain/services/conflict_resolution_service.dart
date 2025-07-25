import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_conflict.dart';
import 'package:trackflow/core/sync/domain/entities/sync_metadata.dart';

/// Abstract interface for conflict resolution
abstract class ConflictResolutionService<T> {
  /// Detect if there's a conflict between local and remote versions
  Future<SyncConflict<T>?> detectConflict({
    required String entityType,
    required String entityId,
    required T localVersion,
    required T remoteVersion,
    required SyncMetadata localMetadata,
    required SyncMetadata remoteMetadata,
  });

  /// Resolve conflict using specified strategy
  Future<T> resolveConflict({
    required SyncConflict<T> conflict,
    required ConflictResolutionStrategy strategy,
  });

  /// Auto-resolve conflict using best strategy for entity type
  Future<T?> autoResolveConflict(SyncConflict<T> conflict);
}

/// Generic implementation of conflict resolution service
@lazySingleton
class ConflictResolutionServiceImpl<T> implements ConflictResolutionService<T> {
  @override
  Future<SyncConflict<T>?> detectConflict({
    required String entityType,
    required String entityId,
    required T localVersion,
    required T remoteVersion,
    required SyncMetadata localMetadata,
    required SyncMetadata remoteMetadata,
  }) async {
    // No conflict if local doesn't need sync
    if (!localMetadata.needsSync) {
      return null;
    }

    // No conflict if versions are compatible
    if (localMetadata.version == remoteMetadata.version &&
        localMetadata.lastModified.isBefore(remoteMetadata.lastModified)) {
      return null;
    }

    // Conflict detected - create conflict object
    return SyncConflict<T>.detected(
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localMetadata: localMetadata,
      remoteMetadata: remoteMetadata,
    );
  }

  @override
  Future<T> resolveConflict({
    required SyncConflict<T> conflict,
    required ConflictResolutionStrategy strategy,
  }) async {
    switch (strategy) {
      case ConflictResolutionStrategy.useLocal:
        return conflict.localVersion;

      case ConflictResolutionStrategy.useRemote:
        return conflict.remoteVersion;

      case ConflictResolutionStrategy.useLatest:
        final useLocal = conflict.localMetadata.lastModified.isAfter(
          conflict.remoteMetadata.lastModified,
        );
        return useLocal ? conflict.localVersion : conflict.remoteVersion;

      case ConflictResolutionStrategy.useHighestVersion:
        final useLocal =
            conflict.localMetadata.version > conflict.remoteMetadata.version;
        return useLocal ? conflict.localVersion : conflict.remoteVersion;

      case ConflictResolutionStrategy.merge:
        return await _performMerge(conflict);

      case ConflictResolutionStrategy.manual:
        throw UnsupportedError('Manual resolution requires user input');
    }
  }

  @override
  Future<T?> autoResolveConflict(SyncConflict<T> conflict) async {
    // Auto-resolution strategy based on conflict type
    switch (conflict.conflictType) {
      case ConflictType.localNewer:
        return await resolveConflict(
          conflict: conflict,
          strategy: ConflictResolutionStrategy.useLocal,
        );

      case ConflictType.remoteNewer:
        return await resolveConflict(
          conflict: conflict,
          strategy: ConflictResolutionStrategy.useRemote,
        );

      case ConflictType.concurrentModification:
        // For concurrent modifications, use latest timestamp
        return await resolveConflict(
          conflict: conflict,
          strategy: ConflictResolutionStrategy.useLatest,
        );

      case ConflictType.deletedLocally:
      case ConflictType.deletedRemotely:
        // Deletion conflicts require manual resolution
        return null;
    }
  }

  /// Perform merge operation (can be overridden by specific implementations)
  Future<T> _performMerge(SyncConflict<T> conflict) async {
    // Default merge strategy: use latest timestamp
    // Subclasses can override this for entity-specific merge logic
    return await resolveConflict(
      conflict: conflict,
      strategy: ConflictResolutionStrategy.useLatest,
    );
  }
}

/// Project-specific conflict resolution service
@lazySingleton
class ProjectConflictResolutionService
    extends ConflictResolutionServiceImpl<dynamic> {
  @override
  Future<dynamic> _performMerge(SyncConflict<dynamic> conflict) async {
    // Project-specific merge logic
    final local = conflict.localVersion as Map<String, dynamic>;
    final remote = conflict.remoteVersion as Map<String, dynamic>;

    // Create merged version by combining non-conflicting fields
    final merged = Map<String, dynamic>.from(remote);

    // Merge strategy for projects:
    // - Use latest name and description
    // - Merge collaborator lists
    // - Use latest dates

    if (conflict.localMetadata.lastModified.isAfter(
      conflict.remoteMetadata.lastModified,
    )) {
      merged['name'] = local['name'];
      merged['description'] = local['description'];
    }

    // Merge collaborator IDs (union of both sets)
    final localCollaborators = Set<String>.from(local['collaboratorIds'] ?? []);
    final remoteCollaborators = Set<String>.from(
      remote['collaboratorIds'] ?? [],
    );
    merged['collaboratorIds'] =
        localCollaborators.union(remoteCollaborators).toList();

    // Use latest modification time
    final latestModified =
        conflict.localMetadata.lastModified.isAfter(
              conflict.remoteMetadata.lastModified,
            )
            ? conflict.localMetadata.lastModified
            : conflict.remoteMetadata.lastModified;

    merged['updatedAt'] = latestModified.toIso8601String();

    return merged;
  }
}

/// Audio Track conflict resolution service
@lazySingleton
class AudioTrackConflictResolutionService
    extends ConflictResolutionServiceImpl<dynamic> {
  @override
  Future<dynamic> _performMerge(SyncConflict<dynamic> conflict) async {
    // Audio track specific merge logic
    final local = conflict.localVersion as Map<String, dynamic>;
    final remote = conflict.remoteVersion as Map<String, dynamic>;

    final merged = Map<String, dynamic>.from(remote);

    // For audio tracks, prefer local changes for metadata but keep remote file info
    if (conflict.localMetadata.lastModified.isAfter(
      conflict.remoteMetadata.lastModified,
    )) {
      merged['name'] = local['name'];
      merged['description'] = local['description'];
      // Keep remote file URL and duration as they're authoritative
    }

    return merged;
  }
}
