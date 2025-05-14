import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

class Email extends ValueObject<Either<Failure, String>> {
  static final _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  factory Email(String input) {
    if (_emailRegex.hasMatch(input)) {
      return Email._(right(input));
    } else {
      return Email._(left(const InvalidEmailFailure()));
    }
  }

  const Email._(super.value);
}
