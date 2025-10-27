import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Use case for syncing a collaborator's profile from remote
/// Used when viewing other users' profiles
@lazySingleton
class SyncCollaboratorProfileUseCase {
  final UserProfileRepository _userProfileRepository;

  SyncCollaboratorProfileUseCase(this._userProfileRepository);

  Future<Either<Failure, UserProfile>> call(String userId) async {
    try {
      AppLogger.info(
        'SyncCollaboratorProfileUseCase: Syncing profile for userId: $userId',
        tag: 'SYNC_COLLABORATOR_PROFILE',
      );

      final result = await _userProfileRepository.syncProfileFromRemote(
        UserId.fromUniqueString(userId),
      );

      return result.fold(
        (failure) {
          AppLogger.error(
            'SyncCollaboratorProfileUseCase: Failed to sync profile: ${failure.message}',
            tag: 'SYNC_COLLABORATOR_PROFILE',
            error: failure,
          );
          return Left(failure);
        },
        (profile) {
          AppLogger.info(
            'SyncCollaboratorProfileUseCase: Profile synced successfully',
            tag: 'SYNC_COLLABORATOR_PROFILE',
          );
          return Right(profile);
        },
      );
    } catch (e) {
      AppLogger.error(
        'SyncCollaboratorProfileUseCase: Exception syncing profile: $e',
        tag: 'SYNC_COLLABORATOR_PROFILE',
        error: e,
      );
      return Left(ServerFailure('Failed to sync collaborator profile: $e'));
    }
  }
}

