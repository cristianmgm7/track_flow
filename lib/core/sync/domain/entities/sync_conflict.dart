import 'package:equatable/equatable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_metadata.dart';

/// Represents a conflict between local and remote versions of an entity
class SyncConflict<T> extends Equatable {
  /// Unique identifier for this conflict
  final String conflictId;
  
  /// Type of entity in conflict (e.g., 'project', 'audio_track')
  final String entityType;
  
  /// ID of the conflicted entity
  final String entityId;
  
  /// Local version of the entity
  final T localVersion;
  
  /// Remote version of the entity
  final T remoteVersion;
  
  /// Sync metadata for local version
  final SyncMetadata localMetadata;
  
  /// Sync metadata for remote version
  final SyncMetadata remoteMetadata;
  
  /// When this conflict was detected
  final DateTime detectedAt;
  
  /// Type of conflict detected
  final ConflictType conflictType;
  
  /// Whether this conflict has been resolved
  final bool isResolved;
  
  /// Resolution strategy used (if resolved)
  final ConflictResolutionStrategy? resolutionStrategy;
  
  /// Final resolved version (if resolved)
  final T? resolvedVersion;

  const SyncConflict({
    required this.conflictId,
    required this.entityType,
    required this.entityId,
    required this.localVersion,
    required this.remoteVersion,
    required this.localMetadata,
    required this.remoteMetadata,
    required this.detectedAt,
    required this.conflictType,
    this.isResolved = false,
    this.resolutionStrategy,
    this.resolvedVersion,
  });

  /// Create a new conflict
  factory SyncConflict.detected({
    required String entityType,
    required String entityId,
    required T localVersion,
    required T remoteVersion,
    required SyncMetadata localMetadata,
    required SyncMetadata remoteMetadata,
  }) {
    final conflictType = _determineConflictType(localMetadata, remoteMetadata);
    
    return SyncConflict<T>(
      conflictId: '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localMetadata: localMetadata,
      remoteMetadata: remoteMetadata,
      detectedAt: DateTime.now(),
      conflictType: conflictType,
    );
  }

  /// Mark conflict as resolved
  SyncConflict<T> resolve({
    required ConflictResolutionStrategy strategy,
    required T resolvedVersion,
  }) {
    return SyncConflict<T>(
      conflictId: conflictId,
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localMetadata: localMetadata,
      remoteMetadata: remoteMetadata,
      detectedAt: detectedAt,
      conflictType: conflictType,
      isResolved: true,
      resolutionStrategy: strategy,
      resolvedVersion: resolvedVersion,
    );
  }

  /// Determine conflict type based on metadata
  static ConflictType _determineConflictType(
    SyncMetadata localMetadata,
    SyncMetadata remoteMetadata,
  ) {
    if (localMetadata.version == remoteMetadata.version) {
      if (localMetadata.lastModified.isAfter(remoteMetadata.lastModified)) {
        return ConflictType.concurrentModification;
      } else {
        return ConflictType.concurrentModification;
      }
    } else if (localMetadata.version > remoteMetadata.version) {
      return ConflictType.localNewer;
    } else {
      return ConflictType.remoteNewer;
    }
  }

  @override
  List<Object?> get props => [
        conflictId,
        entityType,
        entityId,
        localVersion,
        remoteVersion,
        localMetadata,
        remoteMetadata,
        detectedAt,
        conflictType,
        isResolved,
        resolutionStrategy,
        resolvedVersion,
      ];
}

/// Types of conflicts that can occur
enum ConflictType {
  /// Both local and remote were modified concurrently
  concurrentModification,
  
  /// Local version is newer than remote
  localNewer,
  
  /// Remote version is newer than local
  remoteNewer,
  
  /// Entity was deleted locally but modified remotely
  deletedLocally,
  
  /// Entity was deleted remotely but modified locally
  deletedRemotely,
}

/// Strategies for resolving conflicts
enum ConflictResolutionStrategy {
  /// Use local version
  useLocal,
  
  /// Use remote version
  useRemote,
  
  /// Merge changes from both versions
  merge,
  
  /// Use the version with latest timestamp
  useLatest,
  
  /// Use the version with higher version number
  useHighestVersion,
  
  /// Let user manually resolve
  manual,
}

/// Extension for conflict type display
extension ConflictTypeExtension on ConflictType {
  String get displayName {
    switch (this) {
      case ConflictType.concurrentModification:
        return 'Concurrent Modification';
      case ConflictType.localNewer:
        return 'Local Newer';
      case ConflictType.remoteNewer:
        return 'Remote Newer';
      case ConflictType.deletedLocally:
        return 'Deleted Locally';
      case ConflictType.deletedRemotely:
        return 'Deleted Remotely';
    }
  }
  
  bool get requiresUserInput => this == ConflictType.concurrentModification;
}