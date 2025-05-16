import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

Either<Failure, String> validateUserId(String input) {
  if (input.isEmpty) {
    return left(ValidationFailure('UserId cannot be empty'));
  }
  return right(input);
}

class UserId extends ValueObject<Either<Failure, String>> {
  factory UserId(String input) {
    return UserId._(validateUserId(input));
  }

  const UserId._(super.value);
}
