import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/value_failure.dart';

class ProjectName {
  static const maxLength = 50;

  final Either<ValueFailure<String>, String> value;

  factory ProjectName(String input) {
    if (input.isEmpty) {
      return ProjectName._(left(ValueFailure.emptyField(failedValue: input)));
    } else if (input.length > maxLength) {
      return ProjectName._(left(ExceedingLength(input, maxLength)));
    } else {
      return ProjectName._(right(input));
    }
  }

  const ProjectName._(this.value);

  @override
  String toString() {
    return value.fold((l) => l.toString(), (r) => r);
  }
}
