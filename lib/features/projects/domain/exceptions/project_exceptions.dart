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

class UserNotCollaboratorException extends ProjectException {
  const UserNotCollaboratorException() : super('User is not a collaborator');
}
