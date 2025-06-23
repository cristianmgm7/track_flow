import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import '../models/project_dto.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectsLocalDataSource {
  Future<void> cacheProject(ProjectDTO project);

  Future<ProjectDTO?> getCachedProject(UniqueId id);

  Future<void> removeCachedProject(UniqueId id);

  Future<List<ProjectDTO>> getAllProjects();

  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId);

  Future<void> clearCache();
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  final Isar _isar;

  ProjectsLocalDataSourceImpl(this._isar);

  @override
  Future<void> cacheProject(ProjectDTO project) async {
    final projectDoc = ProjectDocument.fromDTO(project);
    await _isar.writeTxn(() async {
      await _isar.projectDocuments.put(projectDoc);
    });
  }

  @override
  Future<ProjectDTO?> getCachedProject(UniqueId id) async {
    final projectDoc = await _isar.projectDocuments.get(fastHash(id.value));
    return projectDoc?.toDTO();
  }

  @override
  Future<void> removeCachedProject(UniqueId id) async {
    await _isar.writeTxn(() async {
      final projectDoc = await _isar.projectDocuments.get(fastHash(id.value));
      if (projectDoc != null) {
        projectDoc.isDeleted = true;
        await _isar.projectDocuments.put(projectDoc);
      }
    });
  }

  @override
  Future<List<ProjectDTO>> getAllProjects() async {
    final projectDocs = await _isar.projectDocuments.where().findAll();
    return projectDocs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId) {
    return _isar.projectDocuments
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (q) => q
              .ownerIdEqualTo(ownerId.value)
              .or()
              .collaboratorIdsElementEqualTo(ownerId.value),
        )
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }

  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.projectDocuments.clear();
    });
  }
}
