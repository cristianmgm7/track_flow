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
            if (profile != null) {
              AppLogger.info(
                'WatchUserProfileUseCase: Profile loaded successfully for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );
            } else {
              // Double-check if user is still authenticated before trying to sync
              final currentUserId = await _sessionStorage.getUserId();
              if (currentUserId == null || currentUserId != id) {
                AppLogger.info(
                  'WatchUserProfileUseCase: User no longer authenticated, stopping profile watch',
                  tag: 'WATCH_USER_PROFILE',
                );
                return Right(null);
              }

              AppLogger.warning(
                'WatchUserProfileUseCase: No profile found for userId: $id',
                tag: 'WATCH_USER_PROFILE',
              );

              // Try to sync from remote if profile is not found locally
              if (id != null) {
                _trySyncFromRemote(id);
              }
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

  /// Try to sync profile from remote when not found locally
  Future<void> _trySyncFromRemote(String userId) async {
    try {
      AppLogger.info(
        'WatchUserProfileUseCase: Attempting to sync profile from remote for userId: $userId',
        tag: 'WATCH_USER_PROFILE',
      );

      final syncResult = await _userProfileRepository.syncProfileFromRemote(
        UserId.fromUniqueString(userId),
      );

      syncResult.fold(
        (failure) {
          AppLogger.warning(
            'WatchUserProfileUseCase: Remote sync failed: ${failure.message}',
            tag: 'WATCH_USER_PROFILE',
          );

          // Log more details about the failure
          if (failure.message.contains('not found')) {
            AppLogger.error(
              'WatchUserProfileUseCase: Profile does not exist in Firestore for userId: $userId',
              tag: 'WATCH_USER_PROFILE',
            );
          } else if (failure.message.contains('No internet connection')) {
            AppLogger.warning(
              'WatchUserProfileUseCase: No internet connection for sync',
              tag: 'WATCH_USER_PROFILE',
            );
          } else {
            AppLogger.error(
              'WatchUserProfileUseCase: Unexpected sync error: ${failure.message}',
              tag: 'WATCH_USER_PROFILE',
            );
          }
        },
        (profile) {
          AppLogger.info(
            'WatchUserProfileUseCase: Profile synced from remote successfully - name: ${profile.name}, email: ${profile.email}',
            tag: 'WATCH_USER_PROFILE',
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'WatchUserProfileUseCase: Error during remote sync: $e',
        tag: 'WATCH_USER_PROFILE',
        error: e,
      );
    }
  }
}
