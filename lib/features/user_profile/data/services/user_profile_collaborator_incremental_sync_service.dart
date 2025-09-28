import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@LazySingleton()
class UserProfileCollaboratorIncrementalSyncService
    implements IncrementalSyncService<UserProfileDTO> {
  final UserProfileRemoteDataSource _remoteDataSource;
  final UserProfileLocalDataSource _localDataSource;
  final ProjectsLocalDataSource _projectsLocalDataSource;

  UserProfileCollaboratorIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._projectsLocalDataSource,
  );
  @override
  Future<Either<Failure, List<UserProfileDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'USER_PROFILES',
        'Getting modified collaborator profiles since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get current collaborators from projects
      final collaboratorsResult = await _getCurrentCollaboratorIds(userId);
      if (collaboratorsResult.isLeft()) {
        return collaboratorsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final collaboratorIds = collaboratorsResult.getOrElse(() => []);

      if (collaboratorIds.isEmpty) {
        AppLogger.sync(
          'USER_PROFILES',
          'No collaborators found',
          syncKey: userId,
        );
        return const Right([]);
      }

      // Get modified profiles for these collaborators
      final result = await _remoteDataSource.getUserProfilesModifiedSince(
        lastSyncTime,
        collaboratorIds,
      );

      return result.fold((failure) => Left(failure), (modifiedProfiles) {
        AppLogger.sync(
          'USER_PROFILES',
          'Found ${modifiedProfiles.length} modified collaborator profiles',
          syncKey: userId,
        );
        return Right(modifiedProfiles);
      });
    } catch (e) {
      AppLogger.error(
        'Failed to get modified collaborator profiles: $e',
        tag: 'UserProfileCollaboratorIncrementalSyncService',
        error: e,
      );
      return Left(
        ServerFailure('Failed to get modified collaborator profiles: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'USER_PROFILES',
        'Getting metadata for modified collaborator profiles since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get current collaborators from projects
      final collaboratorsResult = await _getCurrentCollaboratorIds(userId);
      if (collaboratorsResult.isLeft()) {
        return collaboratorsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final collaboratorIds = collaboratorsResult.getOrElse(() => []);

      if (collaboratorIds.isEmpty) {
        AppLogger.sync(
          'USER_PROFILES',
          'No collaborators found for metadata',
          syncKey: userId,
        );
        return const Right([]);
      }

      // Get metadata for modified profiles
      final result = await _remoteDataSource
          .getUserProfilesMetadataModifiedSince(lastSyncTime, collaboratorIds);

      return result.fold((failure) => Left(failure), (metadata) {
        AppLogger.sync(
          'USER_PROFILES',
          'Found ${metadata.length} metadata entries for modified collaborator profiles',
          syncKey: userId,
        );
        return Right(metadata);
      });
    } catch (e) {
      AppLogger.error(
        'Failed to get metadata for modified collaborator profiles: $e',
        tag: 'UserProfileCollaboratorIncrementalSyncService',
        error: e,
      );
      return Left(
        ServerFailure(
          'Failed to get metadata for modified collaborator profiles: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'USER_PROFILES',
        'Starting incremental sync from ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get modified profiles
      final modifiedResult = await getModifiedSince(lastSyncTime, userId);
      if (modifiedResult.isLeft()) {
        return modifiedResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final modifiedProfiles = modifiedResult.getOrElse(() => []);

      AppLogger.sync(
        'USER_PROFILES',
        'Found ${modifiedProfiles.length} modified collaborator profiles',
        syncKey: userId,
      );

      // Update local cache
      await _updateLocalCache(modifiedProfiles);

      // Get server timestamp for next sync
      final serverTimestamp = DateTime.now().toUtc();

      final result = IncrementalSyncResult(
        modifiedItems: modifiedProfiles,
        deletedItemIds: [], // No deletions handled for now
        serverTimestamp: serverTimestamp,
        totalProcessed: modifiedProfiles.length,
      );

      AppLogger.sync(
        'USER_PROFILES',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'UserProfileCollaboratorIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
  performFullSync(String userId) async {
    return performIncrementalSync(
      DateTime.fromMillisecondsSinceEpoch(0),
      userId,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    try {
      final collaboratorsResult = await _getCurrentCollaboratorIds(userId);
      final collaborators = collaboratorsResult.getOrElse(() => []);

      return Right({
        'userId': userId,
        'totalCollaborators': collaborators.length,
        'syncStrategy': 'incremental_collaborator_profiles',
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }

  /// Get current collaborator IDs from projects
  Future<Either<Failure, List<String>>> _getCurrentCollaboratorIds(
    String userId,
  ) async {
    final projectsResult = await _projectsLocalDataSource.getAllProjects();
    return projectsResult.fold(
      (failure) => Left(failure),
      (projects) => Right(
        projects
            .expand((p) => p.collaboratorIds.map((c) => c))
            .toSet()
            .toList(),
      ),
    );
  }

  /// Update local cache with modified profiles
  Future<void> _updateLocalCache(List<UserProfileDTO> modifiedProfiles) async {
    for (final profile in modifiedProfiles) {
      try {
        await _localDataSource.cacheUserProfile(profile);
      } catch (e) {
        AppLogger.error(
          'Failed to cache user profile ${profile.id}: $e',
          tag: 'UserProfileCollaboratorIncrementalSyncService',
        );
      }
    }
  }
}
