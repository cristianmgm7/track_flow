import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class AppleSignInUseCase {
  final AuthRepository _authRepository;

  AppleSignInUseCase(this._authRepository);

  Future<Either<Failure, User>> call() {
    return _authRepository.signInWithApple();
  }
}
