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
      // Step 1: Check authentication status
      final authResult = await _checkAuthUseCase();
      final isAuthenticated = authResult.fold((failure) => false, (isAuth) => isAuth);

      if (!isAuthenticated) {
        return const Right(UserSession.unauthenticated());
      }

      // Step 2: Get current user (simplified - no sync coupling)
      final userResult = await _getCurrentUserUseCase();
      final user = userResult.fold(
        (failure) {
          AppLogger.warning(
            'Get current user failed: ${failure.message}',
            tag: 'SESSION_SERVICE',
          );
          return null;
        },
        (user) => user,
      );

      if (user == null) {
        return const Right(UserSession.unauthenticated());
      }

      // Step 3: Check setup requirements in parallel
      final results = await Future.wait([
        _onboardingUseCase.checkOnboardingCompleted(user.id.value),
        _profileUseCase.isProfileComplete(user.id.value),
      ]);

      final onboardingComplete = (results[0] as Either<Failure, bool>).fold(
        (failure) => false,
        (completed) => completed,
      );
      final profileComplete = (results[1] as Either<Failure, bool>).fold(
        (failure) => false,
        (complete) => complete,
      );

      // Step 4: Return session state
      if (!onboardingComplete || !profileComplete) {
        return Right(
          UserSession.authenticated(
            user: user,
            onboardingComplete: onboardingComplete,
            profileComplete: profileComplete,
          ),
        );
      }

      return Right(UserSession.ready(user: user));
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
    final result = await _checkAuthUseCase();
    return result.fold(
      (failure) {
        AppLogger.warning(
          'Authentication check failed: ${failure.message}',
          tag: 'SESSION_SERVICE',
        );
        return Left(failure);
      },
      (isAuth) => Right(isAuth),
    );
  }

  /// Get current user ID
  Future<Either<Failure, String?>> getCurrentUserId() async {
    final userResult = await _getCurrentUserUseCase();
    return userResult.fold(
      (failure) {
        AppLogger.warning(
          'Get current user ID failed: ${failure.message}',
          tag: 'SESSION_SERVICE',
        );
        return Left(failure);
      },
      (user) => Right(user?.id.value),
    );
  }

  /// Clear session data (for testing or logout)
  Future<Either<Failure, Unit>> clearSession() async {
    // This would clear any cached session data
    // For now, just return success
    return const Right(unit);
  }
}
