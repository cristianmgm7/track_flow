import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';

/// Service responsible for Google authentication with enhanced data extraction
@lazySingleton
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  GoogleAuthService(this._googleSignIn, this._firebaseAuth);

  /// Authenticates user with Google and extracts all available data
  Future<Either<Failure, GoogleAuthResult>> authenticateWithGoogle() async {
    try {
      // ✅ NUEVO: Configuración específica para emuladores
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // ✅ NUEVO: Configuración para emuladores - usar serverClientId en lugar de clientId
        serverClientId:
            '411076004525-6sfjv4mkbab89b81jn3so4o6s8om46sa.apps.googleusercontent.com', // Web client ID
      );

      // 1. Get Google account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AuthenticationFailure('Google sign in cancelled'));
      }

      // 2. Get Google authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Authenticate with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return Left(
          AuthenticationFailure('No user found after Google sign in'),
        );
      }

      // 5. Determine if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // 6. Extract Google data with fallbacks
      final googleData = GoogleUserData(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? googleUser.email,
        displayName: firebaseUser.displayName ?? googleUser.displayName,
        photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        isNewUser: isNewUser,
      );

      return Right(
        GoogleAuthResult(
          user: firebaseUser,
          googleData: googleData,
          isNewUser: isNewUser,
        ),
      );
    } catch (e) {
      // ✅ NUEVO: Manejo específico de errores comunes
      String errorMessage = 'Google authentication failed: ${e.toString()}';

      if (e.toString().contains('network_error') ||
          e.toString().contains('NETWORK_ERROR')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('sign_in_canceled') ||
          e.toString().contains('SIGN_IN_CANCELED')) {
        errorMessage = 'Sign in was cancelled. Please try again.';
      } else if (e.toString().contains('play_services_not_available')) {
        errorMessage =
            'Google Play Services not available. Please update Google Play Services and try again.';
      } else if (e.toString().contains('developer_error')) {
        errorMessage = 'Configuration error. Please contact support.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Network connectivity issue. Please check your internet connection and try again.';
      }

      return Left(AuthenticationFailure(errorMessage));
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      // Swallow error, as sign out should not throw
    }
  }
}

/// Data extracted from Google authentication
class GoogleUserData {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isNewUser;

  GoogleUserData({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isNewUser,
  });

  @override
  String toString() {
    return 'GoogleUserData(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, isNewUser: $isNewUser)';
  }
}

/// Result of Google authentication process
class GoogleAuthResult {
  final User user;
  final GoogleUserData googleData;
  final bool isNewUser;

  GoogleAuthResult({
    required this.user,
    required this.googleData,
    required this.isNewUser,
  });

  @override
  String toString() {
    return 'GoogleAuthResult(user: ${user.uid}, isNewUser: $isNewUser, googleData: $googleData)';
  }
}
