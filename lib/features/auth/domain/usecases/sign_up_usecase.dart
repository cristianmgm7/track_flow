import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/email.dart';
import '../entities/password.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call(Email email, Password password) async {
    if (email.value.isLeft()) {
      return left(
        email.value.swap().getOrElse(() => const InvalidEmailFailure()),
      );
    }
    if (password.value.isLeft()) {
      return left(
        password.value.swap().getOrElse(() => const InvalidPasswordFailure()),
      );
    }
    return repository.signUpWithEmailAndPassword(
      email.value.getOrElse(() => ''),
      password.value.getOrElse(() => ''),
    );
  }
}
