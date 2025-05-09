abstract class OnboardingEvent {}

class OnboardingStarted extends OnboardingEvent {}

class OnboardingStepCompleted extends OnboardingEvent {
  final int step;
  OnboardingStepCompleted(this.step);
}

class CompleteOnboarding extends OnboardingEvent {}
