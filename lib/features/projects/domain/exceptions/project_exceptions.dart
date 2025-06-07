import 'package:trackflow/core/error/exception.dart';

class ProjectException extends AppException {
  ProjectException(super.message, {super.code});

  @override
  String toString() => 'ProjectException: $message';
}

class ProjectNotFoundException extends ProjectException {
  ProjectNotFoundException() : super('Project not found');
}

class ProjectPermissionException extends ProjectException {
  ProjectPermissionException()
    : super('Insufficient permissions for project operation');
}

class ProjectValidationException extends ProjectException {
  ProjectValidationException(super.message);
}
