// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i3;

import 'package:cloud_firestore/cloud_firestore.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i5;
import 'package:firebase_storage/firebase_storage.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i8;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i9;
import 'package:isar/isar.dart' as _i10;
import 'package:shared_preferences/shared_preferences.dart' as _i28;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i98;
import 'package:trackflow/core/di/app_module.dart' as _i106;
import 'package:trackflow/core/network/network_info.dart' as _i16;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i4;
import 'package:trackflow/core/session/session_storage.dart' as _i58;
import 'package:trackflow/features/audio_cache/data/datasources/audio_cache_local_data_source.dart'
    as _i35;
import 'package:trackflow/features/audio_cache/data/repositories/audio_cache_repository_impl.dart'
    as _i37;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart'
    as _i36;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart'
    as _i49;
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_cubit.dart'
    as _i75;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i38;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i39;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i41;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i40;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i73;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comement_usecase.dart'
    as _i81;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i101;
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart'
    as _i102;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i76;
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart'
    as _i17;
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart'
    as _i18;
import 'package:trackflow/features/audio_player/infrastructure/audio_source_resolver_impl.dart'
    as _i77;
import 'package:trackflow/features/audio_player/infrastructure/playback_state_persistence_impl.dart'
    as _i19;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i42;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i43;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i45;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i44;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i57;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i82;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i84;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i71;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i103;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i46;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i47;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i79;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i78;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i86;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i91;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i95;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i96;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i97;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i104;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i11;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i12;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i14;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i13;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i48;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i85;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i50;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i33;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i90;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i52;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i53;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i55;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i54;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i100;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i74;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i88;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i89;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i94;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i64;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i34;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i105;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i15;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i20;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i22;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i21;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i51;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i70;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i92;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i24;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i23;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i26;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i25;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i80;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i83;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i61;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i65;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i68;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i93;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i29;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i30;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i32;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i31;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i62;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i63;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i66;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i72;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i99;

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
    await gh.factoryAsync<_i3.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i4.DynamicLinkService>(() => _i4.DynamicLinkService());
    gh.lazySingleton<_i5.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i6.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i7.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i8.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i9.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i10.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i11.MagicLinkLocalDataSource>(
        () => _i11.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i12.MagicLinkRemoteDataSource>(() =>
        _i12.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i6.FirebaseFirestore>()));
    gh.factory<_i13.MagicLinkRepository>(() =>
        _i14.MagicLinkRepositoryImp(gh<_i12.MagicLinkRemoteDataSource>()));
    gh.factory<_i15.NavigationCubit>(() => _i15.NavigationCubit());
    gh.lazySingleton<_i16.NetworkInfo>(
        () => _i16.NetworkInfoImpl(gh<_i9.InternetConnectionChecker>()));
    gh.lazySingleton<_i17.PlaybackService>(
        () => appModule.providePlaybackService());
    gh.factory<_i18.PlaybackStatePersistence>(
        () => _i19.PlaybackStatePersistenceImpl());
    gh.lazySingleton<_i20.ProjectDetailRemoteDataSource>(() =>
        _i20.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i6.FirebaseFirestore>()));
    gh.lazySingleton<_i21.ProjectDetailRepository>(
        () => _i22.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i20.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i16.NetworkInfo>(),
            ));
    gh.lazySingleton<_i23.ProjectRemoteDataSource>(() =>
        _i23.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i6.FirebaseFirestore>()));
    gh.lazySingleton<_i24.ProjectsLocalDataSource>(
        () => _i24.ProjectsLocalDataSourceImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i25.ProjectsRepository>(() => _i26.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i23.ProjectRemoteDataSource>(),
          localDataSource: gh<_i24.ProjectsLocalDataSource>(),
          networkInfo: gh<_i16.NetworkInfo>(),
        ));
    gh.lazySingleton<_i27.ResendMagicLinkUseCase>(
        () => _i27.ResendMagicLinkUseCase(gh<_i13.MagicLinkRepository>()));
    await gh.factoryAsync<_i28.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i29.UserProfileLocalDataSource>(
        () => _i29.IsarUserProfileLocalDataSource(gh<_i10.Isar>()));
    gh.lazySingleton<_i30.UserProfileRemoteDataSource>(
        () => _i30.UserProfileRemoteDataSourceImpl(
              gh<_i6.FirebaseFirestore>(),
              gh<_i7.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i31.UserProfileRepository>(
        () => _i32.UserProfileRepositoryImpl(
              gh<_i30.UserProfileRemoteDataSource>(),
              gh<_i29.UserProfileLocalDataSource>(),
              gh<_i16.NetworkInfo>(),
            ));
    gh.lazySingleton<_i33.ValidateMagicLinkUseCase>(
        () => _i33.ValidateMagicLinkUseCase(gh<_i13.MagicLinkRepository>()));
    gh.lazySingleton<_i34.WatchUserProfilesUseCase>(
        () => _i34.WatchUserProfilesUseCase(gh<_i31.UserProfileRepository>()));
    gh.lazySingleton<_i35.AudioCacheLocalDataSource>(
        () => _i35.AudioCacheLocalDataSourceImpl(
              gh<_i7.FirebaseStorage>(),
              gh<_i3.Directory>(),
            ));
    gh.lazySingleton<_i36.AudioCacheRepository>(() =>
        _i37.AudioCacheRepositoryImpl(gh<_i35.AudioCacheLocalDataSource>()));
    gh.lazySingleton<_i38.AudioCommentLocalDataSource>(
        () => _i38.IsarAudioCommentLocalDataSource(gh<_i10.Isar>()));
    gh.lazySingleton<_i39.AudioCommentRemoteDataSource>(() =>
        _i39.FirebaseAudioCommentRemoteDataSource(gh<_i6.FirebaseFirestore>()));
    gh.lazySingleton<_i40.AudioCommentRepository>(
        () => _i41.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i39.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i38.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i16.NetworkInfo>(),
            ));
    gh.lazySingleton<_i42.AudioTrackLocalDataSource>(
        () => _i42.IsarAudioTrackLocalDataSource(gh<_i10.Isar>()));
    gh.lazySingleton<_i43.AudioTrackRemoteDataSource>(
        () => _i43.AudioTrackRemoteDataSourceImpl(
              gh<_i6.FirebaseFirestore>(),
              gh<_i7.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i44.AudioTrackRepository>(
        () => _i45.AudioTrackRepositoryImpl(
              gh<_i43.AudioTrackRemoteDataSource>(),
              gh<_i42.AudioTrackLocalDataSource>(),
              gh<_i16.NetworkInfo>(),
            ));
    gh.lazySingleton<_i46.AuthLocalDataSource>(
        () => _i46.AuthLocalDataSourceImpl(gh<_i28.SharedPreferences>()));
    gh.lazySingleton<_i47.AuthRemoteDataSource>(
        () => _i47.AuthRemoteDataSourceImpl(
              gh<_i5.FirebaseAuth>(),
              gh<_i8.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i48.ConsumeMagicLinkUseCase>(
        () => _i48.ConsumeMagicLinkUseCase(gh<_i13.MagicLinkRepository>()));
    gh.lazySingleton<_i49.GetCachedAudioPath>(
        () => _i49.GetCachedAudioPath(gh<_i36.AudioCacheRepository>()));
    gh.lazySingleton<_i50.GetMagicLinkStatusUseCase>(
        () => _i50.GetMagicLinkStatusUseCase(gh<_i13.MagicLinkRepository>()));
    gh.lazySingleton<_i51.GetProjectByIdUseCase>(
        () => _i51.GetProjectByIdUseCase(gh<_i21.ProjectDetailRepository>()));
    gh.lazySingleton<_i52.ManageCollaboratorsLocalDataSource>(() =>
        _i52.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i24.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i53.ManageCollaboratorsRemoteDataSource>(() =>
        _i53.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i30.UserProfileRemoteDataSource>(),
          firestore: gh<_i6.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i54.ManageCollaboratorsRepository>(
        () => _i55.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i53.ManageCollaboratorsRemoteDataSource>(),
              localDataSourceManageCollaborators:
                  gh<_i52.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i16.NetworkInfo>(),
            ));
    gh.lazySingleton<_i56.ProjectCommentService>(
        () => _i56.ProjectCommentService(gh<_i40.AudioCommentRepository>()));
    gh.lazySingleton<_i57.ProjectTrackService>(
        () => _i57.ProjectTrackService(gh<_i44.AudioTrackRepository>()));
    gh.lazySingleton<_i58.SessionStorage>(
        () => _i58.SessionStorage(prefs: gh<_i28.SharedPreferences>()));
    gh.lazySingleton<_i59.SyncAudioCommentsUseCase>(
        () => _i59.SyncAudioCommentsUseCase(
              gh<_i39.AudioCommentRemoteDataSource>(),
              gh<_i38.AudioCommentLocalDataSource>(),
              gh<_i23.ProjectRemoteDataSource>(),
              gh<_i58.SessionStorage>(),
              gh<_i43.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i60.SyncAudioTracksUseCase>(
        () => _i60.SyncAudioTracksUseCase(
              gh<_i43.AudioTrackRemoteDataSource>(),
              gh<_i42.AudioTrackLocalDataSource>(),
              gh<_i23.ProjectRemoteDataSource>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i61.SyncProjectsUseCase>(() => _i61.SyncProjectsUseCase(
          gh<_i23.ProjectRemoteDataSource>(),
          gh<_i24.ProjectsLocalDataSource>(),
          gh<_i58.SessionStorage>(),
        ));
    gh.lazySingleton<_i62.SyncUserProfileCollaboratorsUseCase>(
        () => _i62.SyncUserProfileCollaboratorsUseCase(
              gh<_i24.ProjectsLocalDataSource>(),
              gh<_i31.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i63.SyncUserProfileUseCase>(
        () => _i63.SyncUserProfileUseCase(
              gh<_i30.UserProfileRemoteDataSource>(),
              gh<_i29.UserProfileLocalDataSource>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i64.UpdateCollaboratorRoleUseCase>(
        () => _i64.UpdateCollaboratorRoleUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i54.ManageCollaboratorsRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i65.UpdateProjectUseCase>(() => _i65.UpdateProjectUseCase(
          gh<_i25.ProjectsRepository>(),
          gh<_i58.SessionStorage>(),
        ));
    gh.factory<_i66.UpdateUserProfileUseCase>(
        () => _i66.UpdateUserProfileUseCase(
              gh<_i31.UserProfileRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i67.UploadAudioTrackUseCase>(
        () => _i67.UploadAudioTrackUseCase(
              gh<_i57.ProjectTrackService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i68.WatchAllProjectsUseCase>(
        () => _i68.WatchAllProjectsUseCase(
              gh<_i25.ProjectsRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i69.WatchCommentsByTrackUseCase>(() =>
        _i69.WatchCommentsByTrackUseCase(gh<_i56.ProjectCommentService>()));
    gh.lazySingleton<_i70.WatchProjectDetailUseCase>(
        () => _i70.WatchProjectDetailUseCase(
              gh<_i42.AudioTrackLocalDataSource>(),
              gh<_i29.UserProfileLocalDataSource>(),
              gh<_i38.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i71.WatchTracksByProjectIdUseCase>(() =>
        _i71.WatchTracksByProjectIdUseCase(gh<_i44.AudioTrackRepository>()));
    gh.lazySingleton<_i72.WatchUserProfileUseCase>(
        () => _i72.WatchUserProfileUseCase(
              gh<_i31.UserProfileRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i73.AddAudioCommentUseCase>(
        () => _i73.AddAudioCommentUseCase(
              gh<_i56.ProjectCommentService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i74.AddCollaboratorToProjectUseCase>(
        () => _i74.AddCollaboratorToProjectUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i54.ManageCollaboratorsRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.factory<_i75.AudioCacheCubit>(
        () => _i75.AudioCacheCubit(gh<_i49.GetCachedAudioPath>()));
    gh.factory<_i76.AudioSourceResolver>(
        () => _i77.AudioSourceResolverImpl(gh<_i49.GetCachedAudioPath>()));
    gh.lazySingleton<_i78.AuthRepository>(() => _i79.AuthRepositoryImpl(
          remote: gh<_i47.AuthRemoteDataSource>(),
          local: gh<_i46.AuthLocalDataSource>(),
          networkInfo: gh<_i16.NetworkInfo>(),
          firestore: gh<_i6.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i29.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i24.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i42.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i38.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i58.SessionStorage>(),
        ));
    gh.lazySingleton<_i80.CreateProjectUseCase>(() => _i80.CreateProjectUseCase(
          gh<_i25.ProjectsRepository>(),
          gh<_i58.SessionStorage>(),
        ));
    gh.lazySingleton<_i81.DeleteAudioCommentUseCase>(
        () => _i81.DeleteAudioCommentUseCase(
              gh<_i56.ProjectCommentService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i82.DeleteAudioTrack>(() => _i82.DeleteAudioTrack(
          gh<_i58.SessionStorage>(),
          gh<_i21.ProjectDetailRepository>(),
          gh<_i57.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i83.DeleteProjectUseCase>(() => _i83.DeleteProjectUseCase(
          gh<_i25.ProjectsRepository>(),
          gh<_i58.SessionStorage>(),
        ));
    gh.lazySingleton<_i84.EditAudioTrackUseCase>(
        () => _i84.EditAudioTrackUseCase(
              gh<_i57.ProjectTrackService>(),
              gh<_i21.ProjectDetailRepository>(),
            ));
    gh.lazySingleton<_i85.GenerateMagicLinkUseCase>(
        () => _i85.GenerateMagicLinkUseCase(
              gh<_i13.MagicLinkRepository>(),
              gh<_i78.AuthRepository>(),
            ));
    gh.lazySingleton<_i86.GetAuthStateUseCase>(
        () => _i86.GetAuthStateUseCase(gh<_i78.AuthRepository>()));
    gh.lazySingleton<_i87.GoogleSignInUseCase>(
        () => _i87.GoogleSignInUseCase(gh<_i78.AuthRepository>()));
    gh.lazySingleton<_i88.JoinProjectWithIdUseCase>(
        () => _i88.JoinProjectWithIdUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i54.ManageCollaboratorsRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i89.LeaveProjectUseCase>(() => _i89.LeaveProjectUseCase(
          gh<_i54.ManageCollaboratorsRepository>(),
          gh<_i58.SessionStorage>(),
        ));
    gh.factory<_i90.MagicLinkBloc>(() => _i90.MagicLinkBloc(
          generateMagicLink: gh<_i85.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i33.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i48.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i27.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i50.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i88.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i78.AuthRepository>(),
        ));
    gh.lazySingleton<_i91.OnboardingUseCase>(
        () => _i91.OnboardingUseCase(gh<_i78.AuthRepository>()));
    gh.factory<_i92.ProjectDetailBloc>(() => _i92.ProjectDetailBloc(
        watchProjectDetail: gh<_i70.WatchProjectDetailUseCase>()));
    gh.factory<_i93.ProjectsBloc>(() => _i93.ProjectsBloc(
          createProject: gh<_i80.CreateProjectUseCase>(),
          updateProject: gh<_i65.UpdateProjectUseCase>(),
          deleteProject: gh<_i83.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i68.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i94.RemoveCollaboratorUseCase>(
        () => _i94.RemoveCollaboratorUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i54.ManageCollaboratorsRepository>(),
              gh<_i58.SessionStorage>(),
            ));
    gh.lazySingleton<_i95.SignInUseCase>(
        () => _i95.SignInUseCase(gh<_i78.AuthRepository>()));
    gh.lazySingleton<_i96.SignOutUseCase>(
        () => _i96.SignOutUseCase(gh<_i78.AuthRepository>()));
    gh.lazySingleton<_i97.SignUpUseCase>(
        () => _i97.SignUpUseCase(gh<_i78.AuthRepository>()));
    gh.lazySingleton<_i98.StartupResourceManager>(
        () => _i98.StartupResourceManager(
              gh<_i59.SyncAudioCommentsUseCase>(),
              gh<_i60.SyncAudioTracksUseCase>(),
              gh<_i61.SyncProjectsUseCase>(),
              gh<_i63.SyncUserProfileUseCase>(),
              gh<_i62.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i99.UserProfileBloc>(() => _i99.UserProfileBloc(
          updateUserProfileUseCase: gh<_i66.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i72.WatchUserProfileUseCase>(),
        ));
    gh.lazySingleton<_i100.AddCollaboratorAndSyncProfileService>(
        () => _i100.AddCollaboratorAndSyncProfileService(
              gh<_i74.AddCollaboratorToProjectUseCase>(),
              gh<_i31.UserProfileRepository>(),
            ));
    gh.factory<_i101.AudioCommentBloc>(() => _i101.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i69.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i73.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i81.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i102.AudioPlayerBloc>(() => _i102.AudioPlayerBloc(
          gh<_i17.PlaybackService>(),
          gh<_i49.GetCachedAudioPath>(),
          gh<_i44.AudioTrackRepository>(),
          gh<_i31.UserProfileRepository>(),
          gh<_i76.AudioSourceResolver>(),
          gh<_i18.PlaybackStatePersistence>(),
        ));
    gh.factory<_i103.AudioTrackBloc>(() => _i103.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i71.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i82.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i67.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i84.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i104.AuthBloc>(() => _i104.AuthBloc(
          signIn: gh<_i95.SignInUseCase>(),
          signUp: gh<_i97.SignUpUseCase>(),
          signOut: gh<_i96.SignOutUseCase>(),
          googleSignIn: gh<_i87.GoogleSignInUseCase>(),
          getAuthState: gh<_i86.GetAuthStateUseCase>(),
          onboarding: gh<_i91.OnboardingUseCase>(),
        ));
    gh.factory<_i105.ManageCollaboratorsBloc>(
        () => _i105.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i100.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i94.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i64.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i89.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i34.WatchUserProfilesUseCase>(),
            ));
    return this;
  }
}

class _$AppModule extends _i106.AppModule {}
