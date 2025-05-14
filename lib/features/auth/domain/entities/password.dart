import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

class Password extends ValueObject<Either<Failure, String>> {
  static const _minLength = 6;

  factory Password(String input) {
    if (input.length >= _minLength) {
      return Password._(right(input));
    } else {
      return Password._(left(InvalidPasswordFailure()));
    }
  }

  const Password._(super.value);
}
