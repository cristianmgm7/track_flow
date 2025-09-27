import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

/// 👤 USER PROFILE INCREMENTAL SYNC SERVICE
///
/// Handles sync for the current user's profile.
/// Special case: only one profile (current user), so "incremental" means
/// checking if the remote profile is newer than local cache.
@LazySingleton()
class UserProfileIncrementalSyncService
    implements IncrementalSyncService<UserProfileDTO> {
  final UserProfileRemoteDataSource _remoteDataSource;
  final UserProfileLocalDataSource _localDataSource;

  UserProfileIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, List<UserProfileDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'USER_PROFILE',
        'Checking if profile modified since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get remote profile
      final remoteResult = await _remoteDataSource.getProfileById(userId);
      if (remoteResult.isLeft()) {
        return remoteResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final remoteProfile = remoteResult.getOrElse(
        () => throw UnimplementedError(),
      );

      // Get local profile for comparison
      final localProfiles = await _localDataSource.getUserProfilesByIds([
        userId,
      ]);
      final localProfile =
          localProfiles.isNotEmpty ? localProfiles.first : null;

      // Check if remote is newer than local
      if (localProfile == null ||
          remoteProfile.updatedAt == null ||
          localProfile.updatedAt == null ||
          remoteProfile.updatedAt!.isAfter(localProfile.updatedAt!)) {
        AppLogger.sync(
          'USER_PROFILE',
          'Profile has been modified remotely',
          syncKey: userId,
        );
        return Right([remoteProfile]);
      }

      AppLogger.sync('USER_PROFILE', 'Profile is up to date', syncKey: userId);
      return const Right([]);
    } catch (e) {
      AppLogger.error(
        'Failed to check modified profile: $e',
        tag: 'UserProfileIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to check modified profile: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    final result = await getModifiedSince(lastSyncTime, userId);
    return result.fold(
      (failure) => Left(failure),
      (profiles) => Right(profiles.isNotEmpty),
    );
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
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    // User profiles don't get deleted
    return const Right([]);
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'USER_PROFILE',
        'Starting incremental sync from ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get modified profiles (should be 0 or 1 for user profile)
      final modifiedResult = await getModifiedSince(lastSyncTime, userId);
      if (modifiedResult.isLeft()) {
        return modifiedResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final modifiedProfiles = modifiedResult.getOrElse(() => []);

      // Update local cache
      for (final profile in modifiedProfiles) {
        await _localDataSource.cacheUserProfile(profile);
      }

      final result = IncrementalSyncResult(
        modifiedItems: modifiedProfiles,
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        totalProcessed: modifiedProfiles.length,
      );

      AppLogger.sync(
        'USER_PROFILE',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'UserProfileIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
  performFullSync(String userId) async {
    try {
      AppLogger.sync('USER_PROFILE', 'Starting full sync', syncKey: userId);

      // Get remote profile
      final remoteResult = await _remoteDataSource.getProfileById(userId);
      if (remoteResult.isLeft()) {
        return remoteResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final remoteProfile = remoteResult.getOrElse(
        () => throw UnimplementedError(),
      );

      // Update local cache
      await _localDataSource.cacheUserProfile(remoteProfile);

      final result = IncrementalSyncResult(
        modifiedItems: [remoteProfile],
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        wasFullSync: true,
        totalProcessed: 1,
      );

      AppLogger.sync(
        'USER_PROFILE',
        'Full sync completed: 1 profile',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Full sync failed: $e',
        tag: 'UserProfileIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Full sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    try {
      final localProfiles = await _localDataSource.getUserProfilesByIds([
        userId,
      ]);
      final hasLocalProfile = localProfiles.isNotEmpty;

      return Right({
        'userId': userId,
        'hasLocalProfile': hasLocalProfile,
        'syncStrategy': 'single_profile_incremental',
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }
}
