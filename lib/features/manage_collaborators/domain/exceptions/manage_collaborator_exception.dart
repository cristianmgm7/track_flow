import 'package:trackflow/core/error/failures.dart';

class ManageCollaboratorException extends Failure {
  const ManageCollaboratorException(super.message);

  @override
  String toString() {
    return 'ManageCollaboratorException: $message';
  }
}

class UserNotCollaboratorException extends ManageCollaboratorException {
  const UserNotCollaboratorException() : super('User is not a collaborator');
}
