import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Repository responsible for managing onboarding flow state
/// Follows Single Responsibility Principle - only handles onboarding completion
abstract class OnboardingRepository {
  /// Mark onboarding as completed
  Future<Either<Failure, Unit>> onboardingCompleted();

  /// Check if onboarding is completed
  Future<Either<Failure, bool>> checkOnboardingCompleted();
}