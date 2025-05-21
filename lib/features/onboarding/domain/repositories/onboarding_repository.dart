abstract class OnboardingRepository {
  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Check if user has seen launch screen
  Future<bool> hasSeenLaunch();

  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted();

  /// Mark launch screen as seen
  Future<void> markLaunchScreenSeen();

  /// Get the onboarding state
  Future<bool> hasSeenOnboarding();
}
