import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<OnboardingStarted>(_onOnboardingStarted);
    on<OnboardingStepCompleted>(_onOnboardingStepCompleted);
    on<CompleteOnboarding>(_onOnboardingCompleted);
  }

  Future<void> _onOnboardingStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('hasCompletedOnboarding') ?? false;

      if (hasCompletedOnboarding) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingInitial());
      }
    } catch (e) {
      emit(OnboardingError('Failed to check onboarding status'));
    }
  }

  Future<void> _onOnboardingStepCompleted(
    OnboardingStepCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onboardingStep', event.step);
      emit(OnboardingInitial());
    } catch (e) {
      emit(OnboardingError('Failed to save onboarding step'));
    }
  }

  Future<void> _onOnboardingCompleted(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Failed to complete onboarding'));
    }
  }
}
