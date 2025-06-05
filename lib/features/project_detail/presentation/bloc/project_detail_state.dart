import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final Project project;

  ProjectDetailsLoaded({required this.project});
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
