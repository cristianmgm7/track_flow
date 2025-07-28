import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileRemoteDataSource _remoteDataSource;
  final NetworkStateManager _networkStateManager;
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({
    required UserProfileLocalDataSource localDataSource,
    required UserProfileRemoteDataSource remoteDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
    required FirebaseFirestore firestore,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkStateManager = networkStateManager,
       _firestore = firestore;

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile(UserId userId) async {
    try {
      // Try to get from local cache first using watch stream
      final localStream = _localDataSource.watchUserProfile(userId.value);
      final localProfile = await localStream.first;

      if (localProfile != null) {
        return Right(localProfile.toDomain());
      }

      // If not in local cache, try to sync from remote
      final syncResult = await syncProfileFromRemote(userId);
      return syncResult.fold(
        (failure) => Left(failure),
        (profile) => Right(profile),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserProfile(UserProfile profile) async {
    try {
      // 1. OFFLINE-FIRST: Update locally IMMEDIATELY
      final dto = UserProfileDTO.fromDomain(profile);
      await _localDataSource.cacheUserProfile(dto);

      // 2. TEMPORARY FIX: Direct sync instead of background queue
      // This avoids the infinite loop issue with the sync system
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.updateProfile(dto);
          remoteResult.fold(
            (failure) {
              AppLogger.warning(
                'Failed to sync profile to remote: ${failure.message}',
                tag: 'UserProfileRepository',
              );
              // Don't fail the operation - local save was successful
            },
            (_) {
              AppLogger.info(
                'Profile synced to remote successfully',
                tag: 'UserProfileRepository',
              );
            },
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local save was successful: $e',
          tag: 'UserProfileRepository',
        );
        // Don't fail the operation - local save was successful
      }

      return Right(unit); // ✅ SUCCESS after local save
    } catch (e) {
      return Left(DatabaseFailure('Failed to update user profile: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId) async* {
    try {
      // CACHE-ASIDE PATTERN: Return local data immediately
      // TEMPORARY FIX: Disabled background sync to avoid infinite loop
      await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
        // Return local data immediately without triggering background sync
        yield Right(dto?.toDomain());
      }
    } catch (e) {
      yield Left(DatabaseFailure('Failed to watch user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> syncProfileFromRemote(
    UserId userId,
  ) async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Left(DatabaseFailure('No internet connection'));
      }

      // Get profile from remote data source
      final remoteResult = await _remoteDataSource.getProfileById(userId.value);

      return remoteResult.fold((failure) => Left(failure), (
        remoteProfile,
      ) async {
        // Cache the profile locally
        await _localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile.toDomain());
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to sync profile from remote: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearProfileCache() async {
    try {
      await _localDataSource.clearCache();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to clear profile cache: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> profileExists(UserId userId) async {
    try {
      // OFFLINE-FIRST: Check local cache first
      final localStream = _localDataSource.watchUserProfile(userId.value);
      final localProfile = await localStream.first;

      if (localProfile != null) {
        // Profile exists locally
        // TEMPORARY FIX: Disabled background sync to avoid infinite loop
        return Right(true);
      }

      // If not local, check remote if connected
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Right(false); // Assume doesn't exist if offline and not cached
      }

      // Check remote database
      final userRef = _firestore.collection('user_profile').doc(userId.value);
      final docSnapshot = await userRef.get();
      return Right(docSnapshot.exists);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if profile exists: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> findUserByEmail(String email) async {
    try {
      // OFFLINE-FIRST: Check local cache first
      final localProfile = await _localDataSource.findUserByEmail(email);
      if (localProfile != null) {
        return Right(localProfile.toDomain());
      }

      // If not in local cache, try remote if connected
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Right(null); // User not found (offline)
      }

      // Search remote database
      final remoteResult = await _remoteDataSource.findUserByEmail(email);
      return remoteResult.fold((failure) => Left(failure), (
        remoteProfile,
      ) async {
        if (remoteProfile != null) {
          // Cache the found profile locally
          await _localDataSource.cacheUserProfile(remoteProfile);
          return Right(remoteProfile.toDomain());
        }
        return Right(null); // User not found
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to find user by email: $e'));
    }
  }
}
