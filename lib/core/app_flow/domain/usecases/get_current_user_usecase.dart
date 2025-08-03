import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Universal use case to get current user information
/// Can return complete User entity or specific user data based on needs
@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// Get the complete User entity of the currently authenticated user
  Future<Either<Failure, User?>> call() async {
    return await _authRepository.getCurrentUser();
  }

  /// Get user data including Google information for profile creation
  Future<
    Either<
      Failure,
      ({UserId? userId, String? email, String? displayName, String? photoUrl})
    >
  >
  getProfileCreationData() async {
    final result = await call();
    return result.fold((failure) => Left(failure), (user) {
      if (user != null) {
        return Right((
          userId: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        ));
      } else {
        return Right((
          userId: null,
          email: null,
          displayName: null,
          photoUrl: null,
        ));
      }
    });
  }

  /// Get only the user ID
  Future<Either<Failure, UserId?>> getUserId() async {
    final result = await call();
    return result.fold((failure) => Left(failure), (user) => Right(user?.id));
  }

  /// Get only the user email
  Future<Either<Failure, String?>> getEmail() async {
    final result = await call();
    return result.fold(
      (failure) => Left(failure),
      (user) => Right(user?.email),
    );
  }
}
