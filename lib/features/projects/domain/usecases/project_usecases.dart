import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_use_case.dart';
import 'package:trackflow/features/projects/domain/usecases/getting_all-projects_use_case.dart';

import 'create_project_usecase.dart';
import 'update_project_usecase.dart';
import 'delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class ProjectUseCases {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;
  final ProjectsRepository repository;
  final GetProjectByIdUseCase getProjectById;
  final GetAllProjectsUseCase getAllProjects;

  ProjectUseCases({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
    required this.repository,
    required this.getProjectById,
    required this.getAllProjects,
  });
}
