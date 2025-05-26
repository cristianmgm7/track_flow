import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Get the current authentication state
  Stream<User?> get authState;

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  // is logged in
  Future<bool> isLoggedIn();

  /// mark onboarding as completed
  Future<bool> onboardingCompleted();

  /// mark welcome screen as completed
  Future<void> welcomeScreenSeenCompleted();

  /// Check if user has seen welcome screen
  Future<bool> checkWelcomeScreenSeen();

  /// check if onboarding is completed
  Future<bool> checkOnboardingCompleted();
}
