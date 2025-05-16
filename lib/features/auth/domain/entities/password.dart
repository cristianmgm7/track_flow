import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

Either<Failure, String> validatePassword(String input) {
  const minLength = 6;
  if (input.length >= minLength) {
    return right(input);
  } else {
    return left(const InvalidPasswordFailure());
  }
}

class PasswordValue extends ValueObject<Either<Failure, String>> {
  factory PasswordValue(String input) {
    return PasswordValue._(validatePassword(input));
  }

  const PasswordValue._(super.value);
}
