import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileRemoteDataSource _remoteDataSource;
  final NetworkStateManager _networkStateManager;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;
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
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager,
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
      
      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'user_profile',
        entityId: profile.id.value,
        operationType: 'update',
        priority: SyncPriority.medium,
        data: {
          'name': profile.name,
          'creativeRole': profile.creativeRole?.name ?? 'unknown',
          'avatarUrl': profile.avatarUrl,
        },
      );

      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'user_profile_update',
        );
      }

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to update user profile: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId) async* {
    try {
      // CACHE-ASIDE PATTERN: Return local data immediately + trigger background sync
      await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
        // Trigger background sync if connected (non-blocking)
        if (await _networkStateManager.isConnected) {
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'user_profile_${userId.value}',
          );
        }
        
        // Return local data immediately
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
        // Profile exists locally, trigger background sync to verify remote state
        if (await _networkStateManager.isConnected) {
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'profile_exists_${userId.value}',
          );
        }
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
}
