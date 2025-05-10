import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

abstract class AuthRepository {
  /// Get the current authentication state
  Stream<AuthState> get authState;

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword(String email, String password);

  /// Sign in with Google
  Future<void> signInWithGoogle();

  /// Sign out
  Future<void> signOut();
}
