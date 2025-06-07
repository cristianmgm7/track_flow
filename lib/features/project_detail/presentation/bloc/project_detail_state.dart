import 'package:trackflow/features/manage_collaborators/presentation/models/manage_colaborators_params.dart';

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final ManageCollaboratorsParams params;

  ProjectDetailsLoaded({required this.params});
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  ProjectDetailsError(this.message);
}

class ProjectLeaveSuccess extends ProjectDetailsState {}
