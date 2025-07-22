import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/coordination/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/coordination/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/coordination/sync_state_manager.dart';
import 'package:trackflow/core/coordination/sync_state.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AuthUseCase _authUseCase;
  final OnboardingUseCase _onboardingUseCase;
  final CheckProfileCompletenessUseCase _profileUseCase;
  final SyncStateManager _syncStateManager;

  StreamSubscription<SyncState>? _syncSubscription;
  bool _isCheckingFlow = false; // Prevent multiple simultaneous checks

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

  @override
  Future<void> close() {
    print('🔄 [AppFlowBloc] close() called');
    _syncSubscription?.cancel();
    return super.close();
  }

  Future<void> _onUserAuthenticated(
    UserAuthenticated event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 [AppFlowBloc] _onUserAuthenticated() called');
    add(CheckAppFlow());
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    // Prevent multiple simultaneous checks
    if (_isCheckingFlow) {
      print('🔄 [AppFlowBloc] CheckAppFlow already in progress, skipping');
      return;
    }

    _isCheckingFlow = true;
    print('🔄 [AppFlowBloc] _onCheckAppFlow() started');
    emit(AppFlowLoading());
    print('🔄 [AppFlowBloc] Emitted AppFlowLoading');

    try {
      // Step 1: Check auth status
      print('🔄 [AppFlowBloc] Step 1: Checking auth status');
      final authResult = await _authUseCase.isAuthenticated();
      final isAuthenticated = await authResult.fold(
        (failure) async => false,
        (isAuth) async => isAuth,
      );
      print('🔄 [AppFlowBloc] Auth result: $isAuthenticated');

      // If not authenticated, reset sync and emit unauthenticated
      if (!isAuthenticated) {
        print('🔄 [AppFlowBloc] User not authenticated, resetting sync');
        _syncStateManager.reset();
        emit(AppFlowUnauthenticated());
        print('🔄 [AppFlowBloc] Emitted AppFlowUnauthenticated');
        return;
      }

      // Step 2: Get current user ID
      print('🔄 [AppFlowBloc] Step 2: Getting current user ID');
      final userIdResult = await _authUseCase.getCurrentUserId();
      final userId = await userIdResult.fold((failure) async {
        print('❌ [AppFlowBloc] Failed to get user ID: ${failure.message}');
        emit(AppFlowError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        print('🔄 [AppFlowBloc] User ID is null, emitting unauthenticated');
        emit(AppFlowUnauthenticated());
        return;
      }
      print('🔄 [AppFlowBloc] User ID: ${userId.value}');

      // Step 3: Initialize data sync with progress updates
      print('🔄 [AppFlowBloc] Step 3: Starting data sync');
      try {
        // Cancel any existing subscription
        await _syncSubscription?.cancel();

        // Listen to sync progress and update state accordingly
        print('🔄 [AppFlowBloc] Setting up sync subscription');
        _syncSubscription = _syncStateManager.syncState.listen(
          (syncState) {
            print(
              '🔄 [AppFlowBloc] Sync state update: ${syncState.status} - ${(syncState.progress * 100).toInt()}%',
            );
            if (syncState.isSyncing) {
              emit(AppFlowSyncing(syncState.progress));
              print(
                '🔄 [AppFlowBloc] Emitted AppFlowSyncing(${syncState.progress})',
              );
            }
          },
          onError: (error) {
            print('❌ [AppFlowBloc] Sync subscription error: $error');
            emit(AppFlowError('Sync failed: $error'));
          },
        );

        // Start sync and wait for completion
        print('🔄 [AppFlowBloc] Calling SyncStateManager.initializeIfNeeded()');
        await _syncStateManager.initializeIfNeeded();
        print('🔄 [AppFlowBloc] Sync completed');
      } catch (syncError) {
        print('❌ [AppFlowBloc] Sync error: $syncError');
        emit(AppFlowError('Data sync failed: $syncError'));
        return;
      } finally {
        // Clean up subscription
        print('🔄 [AppFlowBloc] Cleaning up sync subscription');
        await _syncSubscription?.cancel();
        _syncSubscription = null;
      }

      // Step 4: Check onboarding status (after sync is complete)
      print('🔄 [AppFlowBloc] Step 4: Checking onboarding status');
      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);

      final onboardingCompleted = await onboardingResult.fold(
        (failure) async => null,
        (completed) async => completed,
      );
      print('🔄 [AppFlowBloc] Onboarding completed: $onboardingCompleted');

      if (onboardingCompleted == null) {
        print('❌ [AppFlowBloc] Failed to check onboarding status');
        emit(AppFlowError('Failed to check onboarding status'));
        return;
      }

      if (!onboardingCompleted) {
        print('🔄 [AppFlowBloc] User needs onboarding');
        emit(AppFlowNeedsOnboarding());
        print('🔄 [AppFlowBloc] Emitted AppFlowNeedsOnboarding');
        return;
      }

      // Step 5: Check profile completeness (after sync is complete)
      print('🔄 [AppFlowBloc] Step 5: Checking profile completeness');
      final profileResult = await _profileUseCase.getDetailedCompleteness(
        userId.value,
      );

      await profileResult.fold(
        (failure) async {
          print('❌ [AppFlowBloc] Failed to check profile: ${failure.message}');
          emit(AppFlowError('Failed to check profile: ${failure.message}'));
        },
        (completenessInfo) async {
          print(
            '🔄 [AppFlowBloc] Profile completeness: ${completenessInfo.isComplete}',
          );
          if (completenessInfo.isComplete) {
            print('🔄 [AppFlowBloc] User profile is complete, emitting ready');
            emit(AppFlowReady());
            print('🔄 [AppFlowBloc] Emitted AppFlowReady');
          } else {
            print('🔄 [AppFlowBloc] User needs profile setup');
            emit(AppFlowNeedsProfileSetup());
            print('🔄 [AppFlowBloc] Emitted AppFlowNeedsProfileSetup');
          }
        },
      );
    } catch (e) {
      print('❌ [AppFlowBloc] Unexpected error: $e');
      emit(AppFlowError('Unexpected error: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 [AppFlowBloc] _onUserSignedOut() called');
    // Cancel any ongoing sync subscription
    await _syncSubscription?.cancel();
    _syncSubscription = null;

    // Reset sync state when user signs out
    _syncStateManager.reset();
    emit(AppFlowUnauthenticated());
    print('🔄 [AppFlowBloc] Emitted AppFlowUnauthenticated after sign out');
  }
}
