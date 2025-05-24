import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

Either<Failure, String> validateEmail(String input) {
  // Simple email regex
  const emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  final regex = RegExp(emailRegex);
  if (regex.hasMatch(input)) {
    return right(input);
  } else {
    return left(const InvalidEmailFailure());
  }
}

class EmailAddress extends ValueObject<Either<Failure, String>> {
  factory EmailAddress(String input) {
    return EmailAddress._(validateEmail(input));
  }

  const EmailAddress._(super.value);
}
