import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Repository responsible for managing onboarding flow state
/// Follows Single Responsibility Principle - only handles onboarding completion
/// Now tracks onboarding per user for better security and UX
abstract class OnboardingRepository {
  /// Mark onboarding as completed for a specific user
  Future<Either<Failure, Unit>> onboardingCompleted(String userId);

  /// Check if onboarding is completed for a specific user
  Future<Either<Failure, bool>> checkOnboardingCompleted(String userId);

  /// Reset onboarding status for a specific user (for testing)
  Future<Either<Failure, Unit>> resetOnboarding(String userId);

  /// Clear onboarding data for a specific user (for sign out scenarios)
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId);

  /// Clear all onboarding data (for user deletion scenarios)
  Future<Either<Failure, Unit>> clearAllOnboardingData();
}
