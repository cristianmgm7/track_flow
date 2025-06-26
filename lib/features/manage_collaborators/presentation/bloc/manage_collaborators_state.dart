import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ManageCollaboratorsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManageCollaboratorsInitial extends ManageCollaboratorsState {}

class ManageCollaboratorsLoading extends ManageCollaboratorsState {
  @override
  List<Object?> get props => [];
}

class ManageCollaboratorsLoaded extends ManageCollaboratorsState {
  final Project project;
  final List<UserProfile> userProfiles;
  ManageCollaboratorsLoaded(this.project, this.userProfiles);

  @override
  List<Object?> get props => [project, userProfiles];
}

class ManageCollaboratorsError extends ManageCollaboratorsState {
  final String message;
  ManageCollaboratorsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddCollaboratorSuccess extends ManageCollaboratorsState {
  final Project project;

  AddCollaboratorSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class UpdateCollaboratorRoleSuccess extends ManageCollaboratorsState {
  final Project project;
  final String newRole;

  UpdateCollaboratorRoleSuccess(this.project, this.newRole);

  @override
  List<Object?> get props => [project, newRole];
}

class RemoveCollaboratorSuccess extends ManageCollaboratorsState {
  final Project project;

  RemoveCollaboratorSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class JoinProjectSuccess extends ManageCollaboratorsState {
  final Project project;
  JoinProjectSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class JoinProjectFailure extends ManageCollaboratorsState {
  final String error;

  JoinProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ManageCollaboratorsLeaveSuccess extends ManageCollaboratorsState {
  @override
  List<Object?> get props => [];
}
