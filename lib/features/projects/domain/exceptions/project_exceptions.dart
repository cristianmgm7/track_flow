import 'package:trackflow/core/error/failures.dart';

class ProjectException extends Failure {
  const ProjectException(super.message);
}

class ProjectNotFoundException extends ProjectException {
  const ProjectNotFoundException() : super('Project not found');
}

class ProjectPermissionException extends ProjectException {
  const ProjectPermissionException()
    : super('Insufficient permissions for project operation');
}

class ProjectValidationException extends ProjectException {
  const ProjectValidationException(super.message);
}
