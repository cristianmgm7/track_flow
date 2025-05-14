import 'package:hive/hive.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for local project operations.
abstract class ProjectLocalDataSource {
  /// Caches a list of projects locally.
  Future<void> cacheProjects(List<ProjectDTO> projects);

  /// Gets all cached projects for a specific user.
  Future<List<ProjectDTO>> getCachedProjects(String userId);

  /// Gets all cached projects for a specific user with a given status.
  Future<List<ProjectDTO>> getCachedProjectsByStatus(
    String userId,
    String status,
  );

  /// Caches a single project locally.
  Future<void> cacheProject(ProjectDTO project);

  /// Gets a cached project by its ID.
  Future<ProjectDTO?> getCachedProject(String id);

  /// Removes a project from the cache.
  Future<void> removeCachedProject(String id);

  /// Clears all cached projects for a specific user.
  Future<void> clearUserCache(String userId);
}

/// Implementation of [ProjectLocalDataSource] using Hive.
class HiveProjectLocalDataSource implements ProjectLocalDataSource {
  static const String _boxName = 'projects';
  late final Box<Map<String, dynamic>> _box;

  HiveProjectLocalDataSource({Box<Map<String, dynamic>>? box}) {
    _box = box ?? Hive.box<Map<String, dynamic>>(_boxName);
  }

  String _getUserKey(String userId) => 'user_$userId';
  String _getUserStatusKey(String userId, String status) =>
      'user_${userId}_$status';

  @override
  Future<void> cacheProjects(List<ProjectDTO> projects) async {
    if (projects.isEmpty) return;

    final userId = projects.first.userId;
    final userKey = _getUserKey(userId);

    // Cache all projects
    await _box.put(userKey, {
      for (var project in projects) project.id: project.toMap(),
    });

    // Cache projects by status
    final projectsByStatus = <String, List<ProjectDTO>>{};
    for (var project in projects) {
      projectsByStatus.putIfAbsent(project.status, () => []).add(project);
    }

    for (var entry in projectsByStatus.entries) {
      final statusKey = _getUserStatusKey(userId, entry.key);
      await _box.put(statusKey, {
        for (var project in entry.value) project.id: project.toMap(),
      });
    }
  }

  @override
  Future<List<ProjectDTO>> getCachedProjects(String userId) async {
    final userKey = _getUserKey(userId);
    final data = _box.get(userKey);
    if (data == null) return [];

    return data.entries.map((e) {
      return ProjectDTO.fromMap({
        'id': e.key,
        ...Map<String, dynamic>.from(e.value),
      });
    }).toList();
  }

  @override
  Future<List<ProjectDTO>> getCachedProjectsByStatus(
    String userId,
    String status,
  ) async {
    final statusKey = _getUserStatusKey(userId, status);
    final data = _box.get(statusKey);
    if (data == null) return [];

    return data.entries.map((e) {
      return ProjectDTO.fromMap({
        'id': e.key,
        ...Map<String, dynamic>.from(e.value),
      });
    }).toList();
  }

  @override
  Future<void> cacheProject(ProjectDTO project) async {
    final userId = project.userId;
    final userKey = _getUserKey(userId);
    final statusKey = _getUserStatusKey(userId, project.status);

    // Update user's projects
    final userData = _box.get(userKey) ?? {};
    userData[project.id] = project.toMap();
    await _box.put(userKey, userData);

    // Update status-specific projects
    final statusData = _box.get(statusKey) ?? {};
    statusData[project.id] = project.toMap();
    await _box.put(statusKey, statusData);
  }

  @override
  Future<ProjectDTO?> getCachedProject(String id) async {
    // Search in all user boxes
    for (var key in _box.keys) {
      if (key is String && key.startsWith('user_')) {
        final data = _box.get(key);
        if (data != null && data.containsKey(id)) {
          return ProjectDTO.fromMap({
            'id': id,
            ...Map<String, dynamic>.from(data[id]),
          });
        }
      }
    }
    return null;
  }

  @override
  Future<void> removeCachedProject(String id) async {
    // Remove from all user boxes
    for (var key in _box.keys) {
      if (key is String && key.startsWith('user_')) {
        final data = _box.get(key);
        if (data != null && data.containsKey(id)) {
          data.remove(id);
          await _box.put(key, data);
        }
      }
    }
  }

  @override
  Future<void> clearUserCache(String userId) async {
    // Remove all keys related to this user
    final keysToRemove =
        _box.keys
            .where((key) => key is String && key.startsWith('user_$userId'))
            .toList();
    await _box.deleteAll(keysToRemove);
  }
}
