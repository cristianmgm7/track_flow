import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';

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
  final ProjectUiModel project;
  final List<UserProfileUiModel> userProfiles;
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

class UpdateCollaboratorRoleSuccess extends ManageCollaboratorsState {
  final ProjectUiModel project;
  final String newRole;

  UpdateCollaboratorRoleSuccess(this.project, this.newRole);

  @override
  List<Object?> get props => [project, newRole];
}

class RemoveCollaboratorSuccess extends ManageCollaboratorsState {
  final ProjectUiModel project;

  RemoveCollaboratorSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class JoinProjectSuccess extends ManageCollaboratorsState {
  final ProjectUiModel project;
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

// User search states for adding collaborators
class UserSearchLoading extends ManageCollaboratorsState {
  @override
  List<Object?> get props => [];
}

class UserSearchSuccess extends ManageCollaboratorsState {
  final UserProfileUiModel? user; // null = new user (not found)

  UserSearchSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserSearchError extends ManageCollaboratorsState {
  final String message;

  UserSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddCollaboratorByEmailSuccess extends ManageCollaboratorsState {
  final ProjectUiModel project;
  final String message;

  AddCollaboratorByEmailSuccess(this.project, this.message);

  @override
  List<Object?> get props => [project, message];
}
