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
        AppLogger.info(
          'WatchUserProfileUseCase: No userId found in session storage - user not authenticated',
          tag: 'WATCH_USER_PROFILE',
        );

        // Return null profile instead of error to prevent infinite loops
        yield Right(null);
        return;
      }

      AppLogger.info(
        'WatchUserProfileUseCase: Got userId from session: $id',
        tag: 'WATCH_USER_PROFILE',
      );
    } else {
      // CRITICAL: Even when userId is explicitly provided, verify it matches current session
      // This prevents widgets with stale userIds from loading cached profiles after logout
      final currentSessionUserId = await _sessionStorage.getUserId();
      if (currentSessionUserId == null) {
        AppLogger.warning(
          'WatchUserProfileUseCase: No current session, rejecting explicit userId: $id',
          tag: 'WATCH_USER_PROFILE',
        );
        yield Right(null);
        return;
      }

      if (currentSessionUserId != id) {
        AppLogger.warning(
          'WatchUserProfileUseCase: Explicit userId ($id) does not match current session ($currentSessionUserId), rejecting request',
          tag: 'WATCH_USER_PROFILE',
        );
        yield Right(null);
        return;
      }

      AppLogger.info(
        'WatchUserProfileUseCase: Explicit userId validated against current session: $id',
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
        yield await either.fold(
          (failure) async {
            AppLogger.error(
              'WatchUserProfileUseCase: Error watching profile: ${failure.message}',
              tag: 'WATCH_USER_PROFILE',
              error: failure,
            );
            return Left(failure);
          },
          (profile) async {
            // ✅ CRITICAL: Always check session before processing profile
            final currentUserId = await _sessionStorage.getUserId();
            if (currentUserId == null) {
              AppLogger.info(
                'WatchUserProfileUseCase: No active session, returning null profile',
                tag: 'WATCH_USER_PROFILE',
              );
              return Right(null);
            }

            if (currentUserId != id) {
              AppLogger.warning(
                'WatchUserProfileUseCase: Session userId ($currentUserId) != requested userId ($id), returning null',
                tag: 'WATCH_USER_PROFILE',
              );
              return Right(null);
            }

            if (profile != null) {
              AppLogger.info(
                'WatchUserProfileUseCase: Profile loaded successfully for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );
            } else {
              AppLogger.warning(
                'WatchUserProfileUseCase: No local profile found for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );
              // Do not trigger remote sync here; app bootstrap handles seeding
            }
            return Right(profile);
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

  /// Watch any user's profile without enforcing current session user check.
  /// Use this for viewing collaborator profiles.
  Stream<Either<Failure, UserProfile?>> callAny(String userId) async* {
    try {
      AppLogger.info(
        'WatchUserProfileUseCase.callAny: Watching profile for userId: $userId',
        tag: 'WATCH_USER_PROFILE',
      );
      yield* _userProfileRepository.watchUserProfile(
        UserId.fromUniqueString(userId),
      );
    } catch (e) {
      AppLogger.error(
        'WatchUserProfileUseCase.callAny: Error watching profile: $e',
        tag: 'WATCH_USER_PROFILE',
        error: e,
      );
      yield Left(ServerFailure('Failed to watch user profile: $e'));
    }
  }

  // Remote sync is intentionally not triggered here to keep watch local-only
}
