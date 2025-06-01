import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(UserId userId) async {
    try {
      final userProfile = await _remoteDataSource.getProfile(userId.value);
      return right(userProfile.toDomain());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
    UserProfile userProfile,
  ) async {
    try {
      final userProfileDTO = UserProfileDTO.fromDomain(userProfile);
      await _remoteDataSource.updateProfile(userProfileDTO);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
