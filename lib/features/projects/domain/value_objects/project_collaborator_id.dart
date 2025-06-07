import 'package:trackflow/core/entities/value_object.dart';
import 'package:uuid/uuid.dart';

class ProjectCollaboratorId extends ValueObject<String> {
  factory ProjectCollaboratorId() => ProjectCollaboratorId._(const Uuid().v4());

  const ProjectCollaboratorId._(super.value);
}
