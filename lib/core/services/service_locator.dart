import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_use_case.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
// Auth imports
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart';
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
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';

final sl = GetIt.instance;

void setupProjectDependencies() {
  //blocs
  sl.registerFactory(() => ProjectsBloc(sl(), sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(
    () => AppFlowCubit(authRepository: sl(), onboardingRepository: sl()),
  );

  //repositories
  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  //usecases
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl()));
  sl.registerLazySingleton(
    () => ProjectUseCases(
      createProject: sl(),
      updateProject: sl(),
      deleteProject: sl(),
      repository: sl(),
      getProjectById: sl(),
    ),
  );
  //core!
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );
  //
  //datasources
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => FirestoreProjectDataSource(),
  );
  sl.registerLazySingleton<ProjectLocalDataSource>(
    () => HiveProjectLocalDataSource(box: sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

Future<void> setupAuthDependencies(SharedPreferences prefs) async {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
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
  sl.registerLazySingleton(() => WatchAllProjectsUseCase(sl()));
  final projectsBox = await Hive.openBox<Map<String, dynamic>>('projectsBox');
  // Register it with GetIt
  sl.registerSingleton<Box<Map<String, dynamic>>>(projectsBox);
}
