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
  final Box<Map> _box;

  ProjectsLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheProject(ProjectDTO project) async {
    await _box.put(project.id, project.toMap());
  }

  @override
  Future<ProjectDTO?> getCachedProject(UniqueId id) async {
    final map = _box.get(id.value);
    if (map != null) {
      return ProjectDTO.fromMap(map.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<void> removeCachedProject(UniqueId id) async {
    await _box.delete(id.value);
  }

  @override
  Future<List<ProjectDTO>> getAllProjects() async {
    return _box.values
        .map((map) => ProjectDTO.fromMap(map.cast<String, dynamic>()))
        .toList();
  }

  @override
  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId) async* {
    yield (await getAllProjects())
        .where(
          (dto) =>
              dto.ownerId == ownerId.value ||
              dto.collaboratorIds.contains(ownerId.value),
        )
        .toList();

    yield* _box.watch().asyncMap((_) async {
      final all = await getAllProjects();
      return all
          .where(
            (dto) =>
                dto.ownerId == ownerId.value ||
                dto.collaboratorIds.contains(ownerId.value),
          )
          .toList();
    });
  }
}
