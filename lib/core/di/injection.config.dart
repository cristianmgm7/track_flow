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
import 'package:trackflow/core/di/app_module.dart' as _i850;
import 'package:trackflow/core/network/network_info.dart' as _i952;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i559;
import 'package:trackflow/core/session/session_storage.dart' as _i383;
import 'package:trackflow/core/sync/project_sync_service.dart' as _i1071;
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
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i1010;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i442;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i133;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i524;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i661;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i179;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i1050;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i856;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i741;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i253;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collabolators_remote_datasource.dart'
    as _i93;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i1050;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i1063;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i398;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i391;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i151;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i81;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart'
    as _i438;
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart'
    as _i508;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i509;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i167;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i703;
import 'package:trackflow/features/project_detail/domain/usecases/leave_project_usecase.dart'
    as _i650;
import 'package:trackflow/features/project_detail/domain/usecases/load_user_profile_collaborators_usecase.dart'
    as _i147;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i376;
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
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i744;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i416;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i839;
import 'package:trackflow/features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i120;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i435;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i218;

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
    gh.singleton<_i559.DynamicLinkService>(() => _i559.DynamicLinkService());
    gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => appModule.firebaseFirestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i973.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i979.Box<Map<dynamic, dynamic>>>(
        () => appModule.projectsBox);
    gh.lazySingleton<_i1010.MagicLinkLocalDataSource>(
        () => _i1010.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i509.ProjectDetailRemoteDataSource>(() =>
        _i509.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i952.NetworkInfo>(
        () => _i952.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()));
    gh.lazySingleton<_i383.SessionStorage>(
        () => _i383.SessionStorage(prefs: gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i442.MagicLinkRemoteDataSource>(() =>
        _i442.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i102.ProjectRemoteDataSource>(() =>
        _i102.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i334.ProjectsLocalDataSource>(() =>
        _i334.ProjectsLocalDataSourceImpl(
            box: gh<_i979.Box<Map<dynamic, dynamic>>>()));
    gh.lazySingleton<_i744.UserProfileRemoteDataSource>(() =>
        _i744.UserProfileRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i703.ProjectDetailRepository>(
        () => _i167.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i509.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i952.NetworkInfo>(),
            ));
    gh.factory<_i524.MagicLinkRepository>(() =>
        _i133.MagicLinkRepositoryImp(gh<_i442.MagicLinkRemoteDataSource>()));
    gh.lazySingleton<_i661.ConsumeMagicLinkUseCase>(
        () => _i661.ConsumeMagicLinkUseCase(gh<_i524.MagicLinkRepository>()));
    gh.lazySingleton<_i741.ValidateMagicLinkUseCase>(
        () => _i741.ValidateMagicLinkUseCase(gh<_i524.MagicLinkRepository>()));
    gh.lazySingleton<_i1050.GetMagicLinkStatusUseCase>(() =>
        _i1050.GetMagicLinkStatusUseCase(gh<_i524.MagicLinkRepository>()));
    gh.lazySingleton<_i856.ResendMagicLinkUseCase>(
        () => _i856.ResendMagicLinkUseCase(gh<_i524.MagicLinkRepository>()));
    gh.lazySingleton<_i650.LeaveProjectUseCase>(() => _i650.LeaveProjectUseCase(
          gh<_i703.ProjectDetailRepository>(),
          gh<_i383.SessionStorage>(),
        ));
    gh.lazySingleton<_i147.LoadUserProfileCollaboratorsUseCase>(() =>
        _i147.LoadUserProfileCollaboratorsUseCase(
            gh<_i703.ProjectDetailRepository>()));
    gh.lazySingleton<_i1022.ProjectsRepository>(
        () => _i553.ProjectsRepositoryImpl(
              remoteDataSource: gh<_i102.ProjectRemoteDataSource>(),
              localDataSource: gh<_i334.ProjectsLocalDataSource>(),
              networkInfo: gh<_i952.NetworkInfo>(),
            ));
    gh.lazySingleton<_i93.ManageCollaboratorsRemoteDataSource>(() =>
        _i93.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i744.UserProfileRemoteDataSource>(),
          firestore: gh<_i974.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i839.UserProfileRepository>(() =>
        _i416.UserProfileRepositoryImpl(
            gh<_i744.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i1043.DeleteProjectUseCase>(
        () => _i1043.DeleteProjectUseCase(
              gh<_i1022.ProjectsRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.lazySingleton<_i594.CreateProjectUseCase>(
        () => _i594.CreateProjectUseCase(
              gh<_i1022.ProjectsRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.lazySingleton<_i532.UpdateProjectUseCase>(
        () => _i532.UpdateProjectUseCase(
              gh<_i1022.ProjectsRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.factory<_i120.GetUserProfileUseCase>(() => _i120.GetUserProfileUseCase(
          gh<_i839.UserProfileRepository>(),
          gh<_i383.SessionStorage>(),
        ));
    gh.factory<_i435.UpdateUserProfileUseCase>(
        () => _i435.UpdateUserProfileUseCase(
              gh<_i839.UserProfileRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.factory<_i218.UserProfileBloc>(() => _i218.UserProfileBloc(
          getUserProfileUseCase: gh<_i120.GetUserProfileUseCase>(),
          updateUserProfileUseCase: gh<_i435.UpdateUserProfileUseCase>(),
        ));
    gh.factory<_i376.ProjectDetailBloc>(() => _i376.ProjectDetailBloc(
          getUserProfileCollaborators:
              gh<_i147.LoadUserProfileCollaboratorsUseCase>(),
          leaveProjectUseCase: gh<_i650.LeaveProjectUseCase>(),
        ));
    gh.factory<_i1071.ProjectSyncService>(() => _i1071.ProjectSyncService(
          repository: gh<_i1022.ProjectsRepository>(),
          localDataSource: gh<_i334.ProjectsLocalDataSource>(),
        ));
    gh.lazySingleton<_i1063.ManageCollaboratorsRepository>(
        () => _i1050.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i93.ManageCollaboratorsRemoteDataSource>(),
              networkInfo: gh<_i952.NetworkInfo>(),
              projectRemoteDataSource: gh<_i102.ProjectRemoteDataSource>(),
            ));
    gh.lazySingleton<_i461.WatchAllProjectsUseCase>(
        () => _i461.WatchAllProjectsUseCase(
              gh<_i1022.ProjectsRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.lazySingleton<_i104.AuthRepository>(() => _i447.AuthRepositoryImpl(
          auth: gh<_i59.FirebaseAuth>(),
          googleSignIn: gh<_i116.GoogleSignIn>(),
          prefs: gh<_i460.SharedPreferences>(),
          networkInfo: gh<_i952.NetworkInfo>(),
          firestore: gh<_i974.FirebaseFirestore>(),
          projectSyncService: gh<_i1071.ProjectSyncService>(),
        ));
    gh.lazySingleton<_i391.JoinProjectWithIdUseCase>(
        () => _i391.JoinProjectWithIdUseCase(
              gh<_i1063.ManageCollaboratorsRepository>(),
              gh<_i383.SessionStorage>(),
            ));
    gh.factory<_i534.ProjectsBloc>(() => _i534.ProjectsBloc(
          createProject: gh<_i594.CreateProjectUseCase>(),
          updateProject: gh<_i532.UpdateProjectUseCase>(),
          deleteProject: gh<_i1043.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i461.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i398.AddCollaboratorToProjectUseCase>(() =>
        _i398.AddCollaboratorToProjectUseCase(
            gh<_i1063.ManageCollaboratorsRepository>()));
    gh.lazySingleton<_i81.UpdateCollaboratorRoleUseCase>(() =>
        _i81.UpdateCollaboratorRoleUseCase(
            gh<_i1063.ManageCollaboratorsRepository>()));
    gh.lazySingleton<_i151.RemoveCollaboratorUseCase>(() =>
        _i151.RemoveCollaboratorUseCase(
            gh<_i1063.ManageCollaboratorsRepository>()));
    gh.factory<_i438.ManageCollaboratorsBloc>(() =>
        _i438.ManageCollaboratorsBloc(
          updateCollaboratorRoleUseCase:
              gh<_i81.UpdateCollaboratorRoleUseCase>(),
          addCollaboratorUseCase: gh<_i398.AddCollaboratorToProjectUseCase>(),
        ));
    gh.lazySingleton<_i690.GoogleSignInUseCase>(
        () => _i690.GoogleSignInUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i836.GetAuthStateUseCase>(
        () => _i836.GetAuthStateUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i442.OnboardingUseCase>(
        () => _i442.OnboardingUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i843.SignInUseCase>(
        () => _i843.SignInUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i490.SignUpUseCase>(
        () => _i490.SignUpUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i488.SignOutUseCase>(
        () => _i488.SignOutUseCase(gh<_i104.AuthRepository>()));
    gh.lazySingleton<_i179.GenerateMagicLinkUseCase>(
        () => _i179.GenerateMagicLinkUseCase(
              gh<_i524.MagicLinkRepository>(),
              gh<_i104.AuthRepository>(),
            ));
    gh.factory<_i253.MagicLinkBloc>(() => _i253.MagicLinkBloc(
          generateMagicLink: gh<_i179.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i741.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i661.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i856.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i1050.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i391.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i104.AuthRepository>(),
        ));
    gh.factory<_i340.AuthBloc>(() => _i340.AuthBloc(
          signIn: gh<_i843.SignInUseCase>(),
          signUp: gh<_i490.SignUpUseCase>(),
          signOut: gh<_i488.SignOutUseCase>(),
          googleSignIn: gh<_i690.GoogleSignInUseCase>(),
          getAuthState: gh<_i836.GetAuthStateUseCase>(),
          onboarding: gh<_i442.OnboardingUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i850.AppModule {}
