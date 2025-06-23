import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _userProfileRemoteDataSource;
  final UserProfileLocalDataSource _userProfileLocalDataSource;
  final NetworkInfo _networkInfo;

  UserProfileRepositoryImpl(
    this._userProfileRemoteDataSource,
    this._userProfileLocalDataSource,
    this._networkInfo,
  );

  @override
  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId) async* {
    try {
      await for (final dto in _userProfileLocalDataSource.watchUserProfile(
        userId.value,
      )) {
        try {
          yield Right(dto?.toDomain());
        } catch (e) {
          yield Left(
            ServerFailure(
              'Failed to parse local user profile: ${e.toString()}',
            ),
          );
        }
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
    UserProfile userProfile,
  ) async {
    try {
      final userProfileDTO = UserProfileDTO.fromDomain(userProfile);
      await _userProfileRemoteDataSource.updateProfile(userProfileDTO);
      await _userProfileLocalDataSource.cacheUserProfile(userProfileDTO);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> cacheUserProfiles(List<UserProfile> profiles) async {
    for (final profile in profiles) {
      await _userProfileLocalDataSource.cacheUserProfile(
        UserProfileDTO.fromDomain(profile),
      );
    }
  }

  @override
  Stream<List<UserProfile>> watchUserProfilesByIds(List<String> userIds) {
    return _userProfileLocalDataSource
        .watchUserProfilesByIds(userIds)
        .map((dtos) => dtos.map((e) => e.toDomain()).toList());
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getUserProfilesByIds(
    List<String> userIds,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    final dtos = await _userProfileRemoteDataSource.getUserProfilesByIds(
      userIds,
    );
    return dtos.fold(
      (failure) => left(failure),
      (dtos) => right(dtos.map((e) => e.toDomain()).toList()),
    );
  }
}
