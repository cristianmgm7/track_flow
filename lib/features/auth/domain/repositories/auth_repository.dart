import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

/// Repository responsible for user authentication operations
/// Follows Single Responsibility Principle - only handles authentication
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
  Future<Either<Failure, Unit>> signOut();

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get the signed in user id
  Future<Either<Failure, UserId?>> getSignedInUserId();
}
