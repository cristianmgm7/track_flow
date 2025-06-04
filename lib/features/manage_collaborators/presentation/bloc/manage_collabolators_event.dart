import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/load_user_profile_collaborators_usecase.dart';

abstract class ManageCollaboratorsEvent {}

class LoadCollaborators extends ManageCollaboratorsEvent {
  final ProjectWithCollaborators projectWithCollaborators;
  LoadCollaborators({required this.projectWithCollaborators});
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
