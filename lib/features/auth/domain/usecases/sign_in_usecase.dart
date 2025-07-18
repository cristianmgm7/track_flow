import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/email.dart';
import '../entities/password.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<Either<Failure, User>> call(
    EmailAddress email,
    PasswordValue password,
  ) async {
    // Validate value objects
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
    // Call repository
    return repository.signInWithEmailAndPassword(
      email.value.getOrElse(() => ''),
      password.value.getOrElse(() => ''),
    );
  }
}
