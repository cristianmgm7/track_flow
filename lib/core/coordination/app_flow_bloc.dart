import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/coordination/app_flow_%20events.dart';
import 'package:trackflow/core/coordination/app_flow_state.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AuthUseCase _authUseCase;
  final OnboardingUseCase _onboardingUseCase;
  final CheckProfileCompletenessUseCase _profileUseCase;

  AppFlowBloc({
    required AuthUseCase authUseCase,
    required OnboardingUseCase onboardingUseCase,
    required CheckProfileCompletenessUseCase profileUseCase,
  }) : _authUseCase = authUseCase,
       _onboardingUseCase = onboardingUseCase,
       _profileUseCase = profileUseCase,
       super(AppFlowInitial()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<UserAuthenticated>(_onUserAuthenticated);
    on<UserSignedOut>(_onUserSignedOut);
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    emit(AppFlowLoading());

    try {
      // Check auth status
      final authResult = await _authUseCase.isAuthenticated();

      final authEither = await authResult.fold(
        (failure) async {
          // Don't emit here, return failure to handle below
          return false;
        },
        (isAuthenticated) async {
          return isAuthenticated;
        },
      );

      // If not authenticated, emit and return
      if (!authEither) {
        emit(AppFlowUnauthenticated());
        return;
      }

      // Get current user ID for user-specific onboarding check
      final userIdResult = await _authUseCase.getCurrentUserId();
      final userId = await userIdResult.fold((failure) async {
        emit(AppFlowError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        emit(AppFlowUnauthenticated());
        return;
      }

      // Check onboarding status for specific user
      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);

      final onboardingEither = await onboardingResult.fold(
        (failure) async {
          // Don't emit here, return null to handle below
          return null;
        },
        (onboardingCompleted) async {
          return onboardingCompleted;
        },
      );

      // If onboarding failed, emit error and return
      if (onboardingEither == null) {
        emit(AppFlowError('Failed to check onboarding status'));
        return;
      }

      // If onboarding not completed, emit and return
      if (!onboardingEither) {
        emit(AppFlowNeedsOnboarding());
        return;
      }

      // Check profile completeness
      final profileResult = await _profileUseCase.getDetailedCompleteness();

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

  Future<void> _onUserAuthenticated(
    UserAuthenticated event,
    Emitter<AppFlowState> emit,
  ) async {
    add(CheckAppFlow());
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AppFlowState> emit,
  ) async {
    emit(AppFlowUnauthenticated());
  }
}
