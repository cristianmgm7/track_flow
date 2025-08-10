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
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/media/avatar_cache_manager.dart';
import 'package:trackflow/core/di/injection.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileRemoteDataSource _remoteDataSource;
  final NetworkStateManager _networkStateManager;
  final FirebaseFirestore _firestore;
  // SessionStorage kept for API parity; not used in watcher
  // ignore: unused_field
  final SessionStorage _sessionStorage;

  UserProfileRepositoryImpl({
    required UserProfileLocalDataSource localDataSource,
    required UserProfileRemoteDataSource remoteDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
    required FirebaseFirestore firestore,
    required SessionStorage sessionStorage,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkStateManager = networkStateManager,
       _firestore = firestore,
       _sessionStorage = sessionStorage;

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
      // Normalize and cache local avatar path if needed
      AvatarCacheManager cache = sl<AvatarCacheManager>();
      var dto = UserProfileDTO.fromDomain(profile);
      final isLocalAvatar =
          dto.avatarUrl.isNotEmpty && !dto.avatarUrl.startsWith('http');
      if (isLocalAvatar) {
        try {
          final cachedPath = await cache.copyAvatarToCache(
            profile.id.value,
            dto.avatarUrl,
          );
          // Ensure remote uses the cached path for upload
          dto = dto.copyWith(
            avatarLocalPath: cachedPath,
            avatarUrl: cachedPath,
          );
        } catch (e) {
          AppLogger.warning(
            'Avatar cache copy failed: $e',
            tag: 'UserProfileRepository',
          );
        }
      }

      // 1. OFFLINE-FIRST: Update locally IMMEDIATELY with localPath if any
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
            (remoteUpdatedDto) async {
              AppLogger.info(
                'Profile synced to remote successfully',
                tag: 'UserProfileRepository',
              );
              // Merge remote DTO (with http avatarUrl) with local avatarLocalPath
              final merged = remoteUpdatedDto.copyWith(
                avatarLocalPath: dto.avatarLocalPath,
              );
              try {
                await _localDataSource.cacheUserProfile(merged);
              } catch (e) {
                AppLogger.warning(
                  'Failed to update local cache with remote DTO: $e',
                  tag: 'UserProfileRepository',
                );
              }
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
      AppLogger.info(
        'UserProfileRepository: Starting to watch profile for userId: ${userId.value}',
        tag: 'USER_PROFILE_REPOSITORY',
      );

      // CACHE-ASIDE (local-only watcher): emit local data; seeding is handled by app sync
      await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
        if (dto != null) {
          AppLogger.info(
            'UserProfileRepository: Profile found in local cache',
            tag: 'USER_PROFILE_REPOSITORY',
          );
          yield Right(dto.toDomain());
        } else {
          // Emit null to indicate "not yet available locally"; do not fetch remote here
          yield Right(null);
        }
      }
    } catch (e) {
      AppLogger.error(
        'UserProfileRepository: Error watching profile: $e',
        tag: 'USER_PROFILE_REPOSITORY',
        error: e,
      );
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

      AppLogger.info(
        'UserProfileRepository: Forcing sync from remote for userId: ${userId.value}',
        tag: 'USER_PROFILE_REPOSITORY',
      );

      // Get profile from remote data source
      final remoteResult = await _remoteDataSource.getProfileById(userId.value);

      return remoteResult.fold((failure) => Left(failure), (
        remoteProfile,
      ) async {
        AppLogger.info(
          'UserProfileRepository: Remote profile found, caching locally',
          tag: 'USER_PROFILE_REPOSITORY',
        );
        // Cache the profile locally
        await _localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile.toDomain());
      });
    } catch (e) {
      AppLogger.error(
        'UserProfileRepository: Error syncing profile from remote: $e',
        tag: 'USER_PROFILE_REPOSITORY',
        error: e,
      );
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
      AppLogger.info(
        'UserProfileRepository: Checking if profile exists for userId: ${userId.value}',
        tag: 'USER_PROFILE_REPOSITORY',
      );

      // OFFLINE-FIRST: Check local cache first
      final localStream = _localDataSource.watchUserProfile(userId.value);
      final localProfile = await localStream.first;

      if (localProfile != null) {
        // Profile exists locally
        AppLogger.info(
          'UserProfileRepository: Profile exists locally',
          tag: 'USER_PROFILE_REPOSITORY',
        );
        return Right(true);
      }

      AppLogger.info(
        'UserProfileRepository: Profile not found locally, checking remote',
        tag: 'USER_PROFILE_REPOSITORY',
      );

      // If not local, check remote if connected
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        AppLogger.warning(
          'UserProfileRepository: No internet connection, cannot check remote',
          tag: 'USER_PROFILE_REPOSITORY',
        );
        return Right(false); // Assume doesn't exist if offline and not cached
      }

      // Check remote database
      final userRef = _firestore.collection('user_profile').doc(userId.value);
      final docSnapshot = await userRef.get();

      final exists = docSnapshot.exists;
      AppLogger.info(
        'UserProfileRepository: Remote check completed - exists: $exists',
        tag: 'USER_PROFILE_REPOSITORY',
      );

      if (exists) {
        AppLogger.info(
          'UserProfileRepository: Profile exists in Firestore but not in local cache',
          tag: 'USER_PROFILE_REPOSITORY',
        );
      } else {
        AppLogger.warning(
          'UserProfileRepository: Profile does not exist in Firestore',
          tag: 'USER_PROFILE_REPOSITORY',
        );
      }

      return Right(exists);
    } catch (e) {
      AppLogger.error(
        'UserProfileRepository: Error checking if profile exists: $e',
        tag: 'USER_PROFILE_REPOSITORY',
        error: e,
      );
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
