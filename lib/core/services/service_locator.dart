import 'package:get_it/get_it.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_user_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';

final sl = GetIt.instance;

void setupProjectDependencies() {
  sl.registerLazySingleton<ProjectRepository>(() => SyncProjectRepository());
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl()));
  sl.registerLazySingleton(
    () => ProjectUseCases(
      createProject: sl(),
      updateProject: sl(),
      deleteProject: sl(),
      getUserProjects: sl(),
      getProjectById: sl(),
    ),
  );
}
