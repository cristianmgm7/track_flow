import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/data/models/user_dto.dart';
import 'package:trackflow/core/error/failures.dart';

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
  Stream<domain.User?> get authState {
    if (_isOfflineMode) {
      final hasStoredCredentials = _prefs.getBool('has_credentials') ?? false;
      if (!hasStoredCredentials) return Stream.value(null);
      final email = _prefs.getString('offline_email') ?? '';
      return Stream.value(domain.User(id: 'offline', email: email));
    }
    return _auth!.authStateChanges().map((user) {
      if (user == null) return null;
      return UserDto.fromFirebase(user).toDomain();
    });
  }

  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (_isOfflineMode) {
        await _prefs.setBool('has_credentials', true);
        await _prefs.setString('offline_email', email);
        return right(domain.User(id: 'offline', email: email));
      }
      final cred = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null)
        return left(AuthenticationFailure('No user found after sign in'));
      return right(UserDto.fromFirebase(user).toDomain());
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (_isOfflineMode) {
        await _prefs.setBool('has_credentials', true);
        await _prefs.setString('offline_email', email);
        return right(domain.User(id: 'offline', email: email));
      }
      final cred = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null)
        return left(AuthenticationFailure('No user found after sign up'));
      return right(UserDto.fromFirebase(user).toDomain());
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      if (_isOfflineMode) {
        return left(
          AuthenticationFailure(
            'Google sign in is not available in offline mode',
          ),
        );
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return left(AuthenticationFailure('Google sign in was cancelled'));
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth!.signInWithCredential(credential);
      final user = cred.user;
      if (user == null)
        return left(
          AuthenticationFailure('No user found after Google sign in'),
        );
      return right(UserDto.fromFirebase(user).toDomain());
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
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
