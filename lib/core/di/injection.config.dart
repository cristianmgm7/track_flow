// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i9;

import 'package:cloud_firestore/cloud_firestore.dart' as _i12;
import 'package:connectivity_plus/connectivity_plus.dart' as _i8;
import 'package:firebase_auth/firebase_auth.dart' as _i11;
import 'package:firebase_storage/firebase_storage.dart' as _i13;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i15;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i17;
import 'package:isar/isar.dart' as _i18;
import 'package:shared_preferences/shared_preferences.dart' as _i41;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i123;
import 'package:trackflow/core/di/app_module.dart' as _i136;
import 'package:trackflow/core/network/network_info.dart' as _i24;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i10;
import 'package:trackflow/core/session/session_storage.dart' as _i81;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i79;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i116;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i63;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i64;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_storage_repository_impl.dart'
    as _i66;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart'
    as _i65;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i5;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i14;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart'
    as _i72;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i80;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i87;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i53;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i54;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i55;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i77;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i97;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i105;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i82;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i93;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i126;
import 'package:trackflow/features/audio_player/domain/repositories/audio_content_repository.dart'
    as _i127;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i26;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i99;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i25;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i132;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i133;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i134;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i36;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i37;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/infrastructure/repositories/audio_content_repository_impl.dart'
    as _i128;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i27;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i100;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i135;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i57;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i58;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i60;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i59;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i78;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i106;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i83;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i91;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i95;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i129;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i61;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i62;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i102;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i101;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i110;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i111;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i115;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i120;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i121;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i122;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i130;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i19;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i20;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i22;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i21;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i109;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i69;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i35;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i51;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i114;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i76;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i75;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i125;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i98;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i112;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i113;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i119;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i88;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i52;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i131;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i23;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i28;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i30;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i29;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i71;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i94;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i117;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i32;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i31;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i34;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i33;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i104;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i107;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i84;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i92;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i118;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i47;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i48;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i50;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i49;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i85;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i86;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i90;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i96;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i124;

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
    gh.lazySingleton<_i3.AudioPlaybackService>(
        () => _i4.AudioPlaybackServiceImpl());
    gh.lazySingleton<_i5.CacheMaintenanceService>(
        () => _i6.CacheMaintenanceServiceImpl());
    gh.factory<_i7.CleanupCacheUseCase>(
        () => _i7.CleanupCacheUseCase(gh<_i5.CacheMaintenanceService>()));
    gh.lazySingleton<_i8.Connectivity>(() => appModule.connectivity);
    await gh.factoryAsync<_i9.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i10.DynamicLinkService>(() => _i10.DynamicLinkService());
    gh.lazySingleton<_i11.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i12.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i13.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i14.GetCacheStorageStatsUseCase>(() =>
        _i14.GetCacheStorageStatsUseCase(gh<_i5.CacheMaintenanceService>()));
    gh.lazySingleton<_i15.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i16.InitializeAudioPlayerUseCase>(() =>
        _i16.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i17.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i18.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i19.MagicLinkLocalDataSource>(
        () => _i19.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i20.MagicLinkRemoteDataSource>(() =>
        _i20.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i12.FirebaseFirestore>()));
    gh.factory<_i21.MagicLinkRepository>(() =>
        _i22.MagicLinkRepositoryImp(gh<_i20.MagicLinkRemoteDataSource>()));
    gh.factory<_i23.NavigationCubit>(() => _i23.NavigationCubit());
    gh.lazySingleton<_i24.NetworkInfo>(
        () => _i24.NetworkInfoImpl(gh<_i17.InternetConnectionChecker>()));
    gh.factory<_i25.PauseAudioUseCase>(() => _i25.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i26.PlaybackPersistenceRepository>(
        () => _i27.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i28.ProjectDetailRemoteDataSource>(() =>
        _i28.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i12.FirebaseFirestore>()));
    gh.lazySingleton<_i29.ProjectDetailRepository>(
        () => _i30.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i28.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i24.NetworkInfo>(),
            ));
    gh.lazySingleton<_i31.ProjectRemoteDataSource>(() =>
        _i31.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i12.FirebaseFirestore>()));
    gh.lazySingleton<_i32.ProjectsLocalDataSource>(
        () => _i32.ProjectsLocalDataSourceImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i33.ProjectsRepository>(() => _i34.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i31.ProjectRemoteDataSource>(),
          localDataSource: gh<_i32.ProjectsLocalDataSource>(),
          networkInfo: gh<_i24.NetworkInfo>(),
        ));
    gh.lazySingleton<_i35.ResendMagicLinkUseCase>(
        () => _i35.ResendMagicLinkUseCase(gh<_i21.MagicLinkRepository>()));
    gh.factory<_i36.ResumeAudioUseCase>(() => _i36.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i37.SavePlaybackStateUseCase>(
        () => _i37.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i26.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i38.SeekAudioUseCase>(() =>
        _i38.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i39.SetPlaybackSpeedUseCase>(() => _i39.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i40.SetVolumeUseCase>(() =>
        _i40.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i41.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i42.SkipToNextUseCase>(() => _i42.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i43.SkipToPreviousUseCase>(() => _i43.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i44.StopAudioUseCase>(() =>
        _i44.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i45.ToggleRepeatModeUseCase>(() => _i45.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i46.ToggleShuffleUseCase>(() => _i46.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i47.UserProfileLocalDataSource>(
        () => _i47.IsarUserProfileLocalDataSource(gh<_i18.Isar>()));
    gh.lazySingleton<_i48.UserProfileRemoteDataSource>(
        () => _i48.UserProfileRemoteDataSourceImpl(
              gh<_i12.FirebaseFirestore>(),
              gh<_i13.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i49.UserProfileRepository>(
        () => _i50.UserProfileRepositoryImpl(
              gh<_i48.UserProfileRemoteDataSource>(),
              gh<_i47.UserProfileLocalDataSource>(),
              gh<_i24.NetworkInfo>(),
            ));
    gh.lazySingleton<_i51.ValidateMagicLinkUseCase>(
        () => _i51.ValidateMagicLinkUseCase(gh<_i21.MagicLinkRepository>()));
    gh.lazySingleton<_i52.WatchUserProfilesUseCase>(
        () => _i52.WatchUserProfilesUseCase(gh<_i49.UserProfileRepository>()));
    gh.lazySingleton<_i53.AudioCommentLocalDataSource>(
        () => _i53.IsarAudioCommentLocalDataSource(gh<_i18.Isar>()));
    gh.lazySingleton<_i54.AudioCommentRemoteDataSource>(() =>
        _i54.FirebaseAudioCommentRemoteDataSource(
            gh<_i12.FirebaseFirestore>()));
    gh.lazySingleton<_i55.AudioCommentRepository>(
        () => _i56.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i54.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i53.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i24.NetworkInfo>(),
            ));
    gh.lazySingleton<_i57.AudioTrackLocalDataSource>(
        () => _i57.IsarAudioTrackLocalDataSource(gh<_i18.Isar>()));
    gh.lazySingleton<_i58.AudioTrackRemoteDataSource>(
        () => _i58.AudioTrackRemoteDataSourceImpl(
              gh<_i12.FirebaseFirestore>(),
              gh<_i13.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i59.AudioTrackRepository>(
        () => _i60.AudioTrackRepositoryImpl(
              gh<_i58.AudioTrackRemoteDataSource>(),
              gh<_i57.AudioTrackLocalDataSource>(),
              gh<_i24.NetworkInfo>(),
            ));
    gh.lazySingleton<_i61.AuthLocalDataSource>(
        () => _i61.AuthLocalDataSourceImpl(gh<_i41.SharedPreferences>()));
    gh.lazySingleton<_i62.AuthRemoteDataSource>(
        () => _i62.AuthRemoteDataSourceImpl(
              gh<_i11.FirebaseAuth>(),
              gh<_i15.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i63.CacheStorageLocalDataSource>(
        () => _i63.CacheStorageLocalDataSourceImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i64.CacheStorageRemoteDataSource>(() =>
        _i64.CacheStorageRemoteDataSourceImpl(gh<_i13.FirebaseStorage>()));
    gh.lazySingleton<_i65.CacheStorageRepository>(
        () => _i66.CacheStorageRepositoryImpl(
              localDataSource: gh<_i63.CacheStorageLocalDataSource>(),
              remoteDataSource: gh<_i64.CacheStorageRemoteDataSource>(),
            ));
    gh.factory<_i67.CacheTrackUseCase>(
        () => _i67.CacheTrackUseCase(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i68.ConsumeMagicLinkUseCase>(
        () => _i68.ConsumeMagicLinkUseCase(gh<_i21.MagicLinkRepository>()));
    gh.lazySingleton<_i69.GetMagicLinkStatusUseCase>(
        () => _i69.GetMagicLinkStatusUseCase(gh<_i21.MagicLinkRepository>()));
    gh.factory<_i70.GetPlaylistCacheStatusUseCase>(() =>
        _i70.GetPlaylistCacheStatusUseCase(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i71.GetProjectByIdUseCase>(
        () => _i71.GetProjectByIdUseCase(gh<_i29.ProjectDetailRepository>()));
    gh.factory<_i72.GetTrackCacheStatusUseCase>(() =>
        _i72.GetTrackCacheStatusUseCase(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i73.ManageCollaboratorsLocalDataSource>(() =>
        _i73.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i32.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i74.ManageCollaboratorsRemoteDataSource>(() =>
        _i74.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i48.UserProfileRemoteDataSource>(),
          firestore: gh<_i12.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i75.ManageCollaboratorsRepository>(
        () => _i76.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i74.ManageCollaboratorsRemoteDataSource>(),
              localDataSourceManageCollaborators:
                  gh<_i73.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i24.NetworkInfo>(),
            ));
    gh.lazySingleton<_i77.ProjectCommentService>(
        () => _i77.ProjectCommentService(gh<_i55.AudioCommentRepository>()));
    gh.lazySingleton<_i78.ProjectTrackService>(
        () => _i78.ProjectTrackService(gh<_i59.AudioTrackRepository>()));
    gh.factory<_i79.RemovePlaylistCacheUseCase>(() =>
        _i79.RemovePlaylistCacheUseCase(gh<_i65.CacheStorageRepository>()));
    gh.factory<_i80.RemoveTrackCacheUseCase>(
        () => _i80.RemoveTrackCacheUseCase(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i81.SessionStorage>(
        () => _i81.SessionStorage(prefs: gh<_i41.SharedPreferences>()));
    gh.lazySingleton<_i82.SyncAudioCommentsUseCase>(
        () => _i82.SyncAudioCommentsUseCase(
              gh<_i54.AudioCommentRemoteDataSource>(),
              gh<_i53.AudioCommentLocalDataSource>(),
              gh<_i31.ProjectRemoteDataSource>(),
              gh<_i81.SessionStorage>(),
              gh<_i58.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i83.SyncAudioTracksUseCase>(
        () => _i83.SyncAudioTracksUseCase(
              gh<_i58.AudioTrackRemoteDataSource>(),
              gh<_i57.AudioTrackLocalDataSource>(),
              gh<_i31.ProjectRemoteDataSource>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i84.SyncProjectsUseCase>(() => _i84.SyncProjectsUseCase(
          gh<_i31.ProjectRemoteDataSource>(),
          gh<_i32.ProjectsLocalDataSource>(),
          gh<_i81.SessionStorage>(),
        ));
    gh.lazySingleton<_i85.SyncUserProfileCollaboratorsUseCase>(
        () => _i85.SyncUserProfileCollaboratorsUseCase(
              gh<_i32.ProjectsLocalDataSource>(),
              gh<_i49.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i86.SyncUserProfileUseCase>(
        () => _i86.SyncUserProfileUseCase(
              gh<_i48.UserProfileRemoteDataSource>(),
              gh<_i47.UserProfileLocalDataSource>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.factory<_i87.TrackCacheBloc>(() => _i87.TrackCacheBloc(
          cacheTrackUseCase: gh<_i67.CacheTrackUseCase>(),
          getTrackCacheStatusUseCase: gh<_i72.GetTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i80.RemoveTrackCacheUseCase>(),
        ));
    gh.lazySingleton<_i88.UpdateCollaboratorRoleUseCase>(
        () => _i88.UpdateCollaboratorRoleUseCase(
              gh<_i29.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i89.UpdateProjectUseCase>(() => _i89.UpdateProjectUseCase(
          gh<_i33.ProjectsRepository>(),
          gh<_i81.SessionStorage>(),
        ));
    gh.factory<_i90.UpdateUserProfileUseCase>(
        () => _i90.UpdateUserProfileUseCase(
              gh<_i49.UserProfileRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i91.UploadAudioTrackUseCase>(
        () => _i91.UploadAudioTrackUseCase(
              gh<_i78.ProjectTrackService>(),
              gh<_i29.ProjectDetailRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i92.WatchAllProjectsUseCase>(
        () => _i92.WatchAllProjectsUseCase(
              gh<_i33.ProjectsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i93.WatchCommentsByTrackUseCase>(() =>
        _i93.WatchCommentsByTrackUseCase(gh<_i77.ProjectCommentService>()));
    gh.lazySingleton<_i94.WatchProjectDetailUseCase>(
        () => _i94.WatchProjectDetailUseCase(
              gh<_i57.AudioTrackLocalDataSource>(),
              gh<_i47.UserProfileLocalDataSource>(),
              gh<_i53.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i95.WatchTracksByProjectIdUseCase>(() =>
        _i95.WatchTracksByProjectIdUseCase(gh<_i59.AudioTrackRepository>()));
    gh.lazySingleton<_i96.WatchUserProfileUseCase>(
        () => _i96.WatchUserProfileUseCase(
              gh<_i49.UserProfileRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i97.AddAudioCommentUseCase>(
        () => _i97.AddAudioCommentUseCase(
              gh<_i77.ProjectCommentService>(),
              gh<_i29.ProjectDetailRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i98.AddCollaboratorToProjectUseCase>(
        () => _i98.AddCollaboratorToProjectUseCase(
              gh<_i29.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.factory<_i99.AudioSourceResolver>(
        () => _i100.AudioSourceResolverImpl(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i101.AuthRepository>(() => _i102.AuthRepositoryImpl(
          remote: gh<_i62.AuthRemoteDataSource>(),
          local: gh<_i61.AuthLocalDataSource>(),
          networkInfo: gh<_i24.NetworkInfo>(),
          firestore: gh<_i12.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i47.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i32.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i57.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i53.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i81.SessionStorage>(),
        ));
    gh.factory<_i103.CachePlaylistUseCase>(
        () => _i103.CachePlaylistUseCase(gh<_i65.CacheStorageRepository>()));
    gh.lazySingleton<_i104.CreateProjectUseCase>(
        () => _i104.CreateProjectUseCase(
              gh<_i33.ProjectsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i105.DeleteAudioCommentUseCase>(
        () => _i105.DeleteAudioCommentUseCase(
              gh<_i77.ProjectCommentService>(),
              gh<_i29.ProjectDetailRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i106.DeleteAudioTrack>(() => _i106.DeleteAudioTrack(
          gh<_i81.SessionStorage>(),
          gh<_i29.ProjectDetailRepository>(),
          gh<_i78.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i107.DeleteProjectUseCase>(
        () => _i107.DeleteProjectUseCase(
              gh<_i33.ProjectsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i108.EditAudioTrackUseCase>(
        () => _i108.EditAudioTrackUseCase(
              gh<_i78.ProjectTrackService>(),
              gh<_i29.ProjectDetailRepository>(),
            ));
    gh.lazySingleton<_i109.GenerateMagicLinkUseCase>(
        () => _i109.GenerateMagicLinkUseCase(
              gh<_i21.MagicLinkRepository>(),
              gh<_i101.AuthRepository>(),
            ));
    gh.lazySingleton<_i110.GetAuthStateUseCase>(
        () => _i110.GetAuthStateUseCase(gh<_i101.AuthRepository>()));
    gh.lazySingleton<_i111.GoogleSignInUseCase>(
        () => _i111.GoogleSignInUseCase(gh<_i101.AuthRepository>()));
    gh.lazySingleton<_i112.JoinProjectWithIdUseCase>(
        () => _i112.JoinProjectWithIdUseCase(
              gh<_i29.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i113.LeaveProjectUseCase>(() => _i113.LeaveProjectUseCase(
          gh<_i75.ManageCollaboratorsRepository>(),
          gh<_i81.SessionStorage>(),
        ));
    gh.factory<_i114.MagicLinkBloc>(() => _i114.MagicLinkBloc(
          generateMagicLink: gh<_i109.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i51.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i68.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i35.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i69.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i112.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i101.AuthRepository>(),
        ));
    gh.lazySingleton<_i115.OnboardingUseCase>(
        () => _i115.OnboardingUseCase(gh<_i101.AuthRepository>()));
    gh.factory<_i116.PlaylistCacheBloc>(() => _i116.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i103.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i70.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i79.RemovePlaylistCacheUseCase>(),
        ));
    gh.factory<_i117.ProjectDetailBloc>(() => _i117.ProjectDetailBloc(
        watchProjectDetail: gh<_i94.WatchProjectDetailUseCase>()));
    gh.factory<_i118.ProjectsBloc>(() => _i118.ProjectsBloc(
          createProject: gh<_i104.CreateProjectUseCase>(),
          updateProject: gh<_i89.UpdateProjectUseCase>(),
          deleteProject: gh<_i107.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i92.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i119.RemoveCollaboratorUseCase>(
        () => _i119.RemoveCollaboratorUseCase(
              gh<_i29.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i81.SessionStorage>(),
            ));
    gh.lazySingleton<_i120.SignInUseCase>(
        () => _i120.SignInUseCase(gh<_i101.AuthRepository>()));
    gh.lazySingleton<_i121.SignOutUseCase>(
        () => _i121.SignOutUseCase(gh<_i101.AuthRepository>()));
    gh.lazySingleton<_i122.SignUpUseCase>(
        () => _i122.SignUpUseCase(gh<_i101.AuthRepository>()));
    gh.lazySingleton<_i123.StartupResourceManager>(
        () => _i123.StartupResourceManager(
              gh<_i82.SyncAudioCommentsUseCase>(),
              gh<_i83.SyncAudioTracksUseCase>(),
              gh<_i84.SyncProjectsUseCase>(),
              gh<_i86.SyncUserProfileUseCase>(),
              gh<_i85.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i124.UserProfileBloc>(() => _i124.UserProfileBloc(
          updateUserProfileUseCase: gh<_i90.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i96.WatchUserProfileUseCase>(),
        ));
    gh.lazySingleton<_i125.AddCollaboratorAndSyncProfileService>(
        () => _i125.AddCollaboratorAndSyncProfileService(
              gh<_i98.AddCollaboratorToProjectUseCase>(),
              gh<_i49.UserProfileRepository>(),
            ));
    gh.factory<_i126.AudioCommentBloc>(() => _i126.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i93.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i97.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i105.DeleteAudioCommentUseCase>(),
        ));
    gh.lazySingleton<_i127.AudioContentRepository>(
        () => _i128.AudioContentRepositoryImpl(
              gh<_i59.AudioTrackRepository>(),
              gh<_i99.AudioSourceResolver>(),
            ));
    gh.factory<_i129.AudioTrackBloc>(() => _i129.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i95.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i106.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i91.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i108.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i130.AuthBloc>(() => _i130.AuthBloc(
          signIn: gh<_i120.SignInUseCase>(),
          signUp: gh<_i122.SignUpUseCase>(),
          signOut: gh<_i121.SignOutUseCase>(),
          googleSignIn: gh<_i111.GoogleSignInUseCase>(),
          getAuthState: gh<_i110.GetAuthStateUseCase>(),
          onboarding: gh<_i115.OnboardingUseCase>(),
        ));
    gh.factory<_i131.ManageCollaboratorsBloc>(
        () => _i131.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i125.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i119.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i88.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i113.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i52.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i132.PlayAudioUseCase>(() => _i132.PlayAudioUseCase(
          audioContentRepository: gh<_i127.AudioContentRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i133.PlayPlaylistUseCase>(() => _i133.PlayPlaylistUseCase(
          audioContentRepository: gh<_i127.AudioContentRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i134.RestorePlaybackStateUseCase>(
        () => _i134.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i26.PlaybackPersistenceRepository>(),
              audioContentRepository: gh<_i127.AudioContentRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i135.AudioPlayerBloc>(() => _i135.AudioPlayerBloc(
          initializeAudioPlayerUseCase: gh<_i16.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i132.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i133.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i25.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i36.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i44.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i42.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i43.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i38.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i46.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i45.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i40.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i39.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i37.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i134.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    return this;
  }
}

class _$AppModule extends _i136.AppModule {}
