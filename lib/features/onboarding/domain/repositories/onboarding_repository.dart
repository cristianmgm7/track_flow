abstract class OnboardingRepository {
  /// mark onboarding as completed
  Future<bool> onboardingCompleted();

  /// mark welcome screen as completed
  Future<void> welcomeScreenSeenCompleted();

  /// Check if user has seen welcome screen
  Future<bool> checkWelcomeScreenSeen();

  /// check if onboarding is completed
  Future<bool> checkOnboardingCompleted();
}
