import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/coordination/domain/entities/app_session.dart';
import 'package:trackflow/core/coordination/domain/usecases/check_authentication_status_usecase.dart';
import 'package:trackflow/core/coordination/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/core/coordination/sync_state_manager.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
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
  Future<Either<Failure, AppSession>> initializeSession() async {
    print('🔄 [AppSessionService] initializeSession() started');

    try {
      // Step 1: Check authentication status
      print('🔄 [AppSessionService] Step 1: Checking authentication status');
      final authResult = await _checkAuthUseCase();
      final isAuthenticated = await authResult.fold((failure) async {
        print('❌ [AppSessionService] Auth check failed: ${failure.message}');
        return false;
      }, (isAuth) async => isAuth);

      if (!isAuthenticated) {
        print('🔄 [AppSessionService] User not authenticated');
        return Right(const AppSession.unauthenticated());
      }

      // Step 2: Get current user
      print('🔄 [AppSessionService] Step 2: Getting current user');
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold((failure) async {
        print(
          '❌ [AppSessionService] Failed to get user: ${failure.message}',
        );
        return null;
      }, (user) async => user);

      if (user == null) {
        print('🔄 [AppSessionService] User is null');
        return Right(const AppSession.unauthenticated());
      }

      print('🔄 [AppSessionService] User: ${user.email} (${user.id.value})');

      // Step 3: Check onboarding status
      print('🔄 [AppSessionService] Step 3: Checking onboarding status');
      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(user.id.value);
      final onboardingCompleted = await onboardingResult.fold((failure) async {
        print(
          '❌ [AppSessionService] Onboarding check failed: ${failure.message}',
        );
        return null;
      }, (completed) async => completed);

      if (onboardingCompleted == null) {
        print('❌ [AppSessionService] Failed to check onboarding status');
        return Left(ServerFailure('Failed to check onboarding status'));
      }

      print(
        '🔄 [AppSessionService] Onboarding completed: $onboardingCompleted',
      );

      // Step 4: Check profile completeness
      print('🔄 [AppSessionService] Step 4: Checking profile completeness');
      final profileResult = await _profileUseCase.getDetailedCompleteness(
        user.id.value,
      );

      return await profileResult.fold(
        (failure) async {
          print(
            '❌ [AppSessionService] Profile check failed: ${failure.message}',
          );
          return Left(failure);
        },
        (completenessInfo) async {
          print(
            '🔄 [AppSessionService] Profile completeness: ${completenessInfo.isComplete}',
          );

          // Create session based on completeness
          if (!onboardingCompleted || !completenessInfo.isComplete) {
            // User needs to complete onboarding or profile
            // Note: We'd need to get the actual User entity here
            // For now, we'll return incomplete session
            return Right(
              AppSession.authenticatedIncomplete(
                user: user,
                onboardingComplete: onboardingCompleted,
                profileComplete: completenessInfo.isComplete,
              ),
            );
          }

          // User is fully set up, session is ready for sync/completion
          return Right(
            AppSession.ready(user: user),
          );
        },
      );
    } catch (e) {
      print('❌ [AppSessionService] Unexpected error: $e');
      return Left(
        ServerFailure('Unexpected error during session initialization: $e'),
      );
    }
  }

  /// Initialize data synchronization and return progress stream
  Stream<AppSession> initializeDataSync(AppSession currentSession) async* {
    print('🔄 [AppSessionService] initializeDataSync() started');

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
        print(
          '🔄 [AppSessionService] Sync progress: ${(syncState.progress * 100).toInt()}%',
        );

        if (syncState.isSyncing) {
          yield AppSession.syncing(
            user: currentSession.currentUser!,
            progress: syncState.progress,
          );
        } else if (syncState.isComplete) {
          print('🔄 [AppSessionService] Sync completed successfully');
          yield AppSession.ready(user: currentSession.currentUser!);
          break;
        }
      }

      // Start the sync process
      await _syncStateManager.initializeIfNeeded();
    } catch (e) {
      print('❌ [AppSessionService] Sync error: $e');
      yield currentSession.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Data sync failed: $e',
      );
    }
  }

  /// Sign out the current user and reset session state
  Future<Either<Failure, AppSession>> signOut() async {
    print('🔄 [AppSessionService] signOut() started');

    try {
      // Cancel any ongoing sync
      _syncStateManager.reset();

      // Sign out user
      final result = await _signOutUseCase();
      return result.fold(
        (failure) {
          print('❌ [AppSessionService] Sign out failed: ${failure.message}');
          return Left(failure);
        },
        (_) {
          print('🔄 [AppSessionService] Sign out successful');
          return Right(const AppSession.unauthenticated());
        },
      );
    } catch (e) {
      print('❌ [AppSessionService] Sign out exception: $e');
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }
}
