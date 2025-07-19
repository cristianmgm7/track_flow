import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingUseCase _onboardingUseCase;

  OnboardingBloc({required OnboardingUseCase onboardingUseCase})
    : _onboardingUseCase = onboardingUseCase,
      super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<MarkOnboardingCompleted>(_onMarkOnboardingCompleted);
    on<ResetOnboarding>(_onResetOnboarding);
    on<ResetOnboardingStatus>(_onResetOnboardingStatus);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    try {
      final onboardingResult =
          await _onboardingUseCase.checkOnboardingCompleted();

      final onboardingCompleted = onboardingResult.fold(
        (failure) => false,
        (completed) => completed,
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
      final result = await _onboardingUseCase.onboardingCompleted();
      result.fold(
        (failure) => emit(
          OnboardingError(
            'Failed to mark onboarding completed: ${failure.message}',
          ),
        ),
        (_) => emit(OnboardingCompleted()),
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
      final result = await _onboardingUseCase.resetOnboarding();
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
}
