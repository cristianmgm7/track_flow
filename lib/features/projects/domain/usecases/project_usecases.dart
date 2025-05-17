import 'create_project_usecase.dart';
import 'update_project_usecase.dart';
import 'delete_project_usecase.dart';

class ProjectUseCases {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;

  ProjectUseCases({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
  });
}
