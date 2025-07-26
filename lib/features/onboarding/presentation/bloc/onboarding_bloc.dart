import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_id_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/core/utils/app_logger.dart';
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
    AppLogger.info(
      'OnboardingBloc: Checking onboarding status',
      tag: 'ONBOARDING_BLOC',
    );

    emit(OnboardingLoading());

    try {
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold(
        (failure) async {
          AppLogger.error(
            'OnboardingBloc: Failed to get user ID: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
            error: failure,
          );
          emit(OnboardingError('Failed to get user ID: ${failure.message}'));
          return null;
        },
        (userId) async {
          AppLogger.info(
            'OnboardingBloc: Got user ID: ${userId?.value}',
            tag: 'ONBOARDING_BLOC',
          );
          return userId;
        },
      );

      if (userId == null) {
        AppLogger.error(
          'OnboardingBloc: No authenticated user found',
          tag: 'ONBOARDING_BLOC',
        );
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      AppLogger.info(
        'OnboardingBloc: Checking onboarding completed for user: ${userId.value}',
        tag: 'ONBOARDING_BLOC',
      );

      final onboardingResult = await _onboardingUseCase
          .checkOnboardingCompleted(userId.value);

      final onboardingCompleted = onboardingResult.fold(
        (failure) {
          AppLogger.warning(
            'OnboardingBloc: Onboarding check failed: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
          );
          return false;
        },
        (completed) {
          AppLogger.info(
            'OnboardingBloc: Onboarding completed: $completed',
            tag: 'ONBOARDING_BLOC',
          );
          return completed;
        },
      );

      if (onboardingCompleted) {
        AppLogger.info(
          'OnboardingBloc: Emitting OnboardingCompleted state',
          tag: 'ONBOARDING_BLOC',
        );
        emit(OnboardingCompleted());
      } else {
        AppLogger.info(
          'OnboardingBloc: Emitting OnboardingIncomplete state',
          tag: 'ONBOARDING_BLOC',
        );
        emit(OnboardingIncomplete(hasCompletedOnboarding: onboardingCompleted));
      }
    } catch (e) {
      AppLogger.error(
        'OnboardingBloc: Failed to check onboarding status: $e',
        tag: 'ONBOARDING_BLOC',
        error: e,
      );
      emit(OnboardingError('Failed to check onboarding status: $e'));
    }
  }

  Future<void> _onMarkOnboardingCompleted(
    MarkOnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.info(
      'OnboardingBloc: Marking onboarding as completed',
      tag: 'ONBOARDING_BLOC',
    );

    emit(OnboardingLoading());

    try {
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold(
        (failure) async {
          AppLogger.error(
            'OnboardingBloc: Failed to get user ID for completion: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
            error: failure,
          );
          emit(OnboardingError('Failed to get user ID: ${failure.message}'));
          return null;
        },
        (userId) async {
          AppLogger.info(
            'OnboardingBloc: Got user ID for completion: ${userId?.value}',
            tag: 'ONBOARDING_BLOC',
          );
          return userId;
        },
      );

      if (userId == null) {
        AppLogger.error(
          'OnboardingBloc: No authenticated user found for completion',
          tag: 'ONBOARDING_BLOC',
        );
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      AppLogger.info(
        'OnboardingBloc: Calling onboardingCompleted for user: ${userId.value}',
        tag: 'ONBOARDING_BLOC',
      );

      final result = await _onboardingUseCase.onboardingCompleted(userId.value);
      result.fold(
        (failure) {
          AppLogger.error(
            'OnboardingBloc: Failed to mark onboarding completed: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
            error: failure,
          );
          emit(
            OnboardingError(
              'Failed to mark onboarding completed: ${failure.message}',
            ),
          );
        },
        (_) {
          AppLogger.info(
            'OnboardingBloc: Successfully marked onboarding as completed',
            tag: 'ONBOARDING_BLOC',
          );
          AppLogger.info(
            'OnboardingBloc: Emitting OnboardingCompleted state',
            tag: 'ONBOARDING_BLOC',
          );
          emit(OnboardingCompleted());
        },
      );
    } catch (e) {
      AppLogger.error(
        'OnboardingBloc: Failed to mark onboarding completed: $e',
        tag: 'ONBOARDING_BLOC',
        error: e,
      );
      emit(OnboardingError('Failed to mark onboarding completed: $e'));
    }
  }

  Future<void> _onResetOnboarding(
    ResetOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.info(
      'OnboardingBloc: Resetting onboarding state',
      tag: 'ONBOARDING_BLOC',
    );
    emit(OnboardingInitial());
  }

  Future<void> _onResetOnboardingStatus(
    ResetOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.info(
      'OnboardingBloc: Resetting onboarding status',
      tag: 'ONBOARDING_BLOC',
    );

    emit(OnboardingLoading());

    try {
      // Get current user ID
      final userIdResult = await _getCurrentUserIdUseCase();
      final userId = await userIdResult.fold((failure) async {
        AppLogger.error(
          'OnboardingBloc: Failed to get user ID for reset: ${failure.message}',
          tag: 'ONBOARDING_BLOC',
          error: failure,
        );
        emit(OnboardingError('Failed to get user ID: ${failure.message}'));
        return null;
      }, (userId) async => userId);

      if (userId == null) {
        AppLogger.error(
          'OnboardingBloc: No authenticated user found for reset',
          tag: 'ONBOARDING_BLOC',
        );
        emit(OnboardingError('No authenticated user found'));
        return;
      }

      final result = await _onboardingUseCase.resetOnboarding(userId.value);
      result.fold(
        (failure) {
          AppLogger.error(
            'OnboardingBloc: Failed to reset onboarding: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
            error: failure,
          );
          emit(
            OnboardingError('Failed to reset onboarding: ${failure.message}'),
          );
        },
        (_) {
          AppLogger.info(
            'OnboardingBloc: Successfully reset onboarding status',
            tag: 'ONBOARDING_BLOC',
          );
          emit(OnboardingIncomplete(hasCompletedOnboarding: false));
        },
      );
    } catch (e) {
      AppLogger.error(
        'OnboardingBloc: Failed to reset onboarding: $e',
        tag: 'ONBOARDING_BLOC',
        error: e,
      );
      emit(OnboardingError('Failed to reset onboarding: $e'));
    }
  }

  Future<void> _onClearAllOnboardingData(
    ClearAllOnboardingData event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.info(
      'OnboardingBloc: Clearing all onboarding data',
      tag: 'ONBOARDING_BLOC',
    );

    emit(OnboardingLoading());

    try {
      final result = await _onboardingUseCase.clearAllOnboardingData();
      result.fold(
        (failure) {
          AppLogger.error(
            'OnboardingBloc: Failed to clear onboarding data: ${failure.message}',
            tag: 'ONBOARDING_BLOC',
            error: failure,
          );
          emit(
            OnboardingError(
              'Failed to clear onboarding data: ${failure.message}',
            ),
          );
        },
        (_) {
          AppLogger.info(
            'OnboardingBloc: Successfully cleared all onboarding data',
            tag: 'ONBOARDING_BLOC',
          );
          emit(OnboardingIncomplete(hasCompletedOnboarding: false));
        },
      );
    } catch (e) {
      AppLogger.error(
        'OnboardingBloc: Failed to clear onboarding data: $e',
        tag: 'ONBOARDING_BLOC',
        error: e,
      );
      emit(OnboardingError('Failed to clear onboarding data: $e'));
    }
  }
}
