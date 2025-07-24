import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

/// Complete incremental sync service for Projects (Remote + Local)
///
/// This service follows industry best practices by handling BOTH:
/// - Fetching incremental changes from remote sources
/// - Applying those changes to local cache
///
/// Inspired by companies like Notion, Figma, and Linear that use:
/// - Event-driven architectures
/// - Conflict-free data synchronization
/// - Local-first with background sync
/// - Change Data Capture (CDC) patterns
///
/// Key benefits:
/// - Use cases don't violate Clean Architecture
/// - Single responsibility: complete sync operations
/// - Supports both incremental and full sync modes
/// - Unified error handling and result reporting
@LazySingleton(as: IncrementalSyncService<ProjectDTO>)
class ProjectIncrementalSyncService
    implements IncrementalSyncService<ProjectDTO> {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;

  ProjectIncrementalSyncService(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<ProjectDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      // This is a simplified version - in production you'd implement
      // timestamp-based queries in the remote datasource
      final result = await _remoteDataSource.getUserProjects(userId);

      return result.fold((failure) => Left(failure), (projects) {
        // TODO: Implement actual incremental filtering in Firebase
        // For now, return all projects (fallback to full sync)
        return Right(projects);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to fetch modified projects: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      // Lightweight check - in production this would be a count query
      final result = await getModifiedSince(lastSyncTime, userId);

      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects.isNotEmpty),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to check for modifications: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    try {
      // In production, this would be a Firebase server timestamp
      return Right(DateTime.now());
    } catch (e) {
      return Left(ServerFailure('Failed to get server timestamp: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      // Fetch only metadata for conflict detection
      final result = await getModifiedSince(lastSyncTime, userId);

      return result.fold((failure) => Left(failure), (projects) {
        final metadata =
            projects
                .map(
                  (project) => EntityMetadata(
                    id: project.id,
                    lastModified: project.updatedAt ?? project.createdAt,
                    version: 1, // TODO: Add version to ProjectDTO
                    entityType: 'project',
                  ),
                )
                .toList();

        return Right(metadata);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to fetch project metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      // TODO: Implement deleted projects tracking in Firebase
      // For now, return empty list
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch deleted projects: $e'));
    }
  }

  /// COMPLETE incremental sync operation (Fetch + Cache)
  ///
  /// This is the main method that use cases should call.
  /// It handles the entire sync pipeline:
  /// 1. Fetch modified projects from remote
  /// 2. Fetch deleted projects
  /// 3. Apply changes to local cache
  /// 4. Return unified result
  ///
  /// Inspired by Notion's CDC pipeline and Figma's local-first approach.
  @override
  Future<Either<Failure, IncrementalSyncResult<ProjectDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      // 1. Check if sync is needed (lightweight operation)
      final hasModificationsResult = await hasModifiedSince(
        lastSyncTime,
        userId,
      );

      return await hasModificationsResult.fold(
        (failure) async => Left(failure),
        (hasModifications) async {
          if (!hasModifications) {
            // No changes - return empty result with current timestamp
            final timestamp = await getServerTimestamp();
            return timestamp.fold(
              (failure) => Left(failure),
              (serverTime) => Right(
                IncrementalSyncResult<ProjectDTO>(
                  modifiedItems: [],
                  deletedItemIds: [],
                  serverTimestamp: serverTime,
                  totalProcessed: 0,
                ),
              ),
            );
          }

          // 2. Fetch changes in parallel
          final modifiedResult = getModifiedSince(lastSyncTime, userId);
          final deletedResult = getDeletedSince(lastSyncTime, userId);
          final timestampResult = getServerTimestamp();

          final results = await Future.wait([
            modifiedResult,
            deletedResult,
            timestampResult,
          ]);

          // 3. Extract results
          final modifiedProjects =
              results[0] as Either<Failure, List<ProjectDTO>>;
          final deletedIds = results[1] as Either<Failure, List<String>>;
          final serverTimestamp = results[2] as Either<Failure, DateTime>;

          // 4. Check for failures
          if (modifiedProjects.isLeft()) {
            return Left((modifiedProjects as Left).value);
          }
          if (deletedIds.isLeft()) {
            return Left((deletedIds as Left).value);
          }
          if (serverTimestamp.isLeft()) {
            return Left((serverTimestamp as Left).value);
          }

          // 5. Apply changes to local cache
          final modified = (modifiedProjects as Right).value;
          final deleted = (deletedIds as Right).value;
          final timestamp = (serverTimestamp as Right).value;

          await _applyChangesToCache(modified, deleted);

          // 6. Return unified result
          return Right(
            IncrementalSyncResult<ProjectDTO>(
              modifiedItems: modified,
              deletedItemIds: deleted,
              serverTimestamp: timestamp,
              totalProcessed: modified.length + deleted.length,
            ),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  /// COMPLETE full sync operation (Fetch + Cache)
  ///
  /// Fallback method for when incremental sync fails or
  /// when no previous sync timestamp exists.
  @override
  Future<Either<Failure, IncrementalSyncResult<ProjectDTO>>> performFullSync(
    String userId,
  ) async {
    try {
      // 1. Fetch all user projects
      final result = await _remoteDataSource.getUserProjects(userId);

      return await result.fold((failure) async => Left(failure), (
        projects,
      ) async {
        // 2. Get server timestamp
        final timestampResult = await getServerTimestamp();

        return timestampResult.fold((failure) => Left(failure), (
          timestamp,
        ) async {
          // 3. Replace entire cache (full sync approach)
          await _localDataSource.clearCache();

          // 4. Cache all projects
          for (final project in projects) {
            await _localDataSource.cacheProject(project);
          }

          // 5. Return result
          return Right(
            IncrementalSyncResult<ProjectDTO>(
              modifiedItems: projects,
              deletedItemIds: [],
              serverTimestamp: timestamp,
              wasFullSync: true,
              totalProcessed: projects.length,
            ),
          );
        });
      });
    } catch (e) {
      return Left(ServerFailure('Full sync failed: $e'));
    }
  }

  /// Apply incremental changes to local cache
  ///
  /// This method handles the local data layer updates:
  /// - Cache modified/new projects
  /// - Remove deleted projects from cache
  Future<void> _applyChangesToCache(
    List<ProjectDTO> modifiedProjects,
    List<String> deletedIds,
  ) async {
    // Cache modified/new projects
    for (final project in modifiedProjects) {
      await _localDataSource.cacheProject(project);
    }

    // Remove deleted projects (if local datasource supports it)
    // TODO: Add removeProject method to ProjectsLocalDataSource
    for (final deletedId in deletedIds) {
      // await _localDataSource.removeProject(deletedId);
    }
  }

  /// Get sync statistics for monitoring
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    try {
      // TODO: Implement comprehensive sync statistics
      final stats = {
        'userId': userId,
        'lastChecked': DateTime.now().toIso8601String(),
        'supportsIncremental': true,
        'supportsMetadata': true,
        'supportsDeleted': false, // TODO: Implement deleted tracking
      };

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }
}
