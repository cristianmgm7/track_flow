// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:trackflow/core/app/app_flow_cubit.dart' as _i685;
import 'package:trackflow/core/di/app_module.dart' as _i850;
import 'package:trackflow/core/network/network_info.dart' as _i952;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i447;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i104;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i836;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i690;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i442;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i843;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i488;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i490;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i340;
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart'
    as _i508;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i334;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i102;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i553;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i1022;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i594;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i1043;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i532;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i461;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i534;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i508.NavigationCubit>(() => _i508.NavigationCubit());
    gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => appModule.firebaseFirestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i973.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i979.Box<Map<dynamic, dynamic>>>(
        () => appModule.projectsBox);
    gh.lazySingleton<_i952.NetworkInfo>(
        () => _i952.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()));
    gh.lazySingleton<_i102.ProjectRemoteDataSource>(() =>
        _i102.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i334.ProjectsLocalDataSource>(() =>
        _i334.ProjectsLocalDataSourceImpl(
            box: gh<_i979.Box<Map<dynamic, dynamic>>>()));
    gh.lazySingleton<_i104.AuthRepository>(() => _i447.AuthRepositoryImpl(
          auth: gh<_i59.FirebaseAuth>(),
          googleSignIn: gh<_i116.GoogleSignIn>(),
          prefs: gh<_i460.SharedPreferences>(),
          networkInfo: gh<_i952.NetworkInfo>(),
        ));
    gh.lazySingleton<_i690.GoogleSignInUseCase>(
        () => _i690.GoogleSignInUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i836.GetAuthStateUseCase>(
        () => _i836.GetAuthStateUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i843.SignInUseCase>(
        () => _i843.SignInUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i490.SignUpUseCase>(
        () => _i490.SignUpUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i442.OnboardingUseCase>(
        () => _i442.OnboardingUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i488.SignOutUseCase>(
        () => _i488.SignOutUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i1022.ProjectsRepository>(
        () => _i553.ProjectsRepositoryImpl(
              remoteDataSource: gh<_i102.ProjectRemoteDataSource>(),
              localDataSource: gh<_i334.ProjectsLocalDataSource>(),
              networkInfo: gh<_i952.NetworkInfo>(),
            ));
    gh.factory<_i685.AppFlowCubit>(() => _i685.AppFlowCubit(
          authRepository: gh<_i104.AuthRepository>(),
          onboardingRepository: gh<_i442.OnboardingUseCase>(),
        ));
    gh.factory<_i340.AuthBloc>(() => _i340.AuthBloc(
          signIn: gh<_i843.SignInUseCase>(),
          signUp: gh<_i490.SignUpUseCase>(),
          signOut: gh<_i488.SignOutUseCase>(),
          googleSignIn: gh<_i690.GoogleSignInUseCase>(),
          getAuthState: gh<_i836.GetAuthStateUseCase>(),
          onboarding: gh<_i442.OnboardingUseCase>(),
        ));
    gh.lazySingleton<_i461.WatchAllProjectsUseCase>(
        () => _i461.WatchAllProjectsUseCase(gh<_i1022.ProjectsRepository>()));
    gh.lazySingleton<_i1043.DeleteProjectUseCase>(
        () => _i1043.DeleteProjectUseCase(gh<_i1022.ProjectsRepository>()));
    gh.lazySingleton<_i594.CreateProjectUseCase>(
        () => _i594.CreateProjectUseCase(gh<_i1022.ProjectsRepository>()));
    gh.lazySingleton<_i532.UpdateProjectUseCase>(
        () => _i532.UpdateProjectUseCase(gh<_i1022.ProjectsRepository>()));
    gh.factory<_i534.ProjectsBloc>(() => _i534.ProjectsBloc(
          createProject: gh<_i594.CreateProjectUseCase>(),
          updateProject: gh<_i532.UpdateProjectUseCase>(),
          deleteProject: gh<_i1043.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i461.WatchAllProjectsUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i850.AppModule {}
