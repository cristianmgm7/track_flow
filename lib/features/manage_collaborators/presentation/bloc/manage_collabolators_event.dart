import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';

abstract class ManageCollaboratorsEvent extends Equatable {}

class AddCollaborator extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final UserId collaboratorId;
  final UserRole role;
  AddCollaborator({
    required this.projectId,
    required this.collaboratorId,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, collaboratorId, role];
}

class UpdateCollaboratorRole extends ManageCollaboratorsEvent {
  final UserId userId;
  final UserRole newRole;
  UpdateCollaboratorRole({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}

class RemoveCollaborator extends ManageCollaboratorsEvent {
  final UserId userId;
  RemoveCollaborator(this.userId);

  @override
  List<Object?> get props => [userId];
}

class JoinProjectWithIdRequested extends ManageCollaboratorsEvent {
  final UniqueId projectId;
  JoinProjectWithIdRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
