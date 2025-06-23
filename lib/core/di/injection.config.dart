// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i4;

import 'package:cloud_firestore/cloud_firestore.dart' as _i7;
import 'package:firebase_auth/firebase_auth.dart' as _i6;
import 'package:firebase_storage/firebase_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i10;
import 'package:isar/isar.dart' as _i11;
import 'package:shared_preferences/shared_preferences.dart' as _i26;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i94;
import 'package:trackflow/core/di/app_module.dart' as _i100;
import 'package:trackflow/core/network/network_info.dart' as _i17;
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart'
    as _i3;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i5;
import 'package:trackflow/core/session/session_storage.dart' as _i57;
import 'package:trackflow/core/sync/project_sync_service.dart' as _i55;
import 'package:trackflow/features/audio_cache/audio_cache_cubit.dart' as _i74;
import 'package:trackflow/features/audio_cache/data/datasources/audio_cache_local_data_source.dart'
    as _i33;
import 'package:trackflow/features/audio_cache/data/repositories/audio_cache_repository_impl.dart'
    as _i35;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart'
    as _i34;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart'
    as _i47;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i36;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i37;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i39;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i38;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i54;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comement_usecase.dart'
    as _i78;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i68;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i96;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i40;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i41;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i43;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i42;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i56;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i79;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i70;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i97;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i44;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i45;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i76;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i75;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i82;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i83;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i91;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i92;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i93;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i98;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i12;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i13;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i15;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i14;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i46;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i81;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i48;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i25;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i31;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i86;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collabolators_remote_datasource.dart'
    as _i51;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i50;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i53;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i52;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i73;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i84;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i85;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i90;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i63;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i32;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart'
    as _i99;
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart'
    as _i16;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i18;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i20;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i19;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i49;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i69;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i88;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i22;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i21;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i24;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i23;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i77;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i80;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i60;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i64;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i67;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i89;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i27;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i28;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i30;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i29;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i61;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i62;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i65;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i71;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i95;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i3.AudioPlayerBloc>(() => _i3.AudioPlayerBloc());
    await gh.factoryAsync<_i4.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i5.DynamicLinkService>(() => _i5.DynamicLinkService());
    gh.lazySingleton<_i6.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i7.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i8.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i9.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i10.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i11.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i12.MagicLinkLocalDataSource>(
        () => _i12.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i13.MagicLinkRemoteDataSource>(() =>
        _i13.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i7.FirebaseFirestore>()));
    gh.factory<_i14.MagicLinkRepository>(() =>
        _i15.MagicLinkRepositoryImp(gh<_i13.MagicLinkRemoteDataSource>()));
    gh.factory<_i16.NavigationCubit>(() => _i16.NavigationCubit());
    gh.lazySingleton<_i17.NetworkInfo>(
        () => _i17.NetworkInfoImpl(gh<_i10.InternetConnectionChecker>()));
    gh.lazySingleton<_i18.ProjectDetailRemoteDataSource>(() =>
        _i18.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i19.ProjectDetailRepository>(
        () => _i20.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i18.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i21.ProjectRemoteDataSource>(() =>
        _i21.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i22.ProjectsLocalDataSource>(
        () => _i22.ProjectsLocalDataSourceImpl(gh<_i11.Isar>()));
    gh.lazySingleton<_i23.ProjectsRepository>(() => _i24.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i21.ProjectRemoteDataSource>(),
          localDataSource: gh<_i22.ProjectsLocalDataSource>(),
          networkInfo: gh<_i17.NetworkInfo>(),
        ));
    gh.lazySingleton<_i25.ResendMagicLinkUseCase>(
        () => _i25.ResendMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    await gh.factoryAsync<_i26.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i27.UserProfileLocalDataSource>(
        () => _i27.IsarUserProfileLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i28.UserProfileRemoteDataSource>(
        () => _i28.UserProfileRemoteDataSourceImpl(
              gh<_i7.FirebaseFirestore>(),
              gh<_i8.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i29.UserProfileRepository>(
        () => _i30.UserProfileRepositoryImpl(
              gh<_i28.UserProfileRemoteDataSource>(),
              gh<_i27.UserProfileLocalDataSource>(),
              gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i31.ValidateMagicLinkUseCase>(
        () => _i31.ValidateMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i32.WatchUserProfilesUseCase>(
        () => _i32.WatchUserProfilesUseCase(gh<_i29.UserProfileRepository>()));
    gh.lazySingleton<_i33.AudioCacheLocalDataSource>(
        () => _i33.AudioCacheLocalDataSourceImpl(
              gh<_i8.FirebaseStorage>(),
              gh<_i4.Directory>(),
            ));
    gh.lazySingleton<_i34.AudioCacheRepository>(() =>
        _i35.AudioCacheRepositoryImpl(gh<_i33.AudioCacheLocalDataSource>()));
    gh.lazySingleton<_i36.AudioCommentLocalDataSource>(
        () => _i36.IsarAudioCommentLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i37.AudioCommentRemoteDataSource>(() =>
        _i37.FirebaseAudioCommentRemoteDataSource(gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i38.AudioCommentRepository>(
        () => _i39.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i37.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i36.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i40.AudioTrackLocalDataSource>(
        () => _i40.IsarAudioTrackLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i41.AudioTrackRemoteDataSource>(
        () => _i41.AudioTrackRemoteDataSourceImpl(
              gh<_i7.FirebaseFirestore>(),
              gh<_i8.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i42.AudioTrackRepository>(
        () => _i43.AudioTrackRepositoryImpl(
              gh<_i41.AudioTrackRemoteDataSource>(),
              gh<_i40.AudioTrackLocalDataSource>(),
              gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i44.AuthLocalDataSource>(
        () => _i44.AuthLocalDataSourceImpl(gh<_i26.SharedPreferences>()));
    gh.lazySingleton<_i45.AuthRemoteDataSource>(
        () => _i45.AuthRemoteDataSourceImpl(
              gh<_i6.FirebaseAuth>(),
              gh<_i9.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i46.ConsumeMagicLinkUseCase>(
        () => _i46.ConsumeMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i47.GetCachedAudioPath>(
        () => _i47.GetCachedAudioPath(gh<_i34.AudioCacheRepository>()));
    gh.lazySingleton<_i48.GetMagicLinkStatusUseCase>(
        () => _i48.GetMagicLinkStatusUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i49.GetProjectByIdUseCase>(
        () => _i49.GetProjectByIdUseCase(gh<_i19.ProjectDetailRepository>()));
    gh.lazySingleton<_i50.ManageCollaboratorsLocalDataSource>(() =>
        _i50.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i22.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i51.ManageCollaboratorsRemoteDataSource>(() =>
        _i51.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i28.UserProfileRemoteDataSource>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i52.ManageCollaboratorsRepository>(
        () => _i53.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i51.ManageCollaboratorsRemoteDataSource>(),
              localDataSourceManageCollaborators:
                  gh<_i50.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i54.ProjectCommentService>(
        () => _i54.ProjectCommentService(gh<_i38.AudioCommentRepository>()));
    gh.factory<_i55.ProjectSyncService>(() => _i55.ProjectSyncService(
          repository: gh<_i23.ProjectsRepository>(),
          localDataSource: gh<_i22.ProjectsLocalDataSource>(),
        ));
    gh.lazySingleton<_i56.ProjectTrackService>(
        () => _i56.ProjectTrackService(gh<_i42.AudioTrackRepository>()));
    gh.lazySingleton<_i57.SessionStorage>(
        () => _i57.SessionStorage(prefs: gh<_i26.SharedPreferences>()));
    gh.lazySingleton<_i58.SyncAudioCommentsUseCase>(
        () => _i58.SyncAudioCommentsUseCase(
              gh<_i37.AudioCommentRemoteDataSource>(),
              gh<_i36.AudioCommentLocalDataSource>(),
              gh<_i21.ProjectRemoteDataSource>(),
              gh<_i57.SessionStorage>(),
              gh<_i41.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i59.SyncAudioTracksUseCase>(
        () => _i59.SyncAudioTracksUseCase(
              gh<_i41.AudioTrackRemoteDataSource>(),
              gh<_i40.AudioTrackLocalDataSource>(),
              gh<_i21.ProjectRemoteDataSource>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i60.SyncProjectsUseCase>(() => _i60.SyncProjectsUseCase(
          gh<_i21.ProjectRemoteDataSource>(),
          gh<_i22.ProjectsLocalDataSource>(),
          gh<_i57.SessionStorage>(),
        ));
    gh.lazySingleton<_i61.SyncUserProfileCollaboratorsUseCase>(
        () => _i61.SyncUserProfileCollaboratorsUseCase(
              gh<_i22.ProjectsLocalDataSource>(),
              gh<_i29.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i62.SyncUserProfileUseCase>(
        () => _i62.SyncUserProfileUseCase(
              gh<_i28.UserProfileRemoteDataSource>(),
              gh<_i27.UserProfileLocalDataSource>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i63.UpdateCollaboratorRoleUseCase>(
        () => _i63.UpdateCollaboratorRoleUseCase(
              gh<_i19.ProjectDetailRepository>(),
              gh<_i52.ManageCollaboratorsRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i64.UpdateProjectUseCase>(() => _i64.UpdateProjectUseCase(
          gh<_i23.ProjectsRepository>(),
          gh<_i57.SessionStorage>(),
        ));
    gh.factory<_i65.UpdateUserProfileUseCase>(
        () => _i65.UpdateUserProfileUseCase(
              gh<_i29.UserProfileRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i66.UploadAudioTrackUseCase>(
        () => _i66.UploadAudioTrackUseCase(
              gh<_i56.ProjectTrackService>(),
              gh<_i19.ProjectDetailRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i67.WatchAllProjectsUseCase>(
        () => _i67.WatchAllProjectsUseCase(
              gh<_i23.ProjectsRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i68.WatchCommentsByTrackUseCase>(() =>
        _i68.WatchCommentsByTrackUseCase(gh<_i54.ProjectCommentService>()));
    gh.lazySingleton<_i69.WatchProjectDetailUseCase>(
        () => _i69.WatchProjectDetailUseCase(
              gh<_i40.AudioTrackLocalDataSource>(),
              gh<_i27.UserProfileLocalDataSource>(),
              gh<_i36.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i70.WatchTracksByProjectIdUseCase>(() =>
        _i70.WatchTracksByProjectIdUseCase(gh<_i42.AudioTrackRepository>()));
    gh.lazySingleton<_i71.WatchUserProfileUseCase>(
        () => _i71.WatchUserProfileUseCase(
              gh<_i29.UserProfileRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i72.AddAudioCommentUseCase>(
        () => _i72.AddAudioCommentUseCase(
              gh<_i54.ProjectCommentService>(),
              gh<_i19.ProjectDetailRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i73.AddCollaboratorToProjectUseCase>(
        () => _i73.AddCollaboratorToProjectUseCase(
              gh<_i19.ProjectDetailRepository>(),
              gh<_i52.ManageCollaboratorsRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.factory<_i74.AudioCacheCubit>(
        () => _i74.AudioCacheCubit(gh<_i47.GetCachedAudioPath>()));
    gh.lazySingleton<_i75.AuthRepository>(() => _i76.AuthRepositoryImpl(
          remote: gh<_i45.AuthRemoteDataSource>(),
          local: gh<_i44.AuthLocalDataSource>(),
          networkInfo: gh<_i17.NetworkInfo>(),
          firestore: gh<_i7.FirebaseFirestore>(),
          projectSyncService: gh<_i55.ProjectSyncService>(),
          userProfileLocalDataSource: gh<_i27.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i22.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i40.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i36.AudioCommentLocalDataSource>(),
        ));
    gh.lazySingleton<_i77.CreateProjectUseCase>(() => _i77.CreateProjectUseCase(
          gh<_i23.ProjectsRepository>(),
          gh<_i57.SessionStorage>(),
        ));
    gh.lazySingleton<_i78.DeleteAudioCommentUseCase>(
        () => _i78.DeleteAudioCommentUseCase(
              gh<_i54.ProjectCommentService>(),
              gh<_i19.ProjectDetailRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i79.DeleteAudioTrack>(() => _i79.DeleteAudioTrack(
          gh<_i57.SessionStorage>(),
          gh<_i19.ProjectDetailRepository>(),
          gh<_i56.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i80.DeleteProjectUseCase>(() => _i80.DeleteProjectUseCase(
          gh<_i23.ProjectsRepository>(),
          gh<_i57.SessionStorage>(),
        ));
    gh.lazySingleton<_i81.GenerateMagicLinkUseCase>(
        () => _i81.GenerateMagicLinkUseCase(
              gh<_i14.MagicLinkRepository>(),
              gh<_i75.AuthRepository>(),
            ));
    gh.lazySingleton<_i82.GetAuthStateUseCase>(
        () => _i82.GetAuthStateUseCase(gh<_i75.AuthRepository>()));
    gh.lazySingleton<_i83.GoogleSignInUseCase>(
        () => _i83.GoogleSignInUseCase(gh<_i75.AuthRepository>()));
    gh.lazySingleton<_i84.JoinProjectWithIdUseCase>(
        () => _i84.JoinProjectWithIdUseCase(
              gh<_i19.ProjectDetailRepository>(),
              gh<_i52.ManageCollaboratorsRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i85.LeaveProjectUseCase>(() => _i85.LeaveProjectUseCase(
          gh<_i52.ManageCollaboratorsRepository>(),
          gh<_i57.SessionStorage>(),
        ));
    gh.factory<_i86.MagicLinkBloc>(() => _i86.MagicLinkBloc(
          generateMagicLink: gh<_i81.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i31.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i46.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i25.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i48.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i84.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i75.AuthRepository>(),
        ));
    gh.lazySingleton<_i87.OnboardingUseCase>(
        () => _i87.OnboardingUseCase(gh<_i75.AuthRepository>()));
    gh.factory<_i88.ProjectDetailBloc>(() => _i88.ProjectDetailBloc(
        watchProjectDetail: gh<_i69.WatchProjectDetailUseCase>()));
    gh.factory<_i89.ProjectsBloc>(() => _i89.ProjectsBloc(
          createProject: gh<_i77.CreateProjectUseCase>(),
          updateProject: gh<_i64.UpdateProjectUseCase>(),
          deleteProject: gh<_i80.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i67.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i90.RemoveCollaboratorUseCase>(
        () => _i90.RemoveCollaboratorUseCase(
              gh<_i19.ProjectDetailRepository>(),
              gh<_i52.ManageCollaboratorsRepository>(),
              gh<_i57.SessionStorage>(),
            ));
    gh.lazySingleton<_i91.SignInUseCase>(
        () => _i91.SignInUseCase(gh<_i75.AuthRepository>()));
    gh.lazySingleton<_i92.SignOutUseCase>(
        () => _i92.SignOutUseCase(gh<_i75.AuthRepository>()));
    gh.lazySingleton<_i93.SignUpUseCase>(
        () => _i93.SignUpUseCase(gh<_i75.AuthRepository>()));
    gh.lazySingleton<_i94.StartupResourceManager>(
        () => _i94.StartupResourceManager(
              gh<_i58.SyncAudioCommentsUseCase>(),
              gh<_i59.SyncAudioTracksUseCase>(),
              gh<_i60.SyncProjectsUseCase>(),
              gh<_i62.SyncUserProfileUseCase>(),
              gh<_i61.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i95.UserProfileBloc>(() => _i95.UserProfileBloc(
          updateUserProfileUseCase: gh<_i65.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i71.WatchUserProfileUseCase>(),
        ));
    gh.factory<_i96.AudioCommentBloc>(() => _i96.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i68.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i72.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i78.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i97.AudioTrackBloc>(() => _i97.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i70.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i79.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i66.UploadAudioTrackUseCase>(),
        ));
    gh.factory<_i98.AuthBloc>(() => _i98.AuthBloc(
          signIn: gh<_i91.SignInUseCase>(),
          signUp: gh<_i93.SignUpUseCase>(),
          signOut: gh<_i92.SignOutUseCase>(),
          googleSignIn: gh<_i83.GoogleSignInUseCase>(),
          getAuthState: gh<_i82.GetAuthStateUseCase>(),
          onboarding: gh<_i87.OnboardingUseCase>(),
        ));
    gh.factory<_i99.ManageCollaboratorsBloc>(() => _i99.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i73.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i90.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i63.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i85.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i32.WatchUserProfilesUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i100.AppModule {}
