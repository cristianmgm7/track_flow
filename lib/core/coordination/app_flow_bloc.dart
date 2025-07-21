import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/coordination/app_flow_%20events.dart';
import 'package:trackflow/core/coordination/app_flow_state.dart';
import 'package:trackflow/core/coordination/sync_state_manager.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AuthUseCase _authUseCase;
  final OnboardingUseCase _onboardingUseCase;
  final CheckProfileCompletenessUseCase _profileUseCase;
  final SyncStateManager _syncStateManager;

  AppFlowBloc({
    required AuthUseCase authUseCase,
    required OnboardingUseCase onboardingUseCase,
    required CheckProfileCompletenessUseCase profileUseCase,
    required SyncStateManager syncStateManager,
  }) : _authUseCase = authUseCase,
       _onboardingUseCase = onboardingUseCase,
       _profileUseCase = profileUseCase,
       _syncStateManager = syncStateManager,
       super(AppFlowInitial()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<UserAuthenticated>(_onUserAuthenticated);
    on<UserSignedOut>(_onUserSignedOut);
  }

  Future<void> _onUserAuthenticated(
    UserAuthenticated event,
    Emitter<AppFlowState> emit,
  ) async {
    add(CheckAppFlow());
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    emit(AppFlowLoading());

    try {
      // Step 1: Check auth status
      final authResult = await _authUseCase.isAuthenticated();
      final isAuthenticated = await authResult.fold(
        (failure) async => false,
        (isAuth) async => isAuth,
      );

      // If not authenticated, reset sync and emit unauthenticated
      if (!isAuthenticated) {
        _syncStateManager.reset();
        emit(AppFlowUnauthenticated());
        return;
      }

      // Step 2: Get current user ID
      final userIdResult = await _authUseCase.getCurrentUserId();
      final userId = await userIdResult.fold((failure) async {
        emit(AppFlowError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        emit(AppFlowUnauthenticated());
        return;
      }

      // Step 3: Initialize data sync with progress updates
      try {
        // Listen to sync progress and update state accordingly
        final syncSubscription = _syncStateManager.syncState.listen((syncState) {
          if (syncState.isSyncing) {
            emit(AppFlowSyncing(syncState.progress));
          }
        });

        // Start sync and wait for completion
        await _syncStateManager.initializeIfNeeded();
        
        // Cancel subscription after sync is complete
        await syncSubscription.cancel();
        
      } catch (syncError) {
        emit(AppFlowError('Data sync failed: $syncError'));
        return;
      }

      // Step 4: Check onboarding status (after sync is complete)
      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);

      final onboardingCompleted = await onboardingResult.fold(
        (failure) async => null,
        (completed) async => completed,
      );

      if (onboardingCompleted == null) {
        emit(AppFlowError('Failed to check onboarding status'));
        return;
      }

      if (!onboardingCompleted) {
        emit(AppFlowNeedsOnboarding());
        return;
      }

      // Step 5: Check profile completeness (after sync is complete)
      final profileResult = await _profileUseCase.getDetailedCompleteness(
        userId.value,
      );

      await profileResult.fold(
        (failure) async {
          emit(AppFlowError('Failed to check profile: ${failure.message}'));
        },
        (completenessInfo) async {
          if (completenessInfo.isComplete) {
            emit(AppFlowReady());
          } else {
            emit(AppFlowNeedsProfileSetup());
          }
        },
      );
      
    } catch (e) {
      emit(AppFlowError('Unexpected error: $e'));
    }
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AppFlowState> emit,
  ) async {
    // Reset sync state when user signs out
    _syncStateManager.reset();
    emit(AppFlowUnauthenticated());
  }
}
