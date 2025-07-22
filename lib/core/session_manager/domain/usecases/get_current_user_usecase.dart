import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// Get the complete User entity of the currently authenticated user
  Future<Either<Failure, User?>> call() async {
    final result = await _authRepository.getCurrentUser();
    return result.fold(
      (failure) => Left(failure),
      (user) => Right(user),
    );
  }
}