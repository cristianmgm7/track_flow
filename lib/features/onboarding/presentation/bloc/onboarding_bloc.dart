import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _onboardingRepository;

  OnboardingBloc(this._onboardingRepository) : super(OnboardingInitial()) {
    on<OnboardingMarkCompleted>(_onboardingMarkCompleted);
    on<WelcomeScreenMarkCompleted>(_welcomeScreenMarkCompleted);
  }

  Future<void> _onboardingMarkCompleted(
    OnboardingMarkCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _onboardingRepository.onboardingCompleted();
  }

  Future<void> _welcomeScreenMarkCompleted(
    WelcomeScreenMarkCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _onboardingRepository.welcomeScreenSeenCompleted();
  }
}
