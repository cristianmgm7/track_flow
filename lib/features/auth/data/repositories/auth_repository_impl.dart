import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/data/models/auth_dto.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart';
import 'package:trackflow/features/auth/data/services/google_auth_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SessionStorage _sessionStorage;
  final NetworkStateManager _networkStateManager;
  final GoogleAuthService _googleAuthService; // ✅ NUEVO

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SessionStorage sessionStorage,
    required NetworkStateManager networkStateManager,
    required GoogleAuthService googleAuthService, // ✅ NUEVO
  }) : _remote = remote,
       _sessionStorage = sessionStorage,
       _networkStateManager = networkStateManager,
       _googleAuthService = googleAuthService;

  @override
  Future<Either<Failure, UserId?>> getSignedInUserId() async {
    try {
      final userId = await _sessionStorage.getUserId();
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
      if (user == null) {
        return null;
      }
      final domainUser = AuthDto.fromFirebase(user).toDomain();
      return domainUser;
    });
  }

  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final isConnected = await _networkStateManager.isConnected;
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
      final isConnected = await _networkStateManager.isConnected;
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
      return Right(AuthDto.fromFirebase(user, isNewUser: true).toDomain());
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Left(
          AuthenticationFailure(
            'Google sign in is not available in offline mode',
          ),
        );
      }

      // ✅ NUEVO: Usar GoogleAuthService para obtener datos completos
      final authResult = await _googleAuthService.authenticateWithGoogle();

      return authResult.fold((failure) => Left(failure), (result) async {
        // Guardar sesión
        await _sessionStorage.saveUserId(result.user.uid);

        // ✅ NUEVO: Si es usuario nuevo, guardar datos de Google para onboarding
        if (result.isNewUser) {
          AppLogger.info(
            'New Google user detected: ${result.googleData.email}',
            tag: 'AUTH_REPOSITORY',
          );

          await _sessionStorage.setString(
            'google_display_name',
            result.googleData.displayName ?? '',
          );
          await _sessionStorage.setString(
            'google_photo_url',
            result.googleData.photoUrl ?? '',
          );
          await _sessionStorage.setBool('is_new_google_user', true);

          AppLogger.info(
            'Google data saved for onboarding: displayName=${result.googleData.displayName}, photoUrl=${result.googleData.photoUrl}',
            tag: 'AUTH_REPOSITORY',
          );
        } else {
          AppLogger.info(
            'Existing Google user signed in: ${result.googleData.email}',
            tag: 'AUTH_REPOSITORY',
          );
        }

        return Right(
          AuthDto.fromFirebase(
            result.user,
            isNewUser: result.isNewUser,
          ).toDomain(),
        );
      });
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        await _sessionStorage.setBool('has_credentials', false);
        await _sessionStorage.remove('offline_email');
        return const Right(unit);
      }

      await _remote.signOut();
      await _sessionStorage.clearUserId();

      // ✅ NUEVO: Limpiar datos de Google
      await _sessionStorage.remove('google_display_name');
      await _sessionStorage.remove('google_photo_url');
      await _sessionStorage.setBool('is_new_google_user', false);

      return const Right(unit);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        final hasCredentials =
            await _sessionStorage.getBool('has_credentials') ?? false;
        return Right(hasCredentials);
      }

      // Check session storage first (faster)
      final userId = await _sessionStorage.getUserId();
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

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        // In offline mode, try to get user from session storage
        final userId = await _sessionStorage.getUserId();
        final offlineEmail = await _sessionStorage.getString('offline_email');
        if (userId != null && offlineEmail != null) {
          return Right(
            domain.User(
              id: UserId.fromUniqueString(userId),
              email: offlineEmail,
            ),
          );
        }
        return Right(null);
      }

      // Get user from remote
      final user = await _remote.getCurrentUser();
      if (user == null) {
        return Right(null);
      }

      return Right(AuthDto.fromFirebase(user).toDomain());
    } catch (e) {
      return Left(AuthenticationFailure('Failed to get current user: $e'));
    }
  }
}
