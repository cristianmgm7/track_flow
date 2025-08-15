import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';

@lazySingleton
class AppleAuthService {
  final FirebaseAuth _firebaseAuth;

  AppleAuthService(this._firebaseAuth);

  Future<Either<Failure, User>> authenticateWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauth = OAuthProvider(
        'apple.com',
      ).credential(idToken: credential.identityToken, rawNonce: rawNonce);

      final userCred = await _firebaseAuth.signInWithCredential(oauth);
      if (userCred.user == null) {
        return Left(AuthenticationFailure('No user after Apple sign in'));
      }
      return Right(userCred.user!);
    } catch (e) {
      String errorMessage = 'Apple authentication failed: ${e.toString()}';
      return Left(AuthenticationFailure(errorMessage));
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
