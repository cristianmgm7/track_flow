import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';

abstract class ManageCollaboratorsEvent {}

class LoadCollaborators extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  LoadCollaborators(this.projectId);
}

class AddCollaborator extends ManageCollaboratorsEvent {
  final String email;
  final UserRole role;
  AddCollaborator({required this.email, required this.role});
}

class UpdateCollaboratorRole extends ManageCollaboratorsEvent {
  final UserId userId;
  final UserRole newRole;
  UpdateCollaboratorRole({required this.userId, required this.newRole});
}

class RemoveCollaborator extends ManageCollaboratorsEvent {
  final UserId userId;
  RemoveCollaborator(this.userId);
}
