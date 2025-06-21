import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/core/sync/project_sync_service.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/data/models/auth_dto.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;
  final NetworkInfo _networkInfo;
  final FirebaseFirestore _firestore;
  final ProjectSyncService _projectSyncService;
  final UserProfileLocalDataSource _userProfileLocalDataSource;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required SharedPreferences prefs,
    required NetworkInfo networkInfo,
    required FirebaseFirestore firestore,
    required ProjectSyncService projectSyncService,
    required UserProfileLocalDataSource userProfileLocalDataSource,
  }) : _auth = auth,
       _googleSignIn = googleSignIn,
       _prefs = prefs,
       _networkInfo = networkInfo,
       _firestore = firestore,
       _projectSyncService = projectSyncService,
       _userProfileLocalDataSource = userProfileLocalDataSource;

  Future<void> _cacheUserId(User user) async {
    final userId = user.uid;
    await SessionStorage(prefs: _prefs).saveUserId(userId);
  }

  // user
  @override
  Future<Either<Failure, String>> getSignedInUserId() async {
    final user = _auth.currentUser;
    if (user == null) return left(AuthenticationFailure('No user found'));
    return right(user.uid);
  }

  Future<void> _createOrSyncUserProfile(User user) async {
    final userRef = _firestore.collection('user_profile').doc(user.uid);

    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(userRef);

        if (!docSnapshot.exists) {
          final newProfile = UserProfile(
            id: UserId.fromUniqueString(user.uid),
            name: user.displayName ?? 'No Name',
            email: user.email ?? '',
            avatarUrl: user.photoURL ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            creativeRole: CreativeRole.other,
          );

          transaction.set(
            userRef,
            UserProfileDTO.fromDomain(newProfile).toJson(),
          );
        }
      });

      final finalDoc = await userRef.get();
      if (finalDoc.exists) {
        final data = finalDoc.data();
        if (data != null) {
          final remoteProfile = UserProfileDTO.fromJson(data);
          await _userProfileLocalDataSource.cacheUserProfile(remoteProfile);
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<domain.User?> get authState async* {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      final hasStoredCredentials = _prefs.getBool('has_credentials') ?? false;
      if (!hasStoredCredentials) {
        yield null;
        return;
      }
      final email = _prefs.getString('offline_email') ?? '';
      yield domain.User(id: 'offline', email: email);
      return;
    }
    yield* _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthDto.fromFirebase(user).toDomain();
    });
  }

  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        await _prefs.setBool('has_credentials', true);
        await _prefs.setString('offline_email', email);
        return right(domain.User(id: 'offline', email: email));
      }
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await _cacheUserId(user);
        await _createOrSyncUserProfile(user);
        _projectSyncService.start(UserId.fromUniqueString(user.uid));
      }
      if (user == null) {
        return left(AuthenticationFailure('No user found after sign in'));
      }
      return right(AuthDto.fromFirebase(user).toDomain());
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        await _prefs.setBool('has_credentials', true);
        await _prefs.setString('offline_email', email);
        return right(domain.User(id: 'offline', email: email));
      }
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await _createOrSyncUserProfile(user);
        await _cacheUserId(user);
        _projectSyncService.start(UserId.fromUniqueString(user.uid));
      }
      if (user == null) {
        return left(AuthenticationFailure('No user found after sign up'));
      }
      return right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return left(
          AuthenticationFailure(
            'Google sign in is not available in offline mode',
          ),
        );
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(AuthenticationFailure('Google sign in was cancelled'));
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;
      if (user != null) {
        await _cacheUserId(user);
        await _createOrSyncUserProfile(user);
        _projectSyncService.start(UserId.fromUniqueString(user.uid));
      }
      if (user == null) {
        return left(
          AuthenticationFailure('No user found after Google sign in'),
        );
      }
      return right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      await _prefs.setBool('has_credentials', false);
      await _prefs.remove('offline_email');
      return;
    }
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    _projectSyncService.stop();
  }

  @override
  Future<bool> isLoggedIn() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return _prefs.getBool('has_credentials') ?? false;
    }
    return _auth.currentUser != null;
  }

  // onboarding
  @override
  Future<bool> onboardingCompleted() async {
    return _prefs.setBool('onboardingCompleted', true);
  }

  @override
  Future<void> welcomeScreenSeenCompleted() async {
    await _prefs.setBool('welcomeScreenSeenCompleted', true);
  }

  @override
  Future<bool> checkWelcomeScreenSeen() async {
    return _prefs.getBool('welcomeScreenSeenCompleted') ?? false;
  }

  @override
  Future<bool> checkOnboardingCompleted() async {
    return _prefs.getBool('onboardingCompleted') ?? false;
  }
}
