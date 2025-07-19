import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({
    required UserProfileLocalDataSource localDataSource,
    required UserProfileRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required FirebaseFirestore firestore,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
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
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Update remote first
        final remoteResult = await _remoteDataSource.updateProfile(
          UserProfileDTO.fromDomain(profile),
        );
        if (remoteResult.isLeft()) {
          return Left(
            remoteResult.fold(
              (failure) => failure,
              (success) => throw Exception('Unexpected success'),
            ),
          );
        }
      }

      // Update local cache
      await _localDataSource.cacheUserProfile(
        UserProfileDTO.fromDomain(profile),
      );

      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update user profile: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId) async* {
    try {
      await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
        yield Right(dto?.toDomain());
      }
    } catch (e) {
      yield Left(ServerFailure('Failed to watch user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> syncProfileFromRemote(
    UserId userId,
  ) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return Left(ServerFailure('No internet connection'));
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
      return Left(ServerFailure('Failed to sync profile from remote: $e'));
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        // Check local cache only
        final localStream = _localDataSource.watchUserProfile(userId.value);
        final localProfile = await localStream.first;
        return Right(localProfile != null);
      }

      // Check remote database
      final userRef = _firestore.collection('user_profile').doc(userId.value);
      final docSnapshot = await userRef.get();
      return Right(docSnapshot.exists);
    } catch (e) {
      return Left(ServerFailure('Failed to check if profile exists: $e'));
    }
  }
}
