import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@injectable
class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated() async {
    return await _authRepository.isLoggedIn();
  }

  /// Get current authenticated user ID
  Future<Either<Failure, String?>> getCurrentUserId() async {
    final result = await _authRepository.getSignedInUserId();
    return result.fold((failure) => Left(failure), (userId) => Right(userId));
  }
}
