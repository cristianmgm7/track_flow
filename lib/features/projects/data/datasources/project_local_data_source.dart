import 'package:flutter/foundation.dart';
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
  late final Box<Map> _box;

  ProjectsLocalDataSourceImpl({required Box<Map> box}) {
    _box = box;
  }

  @override
  Future<void> cacheProject(ProjectDTO project) async {
    await _box.put(project.id, project.toMap());
  }

  @override
  Future<ProjectDTO?> getCachedProject(UniqueId id) async {
    final data = _box.get(id.value);
    if (data == null) return null;
    return ProjectDTO.fromMap({
      'id': id.value,
      ...Map<String, dynamic>.from(data),
    });
  }

  @override
  Future<void> removeCachedProject(UniqueId id) async {
    await _box.delete(id.value);
  }

  @override
  Future<List<ProjectDTO>> getAllProjects() async {
    return _box.values
        .whereType<Map>() // only maps
        .map((e) => ProjectDTO.fromMap(Map<String, dynamic>.from(e)))
        .toList();
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

    // Luego escuchar los cambios y filtrar también
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
