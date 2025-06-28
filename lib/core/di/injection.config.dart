// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i4;

import 'package:cloud_firestore/cloud_firestore.dart' as _i7;
import 'package:connectivity_plus/connectivity_plus.dart' as _i3;
import 'package:firebase_auth/firebase_auth.dart' as _i6;
import 'package:firebase_storage/firebase_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i10;
import 'package:isar/isar.dart' as _i11;
import 'package:shared_preferences/shared_preferences.dart' as _i30;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i124;
import 'package:trackflow/core/di/app_module.dart' as _i140;
import 'package:trackflow/core/network/network_info.dart' as _i17;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i5;
import 'package:trackflow/core/session/session_storage.dart' as _i76;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i98;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i136;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_metadata_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i52;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i53;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_metadata_repository_impl.dart'
    as _i51;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_storage_repository_impl.dart'
    as _i55;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_metadata_repository.dart'
    as _i50;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart'
    as _i54;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_download_management_service.dart'
    as _i57;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_storage_management_service.dart'
    as _i59;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/cache_orchestration_service_impl.dart'
    as _i97;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_download_management_service_impl.dart'
    as _i58;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_storage_management_service_impl.dart'
    as _i60;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i99;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i125;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i39;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i40;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i42;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i41;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i92;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i102;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i78;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i88;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i128;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i129;
import 'package:trackflow/features/audio_player/domain/services/offline_mode_service.dart'
    as _i67;
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart'
    as _i18;
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart'
    as _i70;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i134;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i74;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i28;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i75;
import 'package:trackflow/features/audio_player/domain/usecases/seek_to_position_usecase.dart'
    as _i29;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i137;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i138;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i77;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i31;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i32;
import 'package:trackflow/features/audio_player/infrastructure/audio_source_resolver_impl.dart'
    as _i130;
import 'package:trackflow/features/audio_player/infrastructure/offline_mode_service_impl.dart'
    as _i68;
import 'package:trackflow/features/audio_player/infrastructure/playback_service_impl.dart'
    as _i19;
import 'package:trackflow/features/audio_player/infrastructure/playback_state_persistence_impl.dart'
    as _i71;
