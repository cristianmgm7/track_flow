import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_cache_repository.dart';

@LazySingleton(as: UserProfileCacheRepository)
class UserProfileCacheRepositoryImpl implements UserProfileCacheRepository {
  final UserProfileRemoteDataSource _remoteDataSource;
  final UserProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  UserProfileCacheRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, Unit>> cacheUserProfiles(List<UserProfile> profiles) async {
    try {
      for (final profile in profiles) {
        await _localDataSource.cacheUserProfile(
          UserProfileDTO.fromDomain(profile),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache user profiles: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<UserProfile>>> watchUserProfilesByIds(
    List<String> userIds,
  ) {
    return _localDataSource
        .watchUserProfilesByIds(userIds)
        .map(
          (either) => either.fold(
            (failure) => Left(failure),
            (dtos) => Right(dtos.map((e) => e.toDomain()).toList()),
          ),
        );
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getUserProfilesByIds(
    List<String> userIds,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    final dtos = await _remoteDataSource.getUserProfilesByIds(userIds);
    return dtos.fold(
      (failure) => Left(failure),
      (dtos) => Right(dtos.map((e) => e.toDomain()).toList()),
    );
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear user profiles cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> preloadProfiles(List<String> userIds) async {
    try {
      final hasConnected = await _networkInfo.isConnected;
      if (!hasConnected) {
        return Left(DatabaseFailure('No internet connection'));
      }

      final result = await getUserProfilesByIds(userIds);
      return result.fold(
        (failure) => Left(failure),
        (profiles) => cacheUserProfiles(profiles),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to preload profiles: $e'));
    }
  }
}