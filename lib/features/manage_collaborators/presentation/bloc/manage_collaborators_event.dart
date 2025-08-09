import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

abstract class ManageCollaboratorsEvent extends Equatable {}

class WatchCollaborators extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  WatchCollaborators({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class AddCollaboratorByEmail extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final String email;
  final ProjectRole role;

  AddCollaboratorByEmail({
    required this.projectId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, email, role];
}

class UpdateCollaboratorRole extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final UserId userId;
  final ProjectRole newRole;
  UpdateCollaboratorRole({
    required this.projectId,
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [projectId, userId, newRole];
}

class RemoveCollaborator extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  final UserId userId;
  RemoveCollaborator({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

class JoinProjectWithIdRequested extends ManageCollaboratorsEvent {
  final UniqueId projectId;
  JoinProjectWithIdRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class LoadUserProfiles extends ManageCollaboratorsEvent {
  final Project project;
  LoadUserProfiles(this.project);

  @override
  List<Object?> get props => [project];
}

class LeaveProject extends ManageCollaboratorsEvent {
  final ProjectId projectId;
  LeaveProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// User search events for adding collaborators
class SearchUserByEmail extends ManageCollaboratorsEvent {
  final String email;

  SearchUserByEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class ClearUserSearch extends ManageCollaboratorsEvent {
  ClearUserSearch();

  @override
  List<Object?> get props => [];
}

// Internal event to update state from the collaborators bundle stream
class CollaboratorsBundleUpdated extends ManageCollaboratorsEvent {
  final Either<Failure, CollaboratorsBundle> result;

  CollaboratorsBundleUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
