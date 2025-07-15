import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

abstract class ManageCollaboratorsLocalDataSource {
  Future<ProjectDTO> updateProject(ProjectDTO project);
  Future<ProjectDTO?> getProjectById(String projectId);
}

@LazySingleton(as: ManageCollaboratorsLocalDataSource)
class ManageCollaboratorsLocalDataSourceImpl
    implements ManageCollaboratorsLocalDataSource {
  final ProjectsLocalDataSource _projectsLocalDataSource;

  ManageCollaboratorsLocalDataSourceImpl(this._projectsLocalDataSource);

  @override
  Future<ProjectDTO> updateProject(ProjectDTO project) async {
    await _projectsLocalDataSource.cacheProject(project);
    return project;
  }

  @override
  Future<ProjectDTO?> getProjectById(String projectId) async {
    final result = await _projectsLocalDataSource.getCachedProject(projectId);
    return result.fold(
      (failure) => null, // Return null on failure
      (dto) => dto, // Return DTO directly
    );
  }
}
