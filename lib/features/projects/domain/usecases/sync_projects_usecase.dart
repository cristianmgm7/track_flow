import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

@lazySingleton
class SyncProjectsUseCase {
  final ProjectRemoteDataSource remote;
  final ProjectsLocalDataSource local;
  final SessionStorage sessionStorage;

  SyncProjectsUseCase(this.remote, this.local, this.sessionStorage);

  Future<void> call() async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return;
    }
    final failureOrProjects = await remote.getUserProjects(userId);
    await failureOrProjects.fold((failure) async {}, (projects) async {
      for (final project in projects) {
        await local.cacheProject(ProjectDTO.fromDomain(project));
      }
    });
  }
}
