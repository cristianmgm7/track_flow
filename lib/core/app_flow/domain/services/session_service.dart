import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Service that handles ONLY user session management
///
/// This service uses existing use cases and is responsible ONLY for session operations.
/// It does NOT handle any sync-related functionality.
@injectable
class SessionService {
  final CheckAuthenticationStatusUseCase _checkAuthUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final OnboardingUseCase _onboardingUseCase;
  final CheckProfileCompletenessUseCase _profileUseCase;
  SessionService({
    required CheckAuthenticationStatusUseCase checkAuthUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required OnboardingUseCase onboardingUseCase,
    required CheckProfileCompletenessUseCase profileUseCase,
  }) : _checkAuthUseCase = checkAuthUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _onboardingUseCase = onboardingUseCase,
       _profileUseCase = profileUseCase;

  /// Get the current user session
  ///
  /// This method checks authentication, user data, onboarding, and profile completeness.
  /// It does NOT handle any sync operations.
  Future<Either<Failure, UserSession>> getCurrentSession() async {
    try {
      AppLogger.info('Starting getCurrentSession()', tag: 'SESSION_SERVICE');

      // Step 1: Check authentication status with synchronization
      AppLogger.info(
        'Step 1: Checking authentication status with sync...',
        tag: 'SESSION_SERVICE',
      );
      final authResult = await _checkAuthUseCase();

      final isAuthenticated = await authResult.fold(
        (failure) async {
          AppLogger.warning(
            'Authentication check failed: ${failure.message}',
            tag: 'SESSION_SERVICE',
          );
          return false;
        },
        (isAuth) async {
          AppLogger.info(
            'Authentication check result: $isAuth',
            tag: 'SESSION_SERVICE',
          );
          return isAuth;
        },
      );

      if (!isAuthenticated) {
        AppLogger.info(
          'User not authenticated, returning unauthenticated session',
          tag: 'SESSION_SERVICE',
        );
        return const Right(UserSession.unauthenticated());
      }

      // Step 2: Get current user with synchronization
      AppLogger.info(
        'Step 2: Getting current user with sync...',
        tag: 'SESSION_SERVICE',
      );
      final userResult = await _getCurrentUserUseCase();

      final user = await userResult.fold(
        (failure) async {
          AppLogger.warning(
            'Get current user failed: ${failure.message}',
            tag: 'SESSION_SERVICE',
          );
          return null;
        },
        (user) async {
          AppLogger.info(
            'Current user retrieved: ${user?.email} (ID: ${user?.id})',
            tag: 'SESSION_SERVICE',
          );
          return user;
        },
      );

      if (user == null) {
        AppLogger.warning(
          'No user found despite being authenticated, returning unauthenticated',
          tag: 'SESSION_SERVICE',
        );
        return const Right(UserSession.unauthenticated());
      }

      // Steps 3 & 4: Check onboarding and profile in parallel
      AppLogger.info(
        'Step 3 & 4: Checking onboarding and profile completeness in parallel...',
        tag: 'SESSION_SERVICE',
      );

      final parallelResults = await Future.wait([
        _onboardingUseCase.checkOnboardingCompleted(user.id.value),
        _profileUseCase.getDetailedCompleteness(user.id.value),
      ]);

      final onboardingResult = parallelResults[0] as Either<Failure, bool>;
      final profileResult =
          parallelResults[1] as Either<Failure, ProfileCompletenessInfo>;

      // Process onboarding result
      final onboardingCompleted = await onboardingResult.fold(
        (failure) async {
          AppLogger.warning(
            'Onboarding check failed: ${failure.message}',
            tag: 'SESSION_SERVICE',
          );
          return false;
        },
        (completed) async {
          AppLogger.info(
            'Onboarding completed: $completed',
            tag: 'SESSION_SERVICE',
          );
          return completed;
        },
      );

      // Process profile result
      return await profileResult.fold(
        (failure) async {
          AppLogger.error(
            'Profile completeness check failed: ${failure.message}',
            tag: 'SESSION_SERVICE',
            error: failure,
          );
          return Left(failure);
        },
        (completenessInfo) async {
          AppLogger.info(
            'Profile completeness: ${completenessInfo.isComplete}',
            tag: 'SESSION_SERVICE',
          );

          if (!onboardingCompleted || !completenessInfo.isComplete) {
            // User needs to complete setup
            AppLogger.info(
              'User needs setup - onboarding: ${!onboardingCompleted}, profile: ${completenessInfo.isComplete}',
              tag: 'SESSION_SERVICE',
            );

            return Right(
              UserSession.authenticated(
                user: user,
                onboardingComplete:
                    onboardingCompleted, // FIXED: true means onboarding is completed
                profileComplete: completenessInfo.isComplete,
              ),
            );
          }

          // User is fully set up
          AppLogger.info(
            'User is fully ready - returning ready session',
            tag: 'SESSION_SERVICE',
          );

          return Right(UserSession.ready(user: user));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Session initialization failed: $e',
        tag: 'SESSION_SERVICE',
        error: e,
      );
      return Left(ServerFailure('Session initialization failed: $e'));
    }
  }


  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated() async {
    AppLogger.info('Checking if user is authenticated', tag: 'SESSION_SERVICE');
    final result = await _checkAuthUseCase();
    return result.fold(
      (failure) {
        AppLogger.warning(
          'Authentication check failed: ${failure.message}',
          tag: 'SESSION_SERVICE',
        );
        return Left(failure);
      },
      (isAuth) {
        AppLogger.info(
          'Authentication result: $isAuth',
          tag: 'SESSION_SERVICE',
        );
        return Right(isAuth);
      },
    );
  }

  /// Get current user ID
  Future<Either<Failure, String?>> getCurrentUserId() async {
    AppLogger.info('Getting current user ID', tag: 'SESSION_SERVICE');
    final userResult = await _getCurrentUserUseCase();
    return userResult.fold(
      (failure) {
        AppLogger.warning(
          'Get current user ID failed: ${failure.message}',
          tag: 'SESSION_SERVICE',
        );
        return Left(failure);
      },
      (user) {
        final userId = user?.id.value;
        AppLogger.info('Current user ID: $userId', tag: 'SESSION_SERVICE');
        return Right(userId);
      },
    );
  }

  /// Clear session data (for testing or logout)
  Future<Either<Failure, Unit>> clearSession() async {
    AppLogger.info('Clearing session data', tag: 'SESSION_SERVICE');
    // This would clear any cached session data
    // For now, just return success
    return const Right(unit);
  }
}
