import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

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
  final Tuple2<Project, List<UserProfile>> projectWithUserProfiles;
  ManageCollaboratorsLoaded(this.projectWithUserProfiles);

  @override
  List<Object?> get props => [projectWithUserProfiles];
}

class ManageCollaboratorsError extends ManageCollaboratorsState {
  final String message;
  ManageCollaboratorsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddCollaboratorSuccess extends ManageCollaboratorsState {
  final String collaboratorId;

  AddCollaboratorSuccess(this.collaboratorId);

  @override
  List<Object?> get props => [collaboratorId];
}

class UpdateCollaboratorRoleSuccess extends ManageCollaboratorsState {
  final String collaboratorId;
  final String newRole;

  UpdateCollaboratorRoleSuccess(this.collaboratorId, this.newRole);

  @override
  List<Object?> get props => [collaboratorId, newRole];
}

class RemoveCollaboratorSuccess extends ManageCollaboratorsState {
  final String collaboratorId;

  RemoveCollaboratorSuccess(this.collaboratorId);

  @override
  List<Object?> get props => [collaboratorId];
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
