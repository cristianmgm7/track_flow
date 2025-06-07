import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final List<UserProfile> collaborators;

  ProjectDetailsLoaded({required this.collaborators});
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
