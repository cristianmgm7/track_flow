import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectDetailsEvent {}

class LoadProjectDetails extends ProjectDetailsEvent {
  final ProjectId projectId;
  LoadProjectDetails(this.projectId);
}

class LeaveProject extends ProjectDetailsEvent {
  final ProjectId projectId;
  LeaveProject(this.projectId);
}
