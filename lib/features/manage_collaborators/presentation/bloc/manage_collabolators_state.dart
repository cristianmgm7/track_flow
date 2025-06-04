import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsState {}

class ManageCollaboratorsInitial extends ManageCollaboratorsState {}

class ManageCollaboratorsLoading extends ManageCollaboratorsState {}

class ManageCollaboratorsLoaded extends ManageCollaboratorsState {
  final List<UserProfile> collaborators;
  final Map<UserId, UserRole> roles;

  ManageCollaboratorsLoaded({required this.collaborators, required this.roles});
}

class ManageCollaboratorsError extends ManageCollaboratorsState {
  final String message;
  ManageCollaboratorsError(this.message);
}

class CollaboratorActionSuccess extends ManageCollaboratorsState {}
