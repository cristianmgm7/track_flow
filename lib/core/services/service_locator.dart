import 'package:get_it/get_it.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_projec_by_id_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/getting_all-projects_use_case.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
// Auth imports
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';

final sl = GetIt.instance;

class InMemoryProjectRepository implements ProjectRepository {
  final Map<String, Project> _projects = {};

  @override
  Future<Either<Failure, Unit>> createProject(Project project) async {
    _projects[project.id.value] = project;
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    if (_projects.containsKey(project.id.value)) {
      _projects[project.id.value] = project;
      return Right(unit);
    }
    return Left(DatabaseFailure('Project not found'));
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(UniqueId id) async {
    _projects.remove(id.value);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Project>> getProjectById(UniqueId id) async {
    final project = _projects[id.value];
    if (project != null) {
      return Right(project);
    }
    return Left(DatabaseFailure('Project not found'));
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    return Right(_projects.values.toList());
  }
}

void setupProjectDependencies({bool testMode = true}) {
  sl.registerLazySingleton<ProjectRepository>(
    () => InMemoryProjectRepository(),
  );
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAllProjectsUseCase(sl()));
  sl.registerLazySingleton(
    () => ProjectUseCases(
      createProject: sl(),
      updateProject: sl(),
      deleteProject: sl(),
      repository: sl(),
      getProjectById: sl(),
      getAllProjects: sl(),
    ),
  );
}

Future<void> setupAuthDependencies(SharedPreferences prefs) async {
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      auth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
      prefs: prefs,
    ),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStateUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthUseCases(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      googleSignIn: sl(),
      getAuthState: sl(),
    ),
  );
}
