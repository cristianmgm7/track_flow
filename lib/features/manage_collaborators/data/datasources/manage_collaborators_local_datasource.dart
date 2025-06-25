import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

abstract class ManageCollaboratorsLocalDataSource {
  Future<void> updateProject(Project project);
  Future<Project?> getProjectById(ProjectId projectId);
}

@LazySingleton(as: ManageCollaboratorsLocalDataSource)
class ManageCollaboratorsLocalDataSourceImpl
    implements ManageCollaboratorsLocalDataSource {
  final ProjectsLocalDataSource _projectsLocalDataSource;

  ManageCollaboratorsLocalDataSourceImpl(this._projectsLocalDataSource);

  @override
  Future<Project> updateProject(Project project) async {
    final dto = ProjectDTO.fromDomain(project);
    await _projectsLocalDataSource.cacheProject(dto);
    return project;
  }

  @override
  Future<Project?> getProjectById(ProjectId projectId) async {
    final dto = await _projectsLocalDataSource.getCachedProject(projectId);
    return dto?.toDomain();
  }
}
