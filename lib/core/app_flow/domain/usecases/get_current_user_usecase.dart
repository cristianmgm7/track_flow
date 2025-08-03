import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Universal use case to get current user information
/// Can return complete User entity or specific user data based on needs
@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// Get the complete User entity of the currently authenticated user
  Future<Either<Failure, User?>> call() async {
    AppLogger.info(
      'GetCurrentUserUseCase: Getting complete user entity',
      tag: 'GET_CURRENT_USER',
    );

    final result = await _authRepository.getCurrentUser();
    return result.fold(
      (failure) {
        AppLogger.error(
          'GetCurrentUserUseCase: Failed to get user: ${failure.message}',
          tag: 'GET_CURRENT_USER',
        );
        return Left(failure);
      },
      (user) {
        AppLogger.info(
          'GetCurrentUserUseCase: Successfully retrieved user: ${user?.email}',
          tag: 'GET_CURRENT_USER',
        );
        return Right(user);
      },
    );
  }

  /// Get only the user ID and email (lightweight version)
  Future<Either<Failure, ({UserId? userId, String? email})>>
  getBasicData() async {
    AppLogger.info(
      'GetCurrentUserUseCase: Getting basic user data (ID and email)',
      tag: 'GET_CURRENT_USER',
    );

    final result = await call();
    return result.fold((failure) => Left(failure), (user) {
      if (user != null) {
        AppLogger.info(
          'GetCurrentUserUseCase: Basic data retrieved - userId: ${user.id.value}, email: ${user.email}',
          tag: 'GET_CURRENT_USER',
        );
        return Right((userId: user.id, email: user.email));
      } else {
        AppLogger.warning(
          'GetCurrentUserUseCase: No user found, returning null data',
          tag: 'GET_CURRENT_USER',
        );
        return Right((userId: null, email: null));
      }
    });
  }

  /// Get only the user ID
  Future<Either<Failure, UserId?>> getUserId() async {
    AppLogger.info(
      'GetCurrentUserUseCase: Getting user ID only',
      tag: 'GET_CURRENT_USER',
    );

    final result = await call();
    return result.fold((failure) => Left(failure), (user) => Right(user?.id));
  }

  /// Get only the user email
  Future<Either<Failure, String?>> getEmail() async {
    AppLogger.info(
      'GetCurrentUserUseCase: Getting user email only',
      tag: 'GET_CURRENT_USER',
    );

    final result = await call();
    return result.fold(
      (failure) => Left(failure),
      (user) => Right(user?.email),
    );
  }
}
