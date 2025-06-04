import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final Project project;
  final UserRole currentUserRole;
  final List<UserProfile> participants;

  ProjectDetailsLoaded({
    required this.project,
    required this.currentUserRole,
    required this.participants,
  });
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
