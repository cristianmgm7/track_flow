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

  Future<void> _onUserAuthenticated(
    UserAuthenticated event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 AppFlowBloc - UserAuthenticated event received');
    add(CheckAppFlow());
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 AppFlowBloc - CheckAppFlow started');
    emit(AppFlowLoading());

    try {
      // Check auth status
      final authResult = await _authUseCase.isAuthenticated();
      print('🔍 AppFlowBloc - Auth check result: $authResult');

      final authEither = await authResult.fold(
        (failure) async {
          // Don't emit here, return failure to handle below
          print('❌ AppFlowBloc - Auth failed: ${failure.message}');
          return false;
        },
        (isAuthenticated) async {
          print('✅ AppFlowBloc - Auth successful: $isAuthenticated');
          return isAuthenticated;
        },
      );

      // If not authenticated, emit and return
      if (!authEither) {
        print(
          '❌ AppFlowBloc - User not authenticated, emitting unauthenticated',
        );
        emit(AppFlowUnauthenticated());
        return;
      }

      // Get current user ID for user-specific onboarding check
      final userIdResult = await _authUseCase.getCurrentUserId();
      final userId = await userIdResult.fold(
        (failure) async {
          print('❌ AppFlowBloc - Failed to get user ID: ${failure.message}');
          emit(AppFlowError('Failed to get user ID: ${failure.message}'));
          return null;
        },
        (userId) async {
          print('✅ AppFlowBloc - Got user ID: ${userId?.value}');
          return userId;
        },
      );

      if (userId == null) {
        print('❌ AppFlowBloc - No user ID, emitting unauthenticated');
        emit(AppFlowUnauthenticated());
        return;
      }

      // Check onboarding status for specific user
      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);
      print('🔍 AppFlowBloc - Onboarding check result: $onboardingResult');

      final onboardingEither = await onboardingResult.fold(
        (failure) async {
          // Don't emit here, return null to handle below
          print('❌ AppFlowBloc - Onboarding check failed: ${failure.message}');
          return null;
        },
        (onboardingCompleted) async {
          print('✅ AppFlowBloc - Onboarding completed: $onboardingCompleted');
          return onboardingCompleted;
        },
      );

      // If onboarding failed, emit error and return
      if (onboardingEither == null) {
        print('❌ AppFlowBloc - Onboarding failed, emitting error');
        emit(AppFlowError('Failed to check onboarding status'));
        return;
      }

      // If onboarding not completed, emit and return
      if (!onboardingEither) {
        print(
          '🔄 AppFlowBloc - Onboarding not completed, emitting needs onboarding',
        );
        emit(AppFlowNeedsOnboarding());
        return;
      }

      // Check profile completeness for specific user
      print(
        '🔍 AppFlowBloc - Checking profile completeness for user: ${userId.value}',
      );
      final profileResult = await _profileUseCase.getDetailedCompleteness(
        userId.value,
      );
      print('🔍 AppFlowBloc - Profile check result: $profileResult');

      await profileResult.fold(
        (failure) async {
          print('❌ AppFlowBloc - Profile check failed: ${failure.message}');
          emit(AppFlowError('Failed to check profile: ${failure.message}'));
        },
        (completenessInfo) async {
          print(
            '✅ AppFlowBloc - Profile completeness: ${completenessInfo.isComplete}',
          );
          print('📝 AppFlowBloc - Profile reason: ${completenessInfo.reason}');

          if (completenessInfo.isComplete) {
            print('🎉 AppFlowBloc - Profile complete, emitting ready');
            emit(AppFlowReady());
          } else {
            print(
              '🔄 AppFlowBloc - Profile incomplete, emitting needs profile setup',
            );
            emit(AppFlowNeedsProfileSetup());
          }
        },
      );
    } catch (e) {
      print('❌ AppFlowBloc - Unexpected error: $e');
      emit(AppFlowError('Unexpected error: $e'));
    }
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AppFlowState> emit,
  ) async {
    emit(AppFlowUnauthenticated());
  }
}
