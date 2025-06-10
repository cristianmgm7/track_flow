import 'package:trackflow/core/error/failures.dart';

class ProjectException extends Failure {
  const ProjectException(super.message);

  @override
  String toString() {
    return 'ProjectException: $message';
  }
}

class ProjectNotFoundException extends ProjectException {
  const ProjectNotFoundException() : super('Project not found');
}

class ProjectPermissionException extends ProjectException {
  const ProjectPermissionException()
    : super('Insufficient permissions for project operation');

  @override
  String toString() {
    return 'ProjectPermissionException: $message';
  }
}

class ProjectValidationException extends ProjectException {
  const ProjectValidationException(super.message);
}

class UserNotCollaboratorException extends ProjectException {
  const UserNotCollaboratorException() : super('User is not a collaborator');
}

class CollaboratorNotFoundException extends ProjectException {
  const CollaboratorNotFoundException() : super('Collaborator not found');
}
