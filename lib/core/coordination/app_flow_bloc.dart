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
          emit(AppFlowUnauthenticated());
          return null;
        },
        (isAuthenticated) async {
          if (!isAuthenticated) {
            emit(AppFlowUnauthenticated());
            return null;
          }
          return isAuthenticated;
        },
      );

      // If auth failed or user not authenticated, return early
      if (authEither == null) return;

      // Check onboarding status
      final onboardingResult =
          await _onboardingUseCase.checkOnboardingCompleted();

      final onboardingEither = await onboardingResult.fold(
        (failure) async {
          emit(AppFlowError('Failed to check onboarding: ${failure.message}'));
          return null;
        },
        (onboardingCompleted) async {
          if (!onboardingCompleted) {
            emit(AppFlowNeedsOnboarding());
            return null;
          }
          return onboardingCompleted;
        },
      );

      // If onboarding failed or not completed, return early
      if (onboardingEither == null) return;

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
