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
  Future<Either<Failure, Unit>> updateUserProfile(
    UserProfile userProfile,
  ) async {
    try {
      final userProfileDTO = UserProfileDTO.fromDomain(userProfile);
      final result = await _userProfileRemoteDataSource.updateProfile(
        userProfileDTO,
      );
      return await result.fold((failure) => Left(failure), (updatedDTO) async {
        await _userProfileLocalDataSource.cacheUserProfile(updatedDTO);
        return const Right(unit);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile(UserId userId) async {
    try {
      final hasConnected = await _networkInfo.isConnected;
      if (hasConnected) {
        // Try remote first if connected
        final remoteResult = await _userProfileRemoteDataSource.getProfileById(userId.value);
        return await remoteResult.fold(
          (failure) async {
            // Fallback to local if remote fails - using the first value from watch stream
            final localStream = _userProfileLocalDataSource.watchUserProfile(userId.value);
            final localDTO = await localStream.first;
            return Right(localDTO?.toDomain());
          },
          (userProfile) async {
            // Cache the remote result
            final dto = UserProfileDTO.fromDomain(userProfile);
            await _userProfileLocalDataSource.cacheUserProfile(dto);
            return Right(userProfile);
          },
        );
      } else {
        // Use local data when offline - using the first value from watch stream
        final localStream = _userProfileLocalDataSource.watchUserProfile(userId.value);
        final localDTO = await localStream.first;
        return Right(localDTO?.toDomain());
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: $e'));
    }
  }
}
