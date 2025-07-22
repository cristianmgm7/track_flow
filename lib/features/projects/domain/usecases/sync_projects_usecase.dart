import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';

@lazySingleton
class SyncProjectsUseCase {
  final ProjectRemoteDataSource remote;
  final ProjectsLocalDataSource local;
  final SessionStorage sessionStorage;

  SyncProjectsUseCase(this.remote, this.local, this.sessionStorage);

  Future<void> call() async {
    print('SyncProjectsUseCase: Starting sync...');
    final userId = await sessionStorage.getUserId(); // Now async - prevents race conditions
    print('SyncProjectsUseCase: userId from session storage: $userId');

    if (userId == null) {
      print('SyncProjectsUseCase: No userId found, skipping sync (preserving cache)');
      // DON'T clear cache - preserve existing data when no userId
      return;
    }

    print(
      'SyncProjectsUseCase: Fetching projects from remote for user: $userId',
    );
    final failureOrProjects = await remote.getUserProjects(userId);

    await failureOrProjects.fold(
      (failure) async {
        // Don't clear cache if remote fetch fails - preserve existing data
        print('SyncProjectsUseCase: Error syncing projects: $failure');
      },
      (projects) async {
        print(
          'SyncProjectsUseCase: Received ${projects.length} projects from remote',
        );
        // Only clear cache when we have new data to replace it
        await local.clearCache();
        print('SyncProjectsUseCase: Cleared local cache');

        for (final project in projects) {
          print(
            'SyncProjectsUseCase: Caching project: ${project.name} (${project.id})',
          );
          await local.cacheProject(project);
        }
        print(
          'SyncProjectsUseCase: Finished caching ${projects.length} projects',
        );
      },
    );
  }
}
