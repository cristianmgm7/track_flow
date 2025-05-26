import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/email.dart';
import '../entities/password.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  // call is a method that allow use the usecase as a function
  Future<Either<Failure, User>> call(
    EmailAddress email,
    PasswordValue password,
  ) async {
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

    // getOrElse() is used to get the value from the Either object
    return repository.signUpWithEmailAndPassword(
      email.value.getOrElse(() => ''),
      password.value.getOrElse(() => ''),
    );
  }
}
