import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/domain/entities/user_session.dart';
import 'package:trackflow/core/session/domain/usecases/check_authentication_status_usecase.dart';
import 'package:trackflow/core/session/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/core/session/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

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
  final SignOutUseCase _signOutUseCase;

  SessionService({
    required CheckAuthenticationStatusUseCase checkAuthUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required OnboardingUseCase onboardingUseCase,
    required CheckProfileCompletenessUseCase profileUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _checkAuthUseCase = checkAuthUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _onboardingUseCase = onboardingUseCase,
       _profileUseCase = profileUseCase,
       _signOutUseCase = signOutUseCase;

  /// Get the current user session
  ///
  /// This method checks authentication, user data, onboarding, and profile completeness.
  /// It does NOT handle any sync operations.
  Future<Either<Failure, UserSession>> getCurrentSession() async {
    try {
      // Step 1: Check authentication status
      final authResult = await _checkAuthUseCase();
      final isAuthenticated = await authResult.fold(
        (failure) async => false,
        (isAuth) async => isAuth,
      );

      if (!isAuthenticated) {
        return const Right(UserSession.unauthenticated());
      }

      // Step 2: Get current user
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold(
        (failure) async => null,
        (user) async => user,
      );

      if (user == null) {
        return const Right(UserSession.unauthenticated());
      }

      // Steps 3 & 4: Check onboarding and profile in parallel
      final parallelResults = await Future.wait([
        _onboardingUseCase.checkOnboardingCompleted(user.id.value),
        _profileUseCase.getDetailedCompleteness(user.id.value),
      ]);

      final onboardingResult = parallelResults[0] as Either<Failure, bool>;
      final profileResult =
          parallelResults[1] as Either<Failure, ProfileCompletenessInfo>;

      // Process onboarding result
      final onboardingCompleted = await onboardingResult.fold(
        (failure) async => false,
        (completed) async => completed,
      );

      // Process profile result
      return await profileResult.fold((failure) async => Left(failure), (
        completenessInfo,
      ) async {
        if (!onboardingCompleted || !completenessInfo.isComplete) {
          // User needs to complete setup
          return Right(
            UserSession.authenticated(
              user: user,
              onboardingComplete: onboardingCompleted,
              profileComplete: completenessInfo.isComplete,
            ),
          );
        }

        // User is fully set up
        return Right(UserSession.ready(user: user));
      });
    } catch (e) {
      return Left(ServerFailure('Session initialization failed: $e'));
    }
  }

  /// Sign out the current user
  ///
  /// This method only handles user sign out.
  /// It does NOT handle sync state management.
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final result = await _signOutUseCase();
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated() async {
    final result = await _checkAuthUseCase();
    return result.fold((failure) => Left(failure), (isAuth) => Right(isAuth));
  }

  /// Get current user ID
  Future<Either<Failure, String?>> getCurrentUserId() async {
    final userResult = await _getCurrentUserUseCase();
    return userResult.fold(
      (failure) => Left(failure),
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
