import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailsEvent {}

class LoadProjectDetails extends ProjectDetailsEvent {
  final Project project;
  LoadProjectDetails(this.project);
}

class LeaveProject extends ProjectDetailsEvent {
  final ProjectId projectId;
  LeaveProject(this.projectId);
}
