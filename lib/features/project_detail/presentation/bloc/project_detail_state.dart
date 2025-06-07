import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final List<UserProfile> collaborators;
  final Project project;

  ProjectDetailsLoaded({required this.collaborators, required this.project});
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
