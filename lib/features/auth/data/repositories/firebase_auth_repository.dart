import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _auth;
  final GoogleSignIn? _googleSignIn;
  final SharedPreferences _prefs;
  bool _isOfflineMode = false;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    required SharedPreferences prefs,
  }) : _auth = auth,
       _googleSignIn = googleSignIn,
       _prefs = prefs {
    // Check if we're in offline mode
    try {
      if (_auth == null) {
        _isOfflineMode = true;
        debugPrint('Running in offline mode - Auth services not available');
      }
    } catch (e) {
      _isOfflineMode = true;
      debugPrint('Error initializing auth services: $e');
    }
  }

  @override
  Stream<AuthState> get authState {
    if (_isOfflineMode) {
      // In offline mode, check if we have stored credentials
      final hasStoredCredentials = _prefs.getBool('has_credentials') ?? false;
      return Stream.value(
        hasStoredCredentials
            ? AuthAuthenticated(null, true)
            : AuthUnauthenticated(),
      );
    }

    return _auth!.authStateChanges().map((user) {
      if (user == null) {
        return AuthUnauthenticated();
      }
      return AuthAuthenticated(user, false);
    });
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (_isOfflineMode) {
      // In offline mode, store simple credentials
      await _prefs.setBool('has_credentials', true);
      await _prefs.setString('offline_email', email);
      return;
    }

    await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    if (_isOfflineMode) {
      // In offline mode, store simple credentials
      await _prefs.setBool('has_credentials', true);
      await _prefs.setString('offline_email', email);
      return;
    }

    await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    if (_isOfflineMode) {
      throw Exception('Google sign in is not available in offline mode');
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in was cancelled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth!.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    if (_isOfflineMode) {
      await _prefs.setBool('has_credentials', false);
      await _prefs.remove('offline_email');
      return;
    }

    await Future.wait([_auth!.signOut(), _googleSignIn!.signOut()]);
  }
}
