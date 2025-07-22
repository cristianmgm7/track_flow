import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session_manager/domain/entities/app_session.dart';
import 'package:trackflow/core/session_manager/domain/usecases/check_authentication_status_usecase.dart';
import 'package:trackflow/core/session_manager/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/core/session_manager/services/sync_state_manager.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session_manager/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

/// Service that handles application session management and coordination
/// Centralizes all session-related logic that was previously in AppFlowBloc
@injectable
class AppSessionService {
  final CheckAuthenticationStatusUseCase _checkAuthUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final OnboardingUseCase _onboardingUseCase;
  final CheckProfileCompletenessUseCase _profileUseCase;
  final SignOutUseCase _signOutUseCase;
  final SyncStateManager _syncStateManager;

  AppSessionService({
    required CheckAuthenticationStatusUseCase checkAuthUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required OnboardingUseCase onboardingUseCase,
    required CheckProfileCompletenessUseCase profileUseCase,
    required SignOutUseCase signOutUseCase,
    required SyncStateManager syncStateManager,
  }) : _checkAuthUseCase = checkAuthUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _onboardingUseCase = onboardingUseCase,
       _profileUseCase = profileUseCase,
       _signOutUseCase = signOutUseCase,
       _syncStateManager = syncStateManager;

  /// Initialize application session by checking all required states
  /// Returns the complete session state with all verification results
  /// OPTIMIZED: Parallelizes independent verification checks for faster startup
  Future<Either<Failure, AppSession>> initializeSession() async {
    try {
      // Step 1: Check authentication status (must be first)
      final authResult = await _checkAuthUseCase();
      final isAuthenticated = await authResult.fold((failure) async {
        return false;
      }, (isAuth) async => isAuth);

      if (!isAuthenticated) {
        return Right(const AppSession.unauthenticated());
      }

      // Step 2: Get current user (depends on auth)
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold((failure) async {
        return null;
      }, (user) async => user);

      if (user == null) {
        return Right(const AppSession.unauthenticated());
      }

      // Steps 3 & 4: PARALLEL execution - Check onboarding and profile simultaneously
      final parallelResults = await Future.wait([
        _onboardingUseCase.checkOnboardingCompleted(user.id.value),
        _profileUseCase.getDetailedCompleteness(user.id.value),
      ]);

      final onboardingResult = parallelResults[0] as Either<Failure, bool>;
      final profileResult = parallelResults[1] as Either<Failure, ProfileCompletenessInfo>;

      // Process onboarding result
      final onboardingCompleted = await onboardingResult.fold((failure) async {
        return null;
      }, (completed) async => completed);

      if (onboardingCompleted == null) {
        return Left(ServerFailure('Failed to check onboarding status'));
      }

      // Process profile result
      return await profileResult.fold(
        (failure) async {
          return Left(failure);
        },
        (completenessInfo) async {
          // Create session based on completeness
          if (!onboardingCompleted || !completenessInfo.isComplete) {
            // User needs to complete onboarding or profile
            return Right(
              AppSession.authenticated(
                user: user,
                onboardingComplete: onboardingCompleted,
                profileComplete: completenessInfo.isComplete,
              ),
            );
          }

          // User is fully set up, session is ready for sync/completion
          return Right(AppSession.ready(user: user));
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during session initialization: $e'),
      );
    }
  }

  /// Initialize data synchronization and return progress stream
  Stream<AppSession> initializeDataSync(AppSession currentSession) async* {
    if (!currentSession.isAuthenticated) {
      yield currentSession.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Cannot sync data for unauthenticated user',
      );
      return;
    }

    try {
      // Listen to sync progress and emit session updates
      await for (final syncState in _syncStateManager.syncState) {
        if (syncState.isSyncing) {
          yield currentSession.copyWith(
            status: SessionStatus.loading,
            syncProgress: syncState.progress,
          );
        } else if (syncState.isComplete) {
          yield AppSession.ready(user: currentSession.currentUser!);
          break;
        }
      }

      // Start the sync process
      await _syncStateManager.initializeIfNeeded();
    } catch (e) {
      yield currentSession.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Data sync failed: $e',
      );
    }
  }

  /// Sign out the current user and reset session state
  Future<Either<Failure, AppSession>> signOut() async {
    try {
      // Cancel any ongoing sync
      _syncStateManager.reset();

      // Sign out user
      final result = await _signOutUseCase();
      return result.fold(
        (failure) {
          return Left(failure);
        },
        (_) {
          return Right(const AppSession.unauthenticated());
        },
      );
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }
}
