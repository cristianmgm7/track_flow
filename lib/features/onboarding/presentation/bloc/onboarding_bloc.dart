import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session_manager/domain/usecases/get_current_user_id_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingUseCase _onboardingUseCase;
  final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;

  OnboardingBloc({
    required OnboardingUseCase onboardingUseCase,
    required GetCurrentUserIdUseCase getCurrentUserIdUseCase,
  }) : _onboardingUseCase = onboardingUseCase,
       _getCurrentUserIdUseCase = getCurrentUserIdUseCase,
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
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold((failure) async {
        emit(OnboardingError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);

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
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold((failure) async {
        emit(OnboardingError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final result = await _onboardingUseCase.onboardingCompleted(userId.value);
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
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold((failure) async {
        emit(OnboardingError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final result = await _onboardingUseCase.resetOnboarding(userId.value);
      result.fold(
        (failure) => emit(
          OnboardingError('Failed to reset onboarding: ${failure.message}'),
        ),
        (_) => emit(OnboardingIncomplete(hasCompletedOnboarding: false)),
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
        (failure) => emit(
          OnboardingError(
            'Failed to clear onboarding data: ${failure.message}',
          ),
        ),
        (_) => emit(OnboardingIncomplete(hasCompletedOnboarding: false)),
      );
    } catch (e) {
      emit(OnboardingError('Failed to clear onboarding data: $e'));
    }
  }
}
