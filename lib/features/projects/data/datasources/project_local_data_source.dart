import 'package:hive/hive.dart';
import '../models/project_dto.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectLocalDataSource {
  Future<void> cacheProject(ProjectDTO project);

  Future<ProjectDTO?> getCachedProject(UniqueId id);

  Future<void> removeCachedProject(UniqueId id);

  Future<List<ProjectDTO>> getAllProjects();

  Stream<List<ProjectDTO>> watchAllProjects();
}

class HiveProjectLocalDataSource implements ProjectLocalDataSource {
  static const String _boxName = 'projects';
  late final Box<Map<String, dynamic>> _box;

  HiveProjectLocalDataSource({Box<Map<String, dynamic>>? box}) {
    _box = box ?? Hive.box<Map<String, dynamic>>(_boxName);
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
    return _box.values.map((e) => ProjectDTO.fromMap(e)).toList();
  }

  @override
  Stream<List<ProjectDTO>> watchAllProjects() {
    return _box.watch().asyncMap((_) => getAllProjects());
  }
}
