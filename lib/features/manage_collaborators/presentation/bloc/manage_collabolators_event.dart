import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ManageCollaboratorsEvent {}

class LoadCollaborators extends ManageCollaboratorsEvent {
  final Project project;
  LoadCollaborators({required this.project});
}

class AddCollaborator extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final UserId collaboratorId;
  final UserRole role;
  AddCollaborator({
    required this.projectId,
    required this.collaboratorId,
    required this.role,
  });
}

class UpdateCollaboratorRole extends ManageCollaboratorsEvent {
  final UserId userId;
  final UserRole newRole;
  UpdateCollaboratorRole({required this.userId, required this.newRole});

  get projectId => null;
}

class RemoveCollaborator extends ManageCollaboratorsEvent {
  final UserId userId;
  RemoveCollaborator(this.userId);
}

class JoinProjectWithIdRequested extends ManageCollaboratorsEvent {
  final UniqueId projectId;
  JoinProjectWithIdRequested(this.projectId);
}
