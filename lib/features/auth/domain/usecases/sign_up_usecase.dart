import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/error/value_failure.dart';
import '../entities/email.dart';
import '../entities/password.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

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

    // Y cuando usas el email:
    // Si quieres el valor, usas: email.value.getOrElse(() => '')
    // Si quieres el error, usas: email.value.swap().getOrElse(() => DefaultFailure())
  }
}

// getOrElse() is used to get the value from the Either object
// swap() is used to swap the value of the Either object
// getOrElse(() => const InvalidEmailFailure()) is used to get the value from the Either object
// getOrElse(() => const InvalidPasswordFailure()) is used to get the value from the Either object

// all this properties are from the ValueObject class that extends Equatable
