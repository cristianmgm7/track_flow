import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsEvent {}

class LoadCollaborators extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final List<UserProfile> collaborators;
  LoadCollaborators({required this.projectId, required this.collaborators});
}

class AddCollaborator extends ManageCollaboratorsEvent {
  final UserId collaboratorId;
  final UserRole role;
  AddCollaborator({required this.collaboratorId, required this.role});
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
