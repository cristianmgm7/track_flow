import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/failures.dart';

class ProjectStatus extends ValueObject<Either<Failure, String>> {
  static const String draft = 'draft';
  static const String inProgress = 'in_progress';
  static const String finished = 'finished';

  static const List<String> validStatuses = [draft, inProgress, finished];

  factory ProjectStatus(String input) {
    if (validStatuses.contains(input)) {
      return ProjectStatus._(right(input));
    } else {
      return ProjectStatus._(left(InvalidProjectStatusFailure(input)));
    }
  }

  const ProjectStatus._(super.value);
}

class InvalidProjectStatusFailure extends Failure {
  final String invalidStatus;
  const InvalidProjectStatusFailure(this.invalidStatus)
    : super('Invalid project status: $invalidStatus');
}
