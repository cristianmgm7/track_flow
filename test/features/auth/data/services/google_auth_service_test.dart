import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trackflow/features/auth/data/services/google_auth_service.dart';
import 'package:trackflow/core/error/failures.dart';

import 'google_auth_service_test.mocks.dart';

@GenerateMocks([
  GoogleSignIn,
  FirebaseAuth,
  User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  AdditionalUserInfo,
])
void main() {
  group('GoogleAuthService', () {
    late GoogleAuthService googleAuthService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignInAccount mockGoogleAccount;
    late MockGoogleSignInAuthentication mockGoogleAuth;
    late MockUser mockFirebaseUser;
    late MockUserCredential mockUserCredential;
    late MockAdditionalUserInfo mockAdditionalUserInfo;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleAccount = MockGoogleSignInAccount();
      mockGoogleAuth = MockGoogleSignInAuthentication();
      mockFirebaseUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockAdditionalUserInfo = MockAdditionalUserInfo();

      googleAuthService = GoogleAuthService(mockGoogleSignIn, mockFirebaseAuth);
    });

    group('authenticateWithGoogle', () {
      test(
        'should return GoogleAuthResult when authentication is successful for new user',
        () async {
          // Arrange
          const email = 'test@example.com';
          const displayName = 'Test User';
          const photoUrl = 'https://example.com/photo.jpg';
          const uid = 'user123';

          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleAccount);
          when(
            mockGoogleAccount.authentication,
          ).thenAnswer((_) async => mockGoogleAuth);
          when(mockGoogleAccount.email).thenReturn(email);
          when(mockGoogleAccount.displayName).thenReturn(displayName);
          when(mockGoogleAccount.photoUrl).thenReturn(photoUrl);
          when(mockGoogleAuth.accessToken).thenReturn('access_token');
          when(mockGoogleAuth.idToken).thenReturn('id_token');

          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockUserCredential.user).thenReturn(mockFirebaseUser);
          when(
            mockUserCredential.additionalUserInfo,
          ).thenReturn(mockAdditionalUserInfo);
          when(mockAdditionalUserInfo.isNewUser).thenReturn(true);

          when(mockFirebaseUser.uid).thenReturn(uid);
          when(mockFirebaseUser.email).thenReturn(email);
          when(mockFirebaseUser.displayName).thenReturn(displayName);
          when(mockFirebaseUser.photoURL).thenReturn(photoUrl);

          // Act
          final result = await googleAuthService.authenticateWithGoogle();

          // Assert
          expect(result.isRight(), true);
          result.fold((failure) => fail('Should not return failure'), (
            authResult,
          ) {
            expect(authResult.isNewUser, true);
            expect(authResult.googleData.email, email);
            expect(authResult.googleData.displayName, displayName);
            expect(authResult.googleData.photoUrl, photoUrl);
            expect(authResult.user.uid, uid);
          });

          verify(mockGoogleSignIn.signIn()).called(1);
          verify(mockGoogleAccount.authentication).called(1);
          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        },
      );

      test(
        'should return GoogleAuthResult when authentication is successful for existing user',
        () async {
          // Arrange
          const email = 'existing@example.com';
          const displayName = 'Existing User';
          const photoUrl = 'https://example.com/existing.jpg';
          const uid = 'existing123';

          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleAccount);
          when(
            mockGoogleAccount.authentication,
          ).thenAnswer((_) async => mockGoogleAuth);
          when(mockGoogleAccount.email).thenReturn(email);
          when(mockGoogleAccount.displayName).thenReturn(displayName);
          when(mockGoogleAccount.photoUrl).thenReturn(photoUrl);
          when(mockGoogleAuth.accessToken).thenReturn('access_token');
          when(mockGoogleAuth.idToken).thenReturn('id_token');

          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockUserCredential.user).thenReturn(mockFirebaseUser);
          when(
            mockUserCredential.additionalUserInfo,
          ).thenReturn(mockAdditionalUserInfo);
          when(mockAdditionalUserInfo.isNewUser).thenReturn(false);

          when(mockFirebaseUser.uid).thenReturn(uid);
          when(mockFirebaseUser.email).thenReturn(email);
          when(mockFirebaseUser.displayName).thenReturn(displayName);
          when(mockFirebaseUser.photoURL).thenReturn(photoUrl);

          // Act
          final result = await googleAuthService.authenticateWithGoogle();

          // Assert
          expect(result.isRight(), true);
          result.fold((failure) => fail('Should not return failure'), (
            authResult,
          ) {
            expect(authResult.isNewUser, false);
            expect(authResult.googleData.email, email);
            expect(authResult.googleData.displayName, displayName);
            expect(authResult.googleData.photoUrl, photoUrl);
            expect(authResult.user.uid, uid);
          });
        },
      );

      test(
        'should return AuthenticationFailure when Google sign in is cancelled',
        () async {
          // Arrange
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          // Act
          final result = await googleAuthService.authenticateWithGoogle();

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthenticationFailure>());
            expect(failure.message, 'Google sign in cancelled');
          }, (authResult) => fail('Should not return success'));

          verify(mockGoogleSignIn.signIn()).called(1);
          verifyNever(mockGoogleAccount.authentication);
          verifyNever(mockFirebaseAuth.signInWithCredential(any));
        },
      );

      test(
        'should return AuthenticationFailure when Firebase user is null',
        () async {
          // Arrange
          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleAccount);
          when(
            mockGoogleAccount.authentication,
          ).thenAnswer((_) async => mockGoogleAuth);
          when(mockGoogleAuth.accessToken).thenReturn('access_token');
          when(mockGoogleAuth.idToken).thenReturn('id_token');

          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockUserCredential.user).thenReturn(null);

          // Act
          final result = await googleAuthService.authenticateWithGoogle();

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthenticationFailure>());
            expect(failure.message, 'No user found after Google sign in');
          }, (authResult) => fail('Should not return success'));
        },
      );

      test(
        'should return AuthenticationFailure when exception occurs',
        () async {
          // Arrange
          when(mockGoogleSignIn.signIn()).thenThrow(Exception('Network error'));

          // Act
          final result = await googleAuthService.authenticateWithGoogle();

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthenticationFailure>());
            expect(failure.message, contains('Google authentication failed'));
          }, (authResult) => fail('Should not return success'));
        },
      );
    });

    group('signOut', () {
      test('should sign out from both Google and Firebase', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {
          return null;
        });
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async {
          return null;
        });

        // Act
        await googleAuthService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockGoogleSignIn.signOut()).called(1);
      });
    });
  });
}
