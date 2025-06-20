import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/project_dto.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectsLocalDataSource {
  Future<void> cacheProject(ProjectDTO project);

  Future<ProjectDTO?> getCachedProject(UniqueId id);

  Future<void> removeCachedProject(UniqueId id);

  Future<List<ProjectDTO>> getAllProjects();

  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId);
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  late final Box<ProjectDTO> _box;

  ProjectsLocalDataSourceImpl({required Box<ProjectDTO> box}) {
    _box = box;
  }

  @override
  Future<void> cacheProject(ProjectDTO project) async {
    await _box.put(project.id, project);
  }

  @override
  Future<ProjectDTO?> getCachedProject(UniqueId id) async {
    return _box.get(id.value);
  }

  @override
  Future<void> removeCachedProject(UniqueId id) async {
    await _box.delete(id.value);
  }

  @override
  Future<List<ProjectDTO>> getAllProjects() async {
    return _box.values.toList();
  }

  @override
  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId) async* {
    yield (await getAllProjects())
        .where(
          (dto) =>
              dto.ownerId == ownerId.value ||
              dto.collaborators.contains(ownerId.value),
        )
        .toList();

    yield* _box.watch().asyncMap((_) async {
      final all = await getAllProjects();
      return all
          .where(
            (dto) =>
                dto.ownerId == ownerId.value ||
                dto.collaborators.contains(ownerId.value),
          )
          .toList();
    });
  }
}