import 'package:trackflow/features/audio_player/presentation/bloc/audioplayer_bloc.dart'
    as _i139;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i43;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i44;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i46;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i45;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i73;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i105;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i79;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i86;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i90;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i131;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i47;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i48;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i95;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i94;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i107;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i111;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i115;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i121;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i122;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i123;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i132;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i12;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i13;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i15;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i14;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i56;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i106;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i61;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i37;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i114;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i63;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i64;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i66;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i65;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i127;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i93;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i112;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i113;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i118;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i83;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i38;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i133;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i16;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i20;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i22;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i21;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i62;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i89;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i116;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i24;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i23;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i26;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i25;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i101;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i104;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i80;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i84;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i87;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i117;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i33;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i34;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i36;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i35;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i81;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i82;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i85;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i91;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i126;

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
    gh.lazySingleton<_i3.Connectivity>(() => appModule.connectivity);
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
    gh.lazySingleton<_i18.PlaybackService>(() => _i19.PlaybackServiceImpl());
    gh.lazySingleton<_i20.ProjectDetailRemoteDataSource>(() =>
        _i20.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i21.ProjectDetailRepository>(
        () => _i22.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i20.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i23.ProjectRemoteDataSource>(() =>
        _i23.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i24.ProjectsLocalDataSource>(
        () => _i24.ProjectsLocalDataSourceImpl(gh<_i11.Isar>()));
    gh.lazySingleton<_i25.ProjectsRepository>(() => _i26.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i23.ProjectRemoteDataSource>(),
          localDataSource: gh<_i24.ProjectsLocalDataSource>(),
          networkInfo: gh<_i17.NetworkInfo>(),
        ));
    gh.lazySingleton<_i27.ResendMagicLinkUseCase>(
        () => _i27.ResendMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i28.ResumeAudioUseCase>(
        () => _i28.ResumeAudioUseCase(gh<_i18.PlaybackService>()));
    gh.lazySingleton<_i29.SeekToPositionUseCase>(
        () => _i29.SeekToPositionUseCase(gh<_i18.PlaybackService>()));
    await gh.factoryAsync<_i30.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i31.ToggleRepeatModeUseCase>(
        () => _i31.ToggleRepeatModeUseCase());
    gh.lazySingleton<_i32.ToggleShuffleUseCase>(
        () => _i32.ToggleShuffleUseCase());
    gh.lazySingleton<_i33.UserProfileLocalDataSource>(
        () => _i33.IsarUserProfileLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i34.UserProfileRemoteDataSource>(
        () => _i34.UserProfileRemoteDataSourceImpl(
              gh<_i7.FirebaseFirestore>(),
              gh<_i8.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i35.UserProfileRepository>(
        () => _i36.UserProfileRepositoryImpl(
              gh<_i34.UserProfileRemoteDataSource>(),
              gh<_i33.UserProfileLocalDataSource>(),
              gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i37.ValidateMagicLinkUseCase>(
        () => _i37.ValidateMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i38.WatchUserProfilesUseCase>(
        () => _i38.WatchUserProfilesUseCase(gh<_i35.UserProfileRepository>()));
    gh.lazySingleton<_i39.AudioCommentLocalDataSource>(
        () => _i39.IsarAudioCommentLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i40.AudioCommentRemoteDataSource>(() =>
        _i40.FirebaseAudioCommentRemoteDataSource(gh<_i7.FirebaseFirestore>()));
    gh.lazySingleton<_i41.AudioCommentRepository>(
        () => _i42.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i40.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i39.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i43.AudioTrackLocalDataSource>(
        () => _i43.IsarAudioTrackLocalDataSource(gh<_i11.Isar>()));
    gh.lazySingleton<_i44.AudioTrackRemoteDataSource>(
        () => _i44.AudioTrackRemoteDataSourceImpl(
              gh<_i7.FirebaseFirestore>(),
              gh<_i8.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i45.AudioTrackRepository>(
        () => _i46.AudioTrackRepositoryImpl(
              gh<_i44.AudioTrackRemoteDataSource>(),
              gh<_i43.AudioTrackLocalDataSource>(),
              gh<_i17.NetworkInfo>(),
            ));
    gh.lazySingleton<_i47.AuthLocalDataSource>(
        () => _i47.AuthLocalDataSourceImpl(gh<_i30.SharedPreferences>()));
    gh.lazySingleton<_i48.AuthRemoteDataSource>(
        () => _i48.AuthRemoteDataSourceImpl(
              gh<_i6.FirebaseAuth>(),
              gh<_i9.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i49.CacheMetadataLocalDataSource>(
        () => _i49.CacheMetadataLocalDataSourceImpl(gh<_i11.Isar>()));
    gh.lazySingleton<_i50.CacheMetadataRepository>(() =>
        _i51.CacheMetadataRepositoryImpl(
            localDataSource: gh<_i49.CacheMetadataLocalDataSource>()));
    gh.lazySingleton<_i52.CacheStorageLocalDataSource>(
        () => _i52.CacheStorageLocalDataSourceImpl(gh<_i11.Isar>()));
    gh.lazySingleton<_i53.CacheStorageRemoteDataSource>(
        () => _i53.CacheStorageRemoteDataSourceImpl(gh<_i8.FirebaseStorage>()));
    gh.lazySingleton<_i54.CacheStorageRepository>(
        () => _i55.CacheStorageRepositoryImpl(
              localDataSource: gh<_i52.CacheStorageLocalDataSource>(),
              remoteDataSource: gh<_i53.CacheStorageRemoteDataSource>(),
            ));
    gh.lazySingleton<_i56.ConsumeMagicLinkUseCase>(
        () => _i56.ConsumeMagicLinkUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i57.EnhancedDownloadManagementService>(() =>
        _i58.EnhancedDownloadManagementServiceImpl(
            storageRepository: gh<_i54.CacheStorageRepository>()));
    gh.lazySingleton<_i59.EnhancedStorageManagementService>(
        () => _i60.EnhancedStorageManagementServiceImpl(
              storageRepository: gh<_i54.CacheStorageRepository>(),
              metadataRepository: gh<_i50.CacheMetadataRepository>(),
            ));
    gh.lazySingleton<_i61.GetMagicLinkStatusUseCase>(
        () => _i61.GetMagicLinkStatusUseCase(gh<_i14.MagicLinkRepository>()));
    gh.lazySingleton<_i62.GetProjectByIdUseCase>(
        () => _i62.GetProjectByIdUseCase(gh<_i21.ProjectDetailRepository>()));
    gh.lazySingleton<_i63.ManageCollaboratorsLocalDataSource>(() =>
        _i63.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i24.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i64.ManageCollaboratorsRemoteDataSource>(() =>
        _i64.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i34.UserProfileRemoteDataSource>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i65.ManageCollaboratorsRepository>(
        () => _i66.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i64.ManageCollaboratorsRemoteDataSource>(),
              localDataSourceManageCollaborators:
                  gh<_i63.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i17.NetworkInfo>(),
            ));
    gh.factory<_i67.OfflineModeService>(() => _i68.OfflineModeServiceImpl(
          gh<_i3.Connectivity>(),
          gh<_i30.SharedPreferences>(),
        ));
    gh.lazySingleton<_i69.PauseAudioUseCase>(
        () => _i69.PauseAudioUseCase(gh<_i18.PlaybackService>()));
    gh.factory<_i70.PlaybackStatePersistence>(
        () => _i71.PlaybackStatePersistenceImpl(gh<_i30.SharedPreferences>()));
    gh.lazySingleton<_i72.ProjectCommentService>(
        () => _i72.ProjectCommentService(gh<_i41.AudioCommentRepository>()));
    gh.lazySingleton<_i73.ProjectTrackService>(
        () => _i73.ProjectTrackService(gh<_i45.AudioTrackRepository>()));
    gh.lazySingleton<_i74.RestorePlaybackStateUseCase>(
        () => _i74.RestorePlaybackStateUseCase(
              gh<_i70.PlaybackStatePersistence>(),
              gh<_i18.PlaybackService>(),
              gh<_i45.AudioTrackRepository>(),
              gh<_i35.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i75.SavePlaybackStateUseCase>(() =>
        _i75.SavePlaybackStateUseCase(gh<_i70.PlaybackStatePersistence>()));
    gh.lazySingleton<_i76.SessionStorage>(
        () => _i76.SessionStorage(prefs: gh<_i30.SharedPreferences>()));
    gh.lazySingleton<_i77.StopAudioUseCase>(() => _i77.StopAudioUseCase(
          gh<_i18.PlaybackService>(),
          gh<_i70.PlaybackStatePersistence>(),
        ));
    gh.lazySingleton<_i78.SyncAudioCommentsUseCase>(
        () => _i78.SyncAudioCommentsUseCase(
              gh<_i40.AudioCommentRemoteDataSource>(),
              gh<_i39.AudioCommentLocalDataSource>(),
              gh<_i23.ProjectRemoteDataSource>(),
              gh<_i76.SessionStorage>(),
              gh<_i44.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i79.SyncAudioTracksUseCase>(
        () => _i79.SyncAudioTracksUseCase(
              gh<_i44.AudioTrackRemoteDataSource>(),
              gh<_i43.AudioTrackLocalDataSource>(),
              gh<_i23.ProjectRemoteDataSource>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i80.SyncProjectsUseCase>(() => _i80.SyncProjectsUseCase(
          gh<_i23.ProjectRemoteDataSource>(),
          gh<_i24.ProjectsLocalDataSource>(),
          gh<_i76.SessionStorage>(),
        ));
    gh.lazySingleton<_i81.SyncUserProfileCollaboratorsUseCase>(
        () => _i81.SyncUserProfileCollaboratorsUseCase(
              gh<_i24.ProjectsLocalDataSource>(),
              gh<_i35.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i82.SyncUserProfileUseCase>(
        () => _i82.SyncUserProfileUseCase(
              gh<_i34.UserProfileRemoteDataSource>(),
              gh<_i33.UserProfileLocalDataSource>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i83.UpdateCollaboratorRoleUseCase>(
        () => _i83.UpdateCollaboratorRoleUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i65.ManageCollaboratorsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i84.UpdateProjectUseCase>(() => _i84.UpdateProjectUseCase(
          gh<_i25.ProjectsRepository>(),
          gh<_i76.SessionStorage>(),
        ));
    gh.factory<_i85.UpdateUserProfileUseCase>(
        () => _i85.UpdateUserProfileUseCase(
              gh<_i35.UserProfileRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i86.UploadAudioTrackUseCase>(
        () => _i86.UploadAudioTrackUseCase(
              gh<_i73.ProjectTrackService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i87.WatchAllProjectsUseCase>(
        () => _i87.WatchAllProjectsUseCase(
              gh<_i25.ProjectsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i88.WatchCommentsByTrackUseCase>(() =>
        _i88.WatchCommentsByTrackUseCase(gh<_i72.ProjectCommentService>()));
    gh.lazySingleton<_i89.WatchProjectDetailUseCase>(
        () => _i89.WatchProjectDetailUseCase(
              gh<_i43.AudioTrackLocalDataSource>(),
              gh<_i33.UserProfileLocalDataSource>(),
              gh<_i39.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i90.WatchTracksByProjectIdUseCase>(() =>
        _i90.WatchTracksByProjectIdUseCase(gh<_i45.AudioTrackRepository>()));
    gh.lazySingleton<_i91.WatchUserProfileUseCase>(
        () => _i91.WatchUserProfileUseCase(
              gh<_i35.UserProfileRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i92.AddAudioCommentUseCase>(
        () => _i92.AddAudioCommentUseCase(
              gh<_i72.ProjectCommentService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i93.AddCollaboratorToProjectUseCase>(
        () => _i93.AddCollaboratorToProjectUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i65.ManageCollaboratorsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i94.AuthRepository>(() => _i95.AuthRepositoryImpl(
          remote: gh<_i48.AuthRemoteDataSource>(),
          local: gh<_i47.AuthLocalDataSource>(),
          networkInfo: gh<_i17.NetworkInfo>(),
          firestore: gh<_i7.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i33.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i24.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i43.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i39.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i76.SessionStorage>(),
        ));
    gh.lazySingleton<_i96.CacheOrchestrationService>(
        () => _i97.CacheOrchestrationServiceImpl(
              metadataRepository: gh<_i50.CacheMetadataRepository>(),
              storageRepository: gh<_i54.CacheStorageRepository>(),
            ));
    gh.factory<_i98.CachePlaylistUseCase>(
        () => _i98.CachePlaylistUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.factory<_i99.CacheTrackUseCase>(
        () => _i99.CacheTrackUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.factory<_i100.CleanupCacheUseCase>(
        () => _i100.CleanupCacheUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.lazySingleton<_i101.CreateProjectUseCase>(
        () => _i101.CreateProjectUseCase(
              gh<_i25.ProjectsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i102.DeleteAudioCommentUseCase>(
        () => _i102.DeleteAudioCommentUseCase(
              gh<_i72.ProjectCommentService>(),
              gh<_i21.ProjectDetailRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i103.DeleteAudioTrack>(() => _i103.DeleteAudioTrack(
          gh<_i76.SessionStorage>(),
          gh<_i21.ProjectDetailRepository>(),
          gh<_i73.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i104.DeleteProjectUseCase>(
        () => _i104.DeleteProjectUseCase(
              gh<_i25.ProjectsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i105.EditAudioTrackUseCase>(
        () => _i105.EditAudioTrackUseCase(
              gh<_i73.ProjectTrackService>(),
              gh<_i21.ProjectDetailRepository>(),
            ));
    gh.lazySingleton<_i106.GenerateMagicLinkUseCase>(
        () => _i106.GenerateMagicLinkUseCase(
              gh<_i14.MagicLinkRepository>(),
              gh<_i94.AuthRepository>(),
            ));
    gh.lazySingleton<_i107.GetAuthStateUseCase>(
        () => _i107.GetAuthStateUseCase(gh<_i94.AuthRepository>()));
    gh.factory<_i108.GetCacheStorageStatsUseCase>(() =>
        _i108.GetCacheStorageStatsUseCase(
            gh<_i96.CacheOrchestrationService>()));
    gh.factory<_i109.GetPlaylistCacheStatusUseCase>(() =>
        _i109.GetPlaylistCacheStatusUseCase(
            gh<_i96.CacheOrchestrationService>()));
    gh.factory<_i110.GetTrackCacheStatusUseCase>(() =>
        _i110.GetTrackCacheStatusUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.lazySingleton<_i111.GoogleSignInUseCase>(
        () => _i111.GoogleSignInUseCase(gh<_i94.AuthRepository>()));
    gh.lazySingleton<_i112.JoinProjectWithIdUseCase>(
        () => _i112.JoinProjectWithIdUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i65.ManageCollaboratorsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.lazySingleton<_i113.LeaveProjectUseCase>(() => _i113.LeaveProjectUseCase(
          gh<_i65.ManageCollaboratorsRepository>(),
          gh<_i76.SessionStorage>(),
        ));
    gh.factory<_i114.MagicLinkBloc>(() => _i114.MagicLinkBloc(
          generateMagicLink: gh<_i106.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i37.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i56.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i27.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i61.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i112.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i94.AuthRepository>(),
        ));
    gh.lazySingleton<_i115.OnboardingUseCase>(
        () => _i115.OnboardingUseCase(gh<_i94.AuthRepository>()));
    gh.factory<_i116.ProjectDetailBloc>(() => _i116.ProjectDetailBloc(
        watchProjectDetail: gh<_i89.WatchProjectDetailUseCase>()));
    gh.factory<_i117.ProjectsBloc>(() => _i117.ProjectsBloc(
          createProject: gh<_i101.CreateProjectUseCase>(),
          updateProject: gh<_i84.UpdateProjectUseCase>(),
          deleteProject: gh<_i104.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i87.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i118.RemoveCollaboratorUseCase>(
        () => _i118.RemoveCollaboratorUseCase(
              gh<_i21.ProjectDetailRepository>(),
              gh<_i65.ManageCollaboratorsRepository>(),
              gh<_i76.SessionStorage>(),
            ));
    gh.factory<_i119.RemovePlaylistCacheUseCase>(() =>
        _i119.RemovePlaylistCacheUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.factory<_i120.RemoveTrackCacheUseCase>(() =>
        _i120.RemoveTrackCacheUseCase(gh<_i96.CacheOrchestrationService>()));
    gh.lazySingleton<_i121.SignInUseCase>(
        () => _i121.SignInUseCase(gh<_i94.AuthRepository>()));
    gh.lazySingleton<_i122.SignOutUseCase>(
        () => _i122.SignOutUseCase(gh<_i94.AuthRepository>()));
    gh.lazySingleton<_i123.SignUpUseCase>(
        () => _i123.SignUpUseCase(gh<_i94.AuthRepository>()));
    gh.lazySingleton<_i124.StartupResourceManager>(
        () => _i124.StartupResourceManager(
              gh<_i78.SyncAudioCommentsUseCase>(),
              gh<_i79.SyncAudioTracksUseCase>(),
              gh<_i80.SyncProjectsUseCase>(),
              gh<_i82.SyncUserProfileUseCase>(),
              gh<_i81.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i125.TrackCacheBloc>(() => _i125.TrackCacheBloc(
          gh<_i99.CacheTrackUseCase>(),
          gh<_i110.GetTrackCacheStatusUseCase>(),
          gh<_i120.RemoveTrackCacheUseCase>(),
        ));
    gh.factory<_i126.UserProfileBloc>(() => _i126.UserProfileBloc(
          updateUserProfileUseCase: gh<_i85.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i91.WatchUserProfileUseCase>(),
        ));
    gh.lazySingleton<_i127.AddCollaboratorAndSyncProfileService>(
        () => _i127.AddCollaboratorAndSyncProfileService(
              gh<_i93.AddCollaboratorToProjectUseCase>(),
              gh<_i35.UserProfileRepository>(),
            ));
    gh.factory<_i128.AudioCommentBloc>(() => _i128.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i88.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i92.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i102.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i129.AudioSourceResolver>(() => _i130.AudioSourceResolverImpl(
          gh<_i96.CacheOrchestrationService>(),
          gh<_i67.OfflineModeService>(),
        ));
    gh.factory<_i131.AudioTrackBloc>(() => _i131.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i90.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i103.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i86.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i105.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i132.AuthBloc>(() => _i132.AuthBloc(
          signIn: gh<_i121.SignInUseCase>(),
          signUp: gh<_i123.SignUpUseCase>(),
          signOut: gh<_i122.SignOutUseCase>(),
          googleSignIn: gh<_i111.GoogleSignInUseCase>(),
          getAuthState: gh<_i107.GetAuthStateUseCase>(),
          onboarding: gh<_i115.OnboardingUseCase>(),
        ));
    gh.factory<_i133.ManageCollaboratorsBloc>(
        () => _i133.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i127.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i118.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i83.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i113.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i38.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i134.PlayAudioUseCase>(() => _i134.PlayAudioUseCase(
          gh<_i18.PlaybackService>(),
          gh<_i35.UserProfileRepository>(),
          gh<_i129.AudioSourceResolver>(),
        ));
    gh.lazySingleton<_i135.PlayPlaylistUseCase>(() => _i135.PlayPlaylistUseCase(
          gh<_i18.PlaybackService>(),
          gh<_i45.AudioTrackRepository>(),
          gh<_i35.UserProfileRepository>(),
          gh<_i129.AudioSourceResolver>(),
        ));
    gh.factory<_i136.PlaylistCacheBloc>(() => _i136.PlaylistCacheBloc(
          gh<_i98.CachePlaylistUseCase>(),
          gh<_i109.GetPlaylistCacheStatusUseCase>(),
          gh<_i119.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i137.SkipToNextUseCase>(() => _i137.SkipToNextUseCase(
          gh<_i18.PlaybackService>(),
          gh<_i45.AudioTrackRepository>(),
          gh<_i35.UserProfileRepository>(),
          gh<_i129.AudioSourceResolver>(),
        ));
    gh.lazySingleton<_i138.SkipToPreviousUseCase>(
        () => _i138.SkipToPreviousUseCase(
              gh<_i18.PlaybackService>(),
              gh<_i45.AudioTrackRepository>(),
              gh<_i35.UserProfileRepository>(),
              gh<_i129.AudioSourceResolver>(),
            ));
    gh.factory<_i139.AudioPlayerBloc>(() => _i139.AudioPlayerBloc(
          gh<_i18.PlaybackService>(),
          gh<_i134.PlayAudioUseCase>(),
          gh<_i69.PauseAudioUseCase>(),
          gh<_i28.ResumeAudioUseCase>(),
          gh<_i77.StopAudioUseCase>(),
          gh<_i135.PlayPlaylistUseCase>(),
          gh<_i137.SkipToNextUseCase>(),
          gh<_i138.SkipToPreviousUseCase>(),
          gh<_i32.ToggleShuffleUseCase>(),
          gh<_i31.ToggleRepeatModeUseCase>(),
          gh<_i29.SeekToPositionUseCase>(),
          gh<_i75.SavePlaybackStateUseCase>(),
          gh<_i74.RestorePlaybackStateUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i140.AppModule {}
