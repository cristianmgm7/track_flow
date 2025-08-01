import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/data/services/google_auth_service.dart';

abstract class AuthRemoteDataSource {
  Future<User?> getCurrentUser();
  Stream<User?> authStateChanges();
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleAuthService _googleAuthService;

  AuthRemoteDataSourceImpl(
    this._auth,
    this._googleAuthService,
  );

  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Stream<User?> authStateChanges() async* {
    // First emit current user immediately (fixes hot reload timeouts)
    yield _auth.currentUser;

    // Then listen to future auth state changes
    await for (final user in _auth.authStateChanges()) {
      yield user;
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  @override
  Future<User?> signInWithGoogle() async {
    final result = await _googleAuthService.authenticateWithGoogle();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (authResult) => authResult.user,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleAuthService.signOut();
  }
}
