import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingUseCase _onboardingUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  OnboardingBloc({
    required OnboardingUseCase onboardingUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _onboardingUseCase = onboardingUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<MarkOnboardingCompleted>(_onMarkOnboardingCompleted);
    on<ResetOnboarding>(_onResetOnboarding);
    on<ResetOnboardingStatus>(_onResetOnboardingStatus);
    on<ClearAllOnboardingData>(_onClearAllOnboardingData);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      // Get current user
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold(
        (failure) async {
          emit(OnboardingError('Failed to get user: ${failure.message}'));
          return null;
        },
        (user) async {
          return user;
        },
      );

      if (user?.id == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(user!.id.value);

      final onboardingCompleted = onboardingResult.fold(
        (failure) {
          return false;
        },
        (completed) {
          return completed;
        },
      );

      if (onboardingCompleted) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingIncomplete(hasCompletedOnboarding: onboardingCompleted));
      }
    } catch (e) {
      emit(OnboardingError('Failed to check onboarding status: $e'));
    }
  }

  Future<void> _onMarkOnboardingCompleted(
    MarkOnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      // Get current user
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold(
        (failure) async {
          emit(OnboardingError('Failed to get user: ${failure.message}'));
          return null;
        },
        (user) async {
          return user;
        },
      );

      if (user?.id == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final result = await _onboardingUseCase.onboardingCompleted(
        user!.id.value,
      );
      result.fold(
        (failure) {
          emit(
            OnboardingError(
              'Failed to mark onboarding completed: ${failure.message}',
            ),
          );
        },
        (_) {
          emit(OnboardingCompleted());
        },
      );
    } catch (e) {
      emit(OnboardingError('Failed to mark onboarding completed: $e'));
    }
  }

  Future<void> _onResetOnboarding(
    ResetOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingInitial());
  }

  Future<void> _onResetOnboardingStatus(
    ResetOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      // Get current user
      final userResult = await _getCurrentUserUseCase();
      final user = await userResult.fold((failure) async {
        emit(OnboardingError('Failed to get user: ${failure.message}'));
        return null;
      }, (user) async => user);

      if (user?.id == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final result = await _onboardingUseCase.resetOnboarding(user!.id.value);
      result.fold(
        (failure) {
          emit(
            OnboardingError('Failed to reset onboarding: ${failure.message}'),
          );
        },
        (_) {
          emit(OnboardingIncomplete(hasCompletedOnboarding: false));
        },
      );
    } catch (e) {
      emit(OnboardingError('Failed to reset onboarding: $e'));
    }
  }

  Future<void> _onClearAllOnboardingData(
    ClearAllOnboardingData event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      final result = await _onboardingUseCase.clearAllOnboardingData();
      result.fold(
        (failure) {
          emit(
            OnboardingError(
              'Failed to clear onboarding data: ${failure.message}',
            ),
          );
        },
        (_) {
          emit(OnboardingIncomplete(hasCompletedOnboarding: false));
        },
      );
    } catch (e) {
      emit(OnboardingError('Failed to clear onboarding data: $e'));
    }
  }
}
