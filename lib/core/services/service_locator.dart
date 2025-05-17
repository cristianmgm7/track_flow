import 'package:get_it/get_it.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
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

final sl = GetIt.instance;

void setupProjectDependencies() {
  sl.registerLazySingleton<ProjectRepository>(() => SyncProjectRepository());
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(
    () => ProjectUseCases(
      createProject: sl(),
      updateProject: sl(),
      deleteProject: sl(),
      repository: sl(),
      getProjectById: sl(),
    ),
  );
}

Future<void> setupAuthDependencies() async {
  final prefs = await SharedPreferences.getInstance();
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
