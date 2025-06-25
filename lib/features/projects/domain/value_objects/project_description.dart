import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/value_failure.dart';

class ProjectDescription
    extends ValueObject<Either<ValueFailure<String>, String>> {
  static const maxLength = 500;

  factory ProjectDescription(String input) {
    if (input.length > maxLength) {
      return ProjectDescription._(left(ExceedingLength(input, maxLength)));
    } else {
      return ProjectDescription._(right(input));
    }
  }

  const ProjectDescription._(super.value);

  factory ProjectDescription.empty() {
    return ProjectDescription._(right(''));
  }
}
