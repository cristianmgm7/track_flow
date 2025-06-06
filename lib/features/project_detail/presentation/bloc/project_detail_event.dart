import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailsEvent {}

class LoadUserProfiles extends ProjectDetailsEvent {
  final Project project;
  LoadUserProfiles(this.project);
}

class LeaveProject extends ProjectDetailsEvent {
  final ProjectId projectId;
  LeaveProject(this.projectId);
}
