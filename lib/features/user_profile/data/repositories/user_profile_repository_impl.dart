import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _userProfileRemoteDataSource;
  final UserProfileLocalDataSource _userProfileLocalDataSource;

  UserProfileRepositoryImpl(
    this._userProfileRemoteDataSource,
    this._userProfileLocalDataSource,
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
}
