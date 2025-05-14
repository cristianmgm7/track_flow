import 'create_project_usecase.dart';
import 'update_project_usecase.dart';
import 'delete_project_usecase.dart';
import 'get_user_projects_usecase.dart';
import 'get_project_by_id_usecase.dart';

class ProjectUseCases {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;
  final GetUserProjectsUseCase getUserProjects;
  final GetProjectByIdUseCase getProjectById;

  ProjectUseCases({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
    required this.getUserProjects,
    required this.getProjectById,
  });
}
