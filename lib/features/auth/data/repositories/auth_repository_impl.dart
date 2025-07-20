import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/data/models/auth_dto.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SessionStorage _sessionStorage;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SessionStorage sessionStorage,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _sessionStorage = sessionStorage,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserId?>> getSignedInUserId() async {
    try {
      final userId = _sessionStorage.getUserId();
      if (userId == null) return Right(null);
      return Right(UserId.fromUniqueString(userId));
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get user ID from session: $e'),
      );
    }
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
        await _sessionStorage.setString('offline_email', email);
        await _sessionStorage.setBool('has_credentials', true);
        return Right(
          domain.User(id: UserId.fromUniqueString('offline'), email: email),
        );
      }

      final user = await _remote.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await _sessionStorage.saveUserId(user.uid);
      }

      if (user == null) {
        return Left(AuthenticationFailure('No user found after sign in'));
      }
      return Right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
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
        await _sessionStorage.setString('offline_email', email);
        await _sessionStorage.setBool('has_credentials', true);
        return Right(
          domain.User(id: UserId.fromUniqueString('offline'), email: email),
        );
      }

      final user = await _remote.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        await _sessionStorage.saveUserId(user.uid);
      }

      if (user == null) {
        return Left(AuthenticationFailure('No user found after sign up'));
      }
      return Right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return Left(
          AuthenticationFailure(
            'Google sign in is not available in offline mode',
          ),
        );
      }

      final user = await _remote.signInWithGoogle();
      if (user != null) {
        // ✅ SOLO gestión de sesión - responsabilidad única
        await _sessionStorage.saveUserId(user.uid);
      }

      if (user == null) {
        return Left(
          AuthenticationFailure('No user found after Google sign in'),
        );
      }
      return Right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        await _sessionStorage.setBool('has_credentials', false);
        await _sessionStorage.remove('offline_email');
        return const Right(unit);
      }

      await _remote.signOut();
      await _sessionStorage.clearUserId();
      return const Right(unit);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        final hasCredentials =
            _sessionStorage.getBool('has_credentials') ?? false;
        return Right(hasCredentials);
      }

      // Check session storage first (faster)
      final userId = _sessionStorage.getUserId();
      if (userId != null) {
        return Right(true);
      }

      // Fallback to remote check if no session data
      final user = await _remote.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }
}
