import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _onboardingRepository;

  OnboardingBloc(this._onboardingRepository) : super(OnboardingInitial()) {
    on<OnboardingCheckRequested>(_onCheckRequested);
    on<OnboardingMarkCompleted>(_onMarkCompleted);
    on<OnboardingMarkLaunchSeen>(_onMarkLaunchSeen);
  }

  Future<void> _onCheckRequested(
    OnboardingCheckRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      final hasCompletedOnboarding =
          await _onboardingRepository.hasCompletedOnboarding();
      final hasSeenLaunch = await _onboardingRepository.hasSeenLaunch();
      emit(
        OnboardingChecked(
          hasCompletedOnboarding: hasCompletedOnboarding,
          hasSeenLaunch: hasSeenLaunch,
        ),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onMarkCompleted(
    OnboardingMarkCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await _onboardingRepository.markOnboardingCompleted();
      final hasSeenLaunch = await _onboardingRepository.hasSeenLaunch();
      emit(
        OnboardingChecked(
          hasCompletedOnboarding: true,
          hasSeenLaunch: hasSeenLaunch,
        ),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onMarkLaunchSeen(
    OnboardingMarkLaunchSeen event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await _onboardingRepository.markLaunchScreenSeen();
      final hasCompletedOnboarding =
          await _onboardingRepository.hasCompletedOnboarding();
      emit(
        OnboardingChecked(
          hasCompletedOnboarding: hasCompletedOnboarding,
          hasSeenLaunch: true,
        ),
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
