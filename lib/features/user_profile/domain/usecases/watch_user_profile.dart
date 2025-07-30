import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class WatchUserProfileUseCase {
  final UserProfileRepository _userProfileRepository;
  final SessionStorage _sessionStorage;

  WatchUserProfileUseCase(this._userProfileRepository, this._sessionStorage);

  Stream<Either<Failure, UserProfile?>> call([String? userId]) async* {
    String? id = userId;

    // If no userId provided, try to get from session storage
    if (id == null) {
      AppLogger.info(
        'WatchUserProfileUseCase: No userId provided, getting from session storage',
        tag: 'WATCH_USER_PROFILE',
      );
      id = await _sessionStorage.getUserId();

      if (id == null) {
        AppLogger.warning(
          'WatchUserProfileUseCase: No userId found in session storage',
          tag: 'WATCH_USER_PROFILE',
        );
        yield Left(ServerFailure('No user found - user not authenticated'));
        return;
      }

      AppLogger.info(
        'WatchUserProfileUseCase: Got userId from session: $id',
        tag: 'WATCH_USER_PROFILE',
      );
    }

    try {
      AppLogger.info(
        'WatchUserProfileUseCase: Starting to watch profile for userId: $id',
        tag: 'WATCH_USER_PROFILE',
      );

      final stream = _userProfileRepository.watchUserProfile(
        UserId.fromUniqueString(id),
      );

      await for (final either in stream) {
        yield either.fold(
          (failure) {
            AppLogger.error(
              'WatchUserProfileUseCase: Error watching profile: ${failure.message}',
              tag: 'WATCH_USER_PROFILE',
              error: failure,
            );
            return left(failure);
          },
          (profile) {
            if (profile != null) {
              AppLogger.info(
                'WatchUserProfileUseCase: Profile loaded successfully for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );
            } else {
              AppLogger.warning(
                'WatchUserProfileUseCase: No profile found for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );
            }
            return right(profile);
          },
        );
      }
    } catch (e) {
      AppLogger.error(
        'WatchUserProfileUseCase: Exception watching profile: $e',
        tag: 'WATCH_USER_PROFILE',
        error: e,
      );
      yield Left(ServerFailure('Failed to watch user profile: $e'));
    }
  }
}
