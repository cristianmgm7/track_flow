import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_creative_role.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final List<UserProfile> collaborators;
  final Map<UserId, UserRole> roles;
  final Map<UserId, UserCreativeRole> members;

  ProjectDetailsLoaded({
    required this.collaborators,
    required this.roles,
    required this.members,
  });
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
