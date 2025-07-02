import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Repository responsible for managing welcome screen state
/// Follows Single Responsibility Principle - only handles welcome screen visibility
abstract class WelcomeScreenRepository {
  /// Mark welcome screen as seen/completed
  Future<Either<Failure, Unit>> welcomeScreenSeenCompleted();

  /// Check if user has seen welcome screen
  Future<Either<Failure, bool>> checkWelcomeScreenSeen();
}