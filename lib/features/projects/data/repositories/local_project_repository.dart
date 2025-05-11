import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// Implementation of [ProjectRepository] using local storage (Hive) as the data source.
class LocalProjectRepository implements ProjectRepository {
  final ProjectLocalDataSource _localDataSource;

  LocalProjectRepository({ProjectLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? HiveProjectLocalDataSource();

  @override
  Future<Project> createProject(Project project) async {
    final dto = ProjectDTO.fromEntity(project);
    await _localDataSource.cacheProject(dto);
    return project;
  }

  @override
  Future<void> updateProject(Project project) async {
    final dto = ProjectDTO.fromEntity(project);
    await _localDataSource.cacheProject(dto);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _localDataSource.removeCachedProject(projectId);
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final dto = await _localDataSource.getCachedProject(projectId);
    return dto?.toEntity();
  }

  @override
  Stream<List<Project>> getUserProjects(String userId) async* {
    final projects = await _localDataSource.getCachedProjects(userId);
    yield projects.map((dto) => dto.toEntity()).toList();
  }

  @override
  Stream<List<Project>> getUserProjectsByStatus(
    String userId,
    String status,
  ) async* {
    final projects = await _localDataSource.getCachedProjectsByStatus(
      userId,
      status,
    );
    yield projects.map((dto) => dto.toEntity()).toList();
  }
}
