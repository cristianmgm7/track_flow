import 'package:equatable/equatable.dart';
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
  final List<UserProfile> userProfiles;
  ManageCollaboratorsLoaded(this.userProfiles);

  @override
  List<Object?> get props => [userProfiles];
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
  @override
  List<Object?> get props => [];
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
