import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/data/models/auth_dto.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/auth/data/data_sources/user_session_local_datasource.dart';
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/core/session/session_storage.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final UserSessionLocalDataSource _userSessionLocalDataSource;
  final NetworkInfo _networkInfo;
  final FirebaseFirestore _firestore;
  final UserProfileLocalDataSource _userProfileLocalDataSource;
  final ProjectsLocalDataSource _projectLocalDataSource;
  final AudioTrackLocalDataSource _audioTrackLocalDataSource;
  final AudioCommentLocalDataSource _audioCommentLocalDataSource;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required UserSessionLocalDataSource userSessionLocalDataSource,
    required NetworkInfo networkInfo,
    required FirebaseFirestore firestore,
    required UserProfileLocalDataSource userProfileLocalDataSource,
    required ProjectsLocalDataSource projectLocalDataSource,
    required AudioTrackLocalDataSource audioTrackLocalDataSource,
    required AudioCommentLocalDataSource audioCommentLocalDataSource,
    required SessionStorage sessionStorage,
  }) : _remote = remote,
       _userSessionLocalDataSource = userSessionLocalDataSource,
       _networkInfo = networkInfo,
       _firestore = firestore,
       _userProfileLocalDataSource = userProfileLocalDataSource,
       _projectLocalDataSource = projectLocalDataSource,
       _audioTrackLocalDataSource = audioTrackLocalDataSource,
       _audioCommentLocalDataSource = audioCommentLocalDataSource,
       _sessionStorage = sessionStorage;

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
  Future<Either<Failure, String>> getSignedInUserId() async {
    final user = await _remote.getCurrentUser();
    if (user == null) return left(AuthenticationFailure('No user found'));
    return right(user.uid);
  }

  @override
  Stream<domain.User?> get authState {
    return _remote.authStateChanges().map((user) {
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
        final result = await _userSessionLocalDataSource.setOfflineCredentials(email, true);
        result.fold((failure) => throw Exception(failure.message), (_) {});
        return right(domain.User(id: UserId.fromUniqueString('offline'), email: email));
      }
      final user = await _remote.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await _sessionStorage.saveUserId(user.uid);
        final cacheResult = await _userSessionLocalDataSource.cacheUserId(UserId.fromUniqueString(user.uid));
        cacheResult.fold((failure) => throw Exception(failure.message), (_) {});
        await _createOrSyncUserProfile(user);
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
        final result = await _userSessionLocalDataSource.setOfflineCredentials(email, true);
        result.fold((failure) => throw Exception(failure.message), (_) {});
        return right(domain.User(id: UserId.fromUniqueString('offline'), email: email));
      }
      final user = await _remote.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        await _sessionStorage.saveUserId(user.uid);
        await _createOrSyncUserProfile(user);
        final cacheResult = await _userSessionLocalDataSource.cacheUserId(UserId.fromUniqueString(user.uid));
        cacheResult.fold((failure) => throw Exception(failure.message), (_) {});
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
      final user = await _remote.signInWithGoogle();
      if (user != null) {
        await _sessionStorage.saveUserId(user.uid);
        final cacheResult = await _userSessionLocalDataSource.cacheUserId(UserId.fromUniqueString(user.uid));
        cacheResult.fold((failure) => throw Exception(failure.message), (_) {});
        await _createOrSyncUserProfile(user);
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
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        final clearResult = await _userSessionLocalDataSource.clearOfflineCredentials();
        clearResult.fold((failure) => throw Exception(failure.message), (_) {});
        await _sessionStorage.clearUserId();
        return right(unit);
      }
      await _remote.signOut();
      await _userProfileLocalDataSource.clearCache();
      await _projectLocalDataSource.clearCache();
      await _audioTrackLocalDataSource.clearCache();
      await _audioCommentLocalDataSource.clearCache();
      await _sessionStorage.clearUserId();
      return right(unit);
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        final hasCredentialsResult = await _userSessionLocalDataSource.hasOfflineCredentials();
        return hasCredentialsResult.fold(
          (failure) => left(failure),
          (hasCredentials) => right(hasCredentials),
        );
      }
      final user = await _remote.getCurrentUser();
      return right(user != null);
    } catch (e) {
      return left(AuthenticationFailure(e.toString()));
    }
  }

}
