// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i13;

import 'package:cloud_firestore/cloud_firestore.dart' as _i16;
import 'package:connectivity_plus/connectivity_plus.dart' as _i12;
import 'package:firebase_auth/firebase_auth.dart' as _i15;
import 'package:firebase_storage/firebase_storage.dart' as _i17;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i20;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i22;
import 'package:isar/isar.dart' as _i23;
import 'package:shared_preferences/shared_preferences.dart' as _i48;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i147;
import 'package:trackflow/core/di/app_module.dart' as _i150;
import 'package:trackflow/core/network/network_info.dart' as _i29;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i14;
import 'package:trackflow/core/session/session_storage.dart' as _i84;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i19;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i80;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i71;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i104;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i107;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i114;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i9;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i106;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_storage_facade_repository.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i11;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i10;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart'
    as _i124;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i140;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i60;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i61;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i63;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i62;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i81;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i102;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i118;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i85;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i95;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i144;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i31;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i30;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i78;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i79;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i83;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i32;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i105;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i67;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i66;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i82;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i121;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i86;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i91;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i97;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i145;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i108;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i68;
import 'package:trackflow/features/auth/data/data_sources/onboarding_state_local_datasource.dart'
    as _i77;
import 'package:trackflow/features/auth/data/data_sources/user_session_local_datasource.dart'
    as _i58;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i110;
import 'package:trackflow/features/auth/data/repositories/onboarding_repository_impl.dart'
    as _i130;
import 'package:trackflow/features/auth/data/repositories/welcome_screen_repository_impl.dart'
    as _i101;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i109;
import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart'
    as _i129;
import 'package:trackflow/features/auth/domain/repositories/welcome_screen_repository.dart'
    as _i100;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i123;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i125;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i131;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i136;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i137;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i138;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i146;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i24;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i26;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i72;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i122;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i73;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i42;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i59;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i128;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i75;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i76;
import 'package:trackflow/features/manage_collaborators/data/repositories/collaborator_repository_impl.dart'
    as _i116;
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart'
    as _i115;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i148;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i143;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i126;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i127;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i134;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i141;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i99;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i149;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i28;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i33;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i34;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i36;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i35;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i74;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i96;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i132;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i38;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i37;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i40;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i39;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i117;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i120;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i87;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i94;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i133;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i54;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i55;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i93;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i57;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_cache_repository.dart'
    as _i92;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i56;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i139;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i88;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i90;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i98;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i142;

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
    gh.factory<_i5.AudioSourceResolver>(() =>
        _i6.AudioSourceResolverImpl(gh<_i7.CacheStorageFacadeRepository>()));
    gh.lazySingleton<_i8.CacheMaintenanceService>(
        () => _i9.CacheMaintenanceServiceImpl());
    gh.factory<_i10.CacheTrackUseCase>(
        () => _i10.CacheTrackUseCase(gh<_i7.CacheStorageFacadeRepository>()));
    gh.factory<_i11.CleanupCacheUseCase>(
        () => _i11.CleanupCacheUseCase(gh<_i8.CacheMaintenanceService>()));
    gh.lazySingleton<_i12.Connectivity>(() => appModule.connectivity);
    await gh.factoryAsync<_i13.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i14.DynamicLinkService>(() => _i14.DynamicLinkService());
    gh.lazySingleton<_i15.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i16.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i17.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i18.GetCacheStorageStatsUseCase>(() =>
        _i18.GetCacheStorageStatsUseCase(gh<_i8.CacheMaintenanceService>()));
    gh.factory<_i19.GetPlaylistCacheStatusUseCase>(() =>
        _i19.GetPlaylistCacheStatusUseCase(
            gh<_i7.CacheStorageFacadeRepository>()));
    gh.lazySingleton<_i20.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i21.InitializeAudioPlayerUseCase>(() =>
        _i21.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i22.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i23.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i24.MagicLinkLocalDataSource>(
        () => _i24.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i25.MagicLinkRemoteDataSource>(() =>
        _i25.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.factory<_i26.MagicLinkRepository>(() =>
        _i27.MagicLinkRepositoryImp(gh<_i25.MagicLinkRemoteDataSource>()));
    gh.factory<_i28.NavigationCubit>(() => _i28.NavigationCubit());
    gh.lazySingleton<_i29.NetworkInfo>(
        () => _i29.NetworkInfoImpl(gh<_i22.InternetConnectionChecker>()));
    gh.factory<_i30.PauseAudioUseCase>(() => _i30.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i31.PlaybackPersistenceRepository>(
        () => _i32.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i33.PlaylistLocalDataSource>(
        () => _i33.PlaylistLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i34.PlaylistRemoteDataSource>(
        () => _i34.PlaylistRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i35.PlaylistRepository>(() => _i36.PlaylistRepositoryImpl(
          localDataSource: gh<_i33.PlaylistLocalDataSource>(),
          remoteDataSource: gh<_i34.PlaylistRemoteDataSource>(),
        ));
    gh.lazySingleton<_i37.ProjectRemoteDataSource>(() =>
        _i37.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i38.ProjectsLocalDataSource>(
        () => _i38.ProjectsLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i39.ProjectsRepository>(() => _i40.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i37.ProjectRemoteDataSource>(),
          localDataSource: gh<_i38.ProjectsLocalDataSource>(),
          networkInfo: gh<_i29.NetworkInfo>(),
        ));
    gh.factory<_i41.RemovePlaylistCacheUseCase>(() =>
        _i41.RemovePlaylistCacheUseCase(
            gh<_i7.CacheStorageFacadeRepository>()));
    gh.lazySingleton<_i42.ResendMagicLinkUseCase>(
        () => _i42.ResendMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i43.ResumeAudioUseCase>(() => _i43.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i44.SavePlaybackStateUseCase>(
        () => _i44.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i31.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i45.SeekAudioUseCase>(() =>
        _i45.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i46.SetPlaybackSpeedUseCase>(() => _i46.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i47.SetVolumeUseCase>(() =>
        _i47.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i48.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i49.SkipToNextUseCase>(() => _i49.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i50.SkipToPreviousUseCase>(() => _i50.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i51.StopAudioUseCase>(() =>
        _i51.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i52.ToggleRepeatModeUseCase>(() => _i52.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i53.ToggleShuffleUseCase>(() => _i53.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i54.UserProfileLocalDataSource>(
        () => _i54.IsarUserProfileLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i55.UserProfileRemoteDataSource>(
        () => _i55.UserProfileRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i56.UserProfileRepository>(
        () => _i57.UserProfileRepositoryImpl(
              gh<_i55.UserProfileRemoteDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i29.NetworkInfo>(),
            ));
    gh.lazySingleton<_i58.UserSessionLocalDataSource>(() =>
        _i58.UserSessionLocalDataSourceImpl(gh<_i48.SharedPreferences>()));
    gh.lazySingleton<_i59.ValidateMagicLinkUseCase>(
        () => _i59.ValidateMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.lazySingleton<_i60.AudioCommentLocalDataSource>(
        () => _i60.IsarAudioCommentLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i61.AudioCommentRemoteDataSource>(() =>
        _i61.FirebaseAudioCommentRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i62.AudioCommentRepository>(
        () => _i63.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i61.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i60.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i29.NetworkInfo>(),
            ));
    gh.lazySingleton<_i64.AudioTrackLocalDataSource>(
        () => _i64.IsarAudioTrackLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i65.AudioTrackRemoteDataSource>(
        () => _i65.AudioTrackRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i66.AudioTrackRepository>(
        () => _i67.AudioTrackRepositoryImpl(
              gh<_i65.AudioTrackRemoteDataSource>(),
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i29.NetworkInfo>(),
            ));
    gh.lazySingleton<_i68.AuthRemoteDataSource>(
        () => _i68.AuthRemoteDataSourceImpl(
              gh<_i15.FirebaseAuth>(),
              gh<_i20.GoogleSignIn>(),
            ));
    gh.factory<_i69.CachePlaylistUseCase>(() => _i69.CachePlaylistUseCase(
          gh<_i7.CacheStorageFacadeRepository>(),
          gh<_i66.AudioTrackRepository>(),
        ));
    gh.lazySingleton<_i70.CacheStorageLocalDataSource>(
        () => _i70.CacheStorageLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i71.CacheStorageRemoteDataSource>(() =>
        _i71.CacheStorageRemoteDataSourceImpl(gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i72.ConsumeMagicLinkUseCase>(
        () => _i72.ConsumeMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.lazySingleton<_i73.GetMagicLinkStatusUseCase>(
        () => _i73.GetMagicLinkStatusUseCase(gh<_i26.MagicLinkRepository>()));
    gh.lazySingleton<_i74.GetProjectByIdUseCase>(
        () => _i74.GetProjectByIdUseCase(gh<_i39.ProjectsRepository>()));
    gh.lazySingleton<_i75.ManageCollaboratorsLocalDataSource>(() =>
        _i75.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i38.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i76.ManageCollaboratorsRemoteDataSource>(() =>
        _i76.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i55.UserProfileRemoteDataSource>(),
          firestore: gh<_i16.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i77.OnboardingStateLocalDataSource>(() =>
        _i77.OnboardingStateLocalDataSourceImpl(gh<_i48.SharedPreferences>()));
    gh.factory<_i78.PlayAudioUseCase>(() => _i78.PlayAudioUseCase(
          audioTrackRepository: gh<_i66.AudioTrackRepository>(),
          cacheStorageRepository: gh<_i7.CacheStorageFacadeRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i79.PlayPlaylistUseCase>(() => _i79.PlayPlaylistUseCase(
          playlistRepository: gh<_i35.PlaylistRepository>(),
          audioTrackRepository: gh<_i66.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i80.PlaylistCacheBloc>(() => _i80.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i69.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i19.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i41.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i81.ProjectCommentService>(
        () => _i81.ProjectCommentService(gh<_i62.AudioCommentRepository>()));
    gh.lazySingleton<_i82.ProjectTrackService>(
        () => _i82.ProjectTrackService(gh<_i66.AudioTrackRepository>()));
    gh.factory<_i83.RestorePlaybackStateUseCase>(
        () => _i83.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i31.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i66.AudioTrackRepository>(),
              cacheStorageRepository: gh<_i7.CacheStorageFacadeRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i84.SessionStorage>(
        () => _i84.SessionStorage(prefs: gh<_i48.SharedPreferences>()));
    gh.lazySingleton<_i85.SyncAudioCommentsUseCase>(
        () => _i85.SyncAudioCommentsUseCase(
              gh<_i61.AudioCommentRemoteDataSource>(),
              gh<_i60.AudioCommentLocalDataSource>(),
              gh<_i37.ProjectRemoteDataSource>(),
              gh<_i84.SessionStorage>(),
              gh<_i65.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i86.SyncAudioTracksUseCase>(
        () => _i86.SyncAudioTracksUseCase(
              gh<_i65.AudioTrackRemoteDataSource>(),
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i37.ProjectRemoteDataSource>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i87.SyncProjectsUseCase>(() => _i87.SyncProjectsUseCase(
          gh<_i37.ProjectRemoteDataSource>(),
          gh<_i38.ProjectsLocalDataSource>(),
          gh<_i84.SessionStorage>(),
        ));
    gh.lazySingleton<_i88.SyncUserProfileUseCase>(
        () => _i88.SyncUserProfileUseCase(
              gh<_i55.UserProfileRemoteDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i89.UpdateProjectUseCase>(() => _i89.UpdateProjectUseCase(
          gh<_i39.ProjectsRepository>(),
          gh<_i84.SessionStorage>(),
        ));
    gh.factory<_i90.UpdateUserProfileUseCase>(
        () => _i90.UpdateUserProfileUseCase(
              gh<_i56.UserProfileRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i91.UploadAudioTrackUseCase>(
        () => _i91.UploadAudioTrackUseCase(
              gh<_i82.ProjectTrackService>(),
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i92.UserProfileCacheRepository>(
        () => _i93.UserProfileCacheRepositoryImpl(
              gh<_i55.UserProfileRemoteDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i29.NetworkInfo>(),
            ));
    gh.lazySingleton<_i94.WatchAllProjectsUseCase>(
        () => _i94.WatchAllProjectsUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i95.WatchCommentsByTrackUseCase>(() =>
        _i95.WatchCommentsByTrackUseCase(gh<_i81.ProjectCommentService>()));
    gh.lazySingleton<_i96.WatchProjectDetailUseCase>(
        () => _i96.WatchProjectDetailUseCase(
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i60.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i97.WatchTracksByProjectIdUseCase>(() =>
        _i97.WatchTracksByProjectIdUseCase(gh<_i66.AudioTrackRepository>()));
    gh.lazySingleton<_i98.WatchUserProfileUseCase>(
        () => _i98.WatchUserProfileUseCase(
              gh<_i56.UserProfileRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i99.WatchUserProfilesUseCase>(() =>
        _i99.WatchUserProfilesUseCase(gh<_i92.UserProfileCacheRepository>()));
    gh.lazySingleton<_i100.WelcomeScreenRepository>(() =>
        _i101.WelcomeScreenRepositoryImpl(
            gh<_i77.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i102.AddAudioCommentUseCase>(
        () => _i102.AddAudioCommentUseCase(
              gh<_i81.ProjectCommentService>(),
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i103.AudioDownloadRepository>(() =>
        _i104.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i71.CacheStorageRemoteDataSource>()));
    gh.factory<_i105.AudioPlayerBloc>(() => _i105.AudioPlayerBloc(
          initializeAudioPlayerUseCase: gh<_i21.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i78.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i79.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i30.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i43.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i51.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i49.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i50.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i45.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i53.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i52.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i47.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i46.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i44.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i83.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i106.AudioStorageRepository>(() =>
        _i107.AudioStorageRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i108.AuthLocalDataSource>(
        () => _i108.AuthLocalDataSourceImpl(
              gh<_i58.UserSessionLocalDataSource>(),
              gh<_i77.OnboardingStateLocalDataSource>(),
            ));
    gh.lazySingleton<_i109.AuthRepository>(() => _i110.AuthRepositoryImpl(
          remote: gh<_i68.AuthRemoteDataSource>(),
          userSessionLocalDataSource: gh<_i58.UserSessionLocalDataSource>(),
          networkInfo: gh<_i29.NetworkInfo>(),
          firestore: gh<_i16.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i54.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i38.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i64.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i60.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i84.SessionStorage>(),
        ));
    gh.lazySingleton<_i111.CacheKeyRepository>(() =>
        _i112.CacheKeyRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i113.CacheMaintenanceRepository>(() =>
        _i114.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i115.CollaboratorRepository>(
        () => _i116.CollaboratorRepositoryImpl(
              remoteDataSource: gh<_i76.ManageCollaboratorsRemoteDataSource>(),
              localDataSource: gh<_i75.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i29.NetworkInfo>(),
            ));
    gh.lazySingleton<_i117.CreateProjectUseCase>(
        () => _i117.CreateProjectUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i118.DeleteAudioCommentUseCase>(
        () => _i118.DeleteAudioCommentUseCase(
              gh<_i81.ProjectCommentService>(),
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i119.DeleteAudioTrack>(() => _i119.DeleteAudioTrack(
          gh<_i84.SessionStorage>(),
          gh<_i39.ProjectsRepository>(),
          gh<_i82.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i120.DeleteProjectUseCase>(
        () => _i120.DeleteProjectUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i121.EditAudioTrackUseCase>(
        () => _i121.EditAudioTrackUseCase(
              gh<_i82.ProjectTrackService>(),
              gh<_i39.ProjectsRepository>(),
            ));
    gh.lazySingleton<_i122.GenerateMagicLinkUseCase>(
        () => _i122.GenerateMagicLinkUseCase(
              gh<_i26.MagicLinkRepository>(),
              gh<_i109.AuthRepository>(),
            ));
    gh.lazySingleton<_i123.GetAuthStateUseCase>(
        () => _i123.GetAuthStateUseCase(gh<_i109.AuthRepository>()));
    gh.factory<_i124.GetTrackCacheStatusUseCase>(
        () => _i124.GetTrackCacheStatusUseCase(
              gh<_i106.AudioStorageRepository>(),
              gh<_i103.AudioDownloadRepository>(),
            ));
    gh.lazySingleton<_i125.GoogleSignInUseCase>(
        () => _i125.GoogleSignInUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i126.JoinProjectWithIdUseCase>(
        () => _i126.JoinProjectWithIdUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i115.CollaboratorRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.lazySingleton<_i127.LeaveProjectUseCase>(() => _i127.LeaveProjectUseCase(
          gh<_i115.CollaboratorRepository>(),
          gh<_i84.SessionStorage>(),
        ));
    gh.factory<_i128.MagicLinkBloc>(() => _i128.MagicLinkBloc(
          generateMagicLink: gh<_i122.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i59.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i72.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i42.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i73.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i126.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i109.AuthRepository>(),
        ));
    gh.lazySingleton<_i129.OnboardingRepository>(() =>
        _i130.OnboardingRepositoryImpl(
            gh<_i77.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i131.OnboardingUseCase>(() => _i131.OnboardingUseCase(
          gh<_i129.OnboardingRepository>(),
          gh<_i100.WelcomeScreenRepository>(),
        ));
    gh.factory<_i132.ProjectDetailBloc>(() => _i132.ProjectDetailBloc(
        watchProjectDetail: gh<_i96.WatchProjectDetailUseCase>()));
    gh.factory<_i133.ProjectsBloc>(() => _i133.ProjectsBloc(
          createProject: gh<_i117.CreateProjectUseCase>(),
          updateProject: gh<_i89.UpdateProjectUseCase>(),
          deleteProject: gh<_i120.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i94.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i134.RemoveCollaboratorUseCase>(
        () => _i134.RemoveCollaboratorUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i115.CollaboratorRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.factory<_i135.RemoveTrackCacheUseCase>(() =>
        _i135.RemoveTrackCacheUseCase(gh<_i106.AudioStorageRepository>()));
    gh.lazySingleton<_i136.SignInUseCase>(
        () => _i136.SignInUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i137.SignOutUseCase>(
        () => _i137.SignOutUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i138.SignUpUseCase>(
        () => _i138.SignUpUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i139.SyncUserProfileCollaboratorsUseCase>(
        () => _i139.SyncUserProfileCollaboratorsUseCase(
              gh<_i38.ProjectsLocalDataSource>(),
              gh<_i92.UserProfileCacheRepository>(),
            ));
    gh.factory<_i140.TrackCacheBloc>(() => _i140.TrackCacheBloc(
          cacheTrackUseCase: gh<_i10.CacheTrackUseCase>(),
          getTrackCacheStatusUseCase: gh<_i124.GetTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i135.RemoveTrackCacheUseCase>(),
        ));
    gh.lazySingleton<_i141.UpdateCollaboratorRoleUseCase>(
        () => _i141.UpdateCollaboratorRoleUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i115.CollaboratorRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.factory<_i142.UserProfileBloc>(() => _i142.UserProfileBloc(
          updateUserProfileUseCase: gh<_i90.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i98.WatchUserProfileUseCase>(),
        ));
    gh.lazySingleton<_i143.AddCollaboratorToProjectUseCase>(
        () => _i143.AddCollaboratorToProjectUseCase(
              gh<_i39.ProjectsRepository>(),
              gh<_i115.CollaboratorRepository>(),
              gh<_i84.SessionStorage>(),
            ));
    gh.factory<_i144.AudioCommentBloc>(() => _i144.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i95.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i102.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i118.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i145.AudioTrackBloc>(() => _i145.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i97.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i119.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i91.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i121.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i146.AuthBloc>(() => _i146.AuthBloc(
          signIn: gh<_i136.SignInUseCase>(),
          signUp: gh<_i138.SignUpUseCase>(),
          signOut: gh<_i137.SignOutUseCase>(),
          googleSignIn: gh<_i125.GoogleSignInUseCase>(),
          getAuthState: gh<_i123.GetAuthStateUseCase>(),
          onboarding: gh<_i131.OnboardingUseCase>(),
        ));
    gh.lazySingleton<_i147.StartupResourceManager>(
        () => _i147.StartupResourceManager(
              gh<_i85.SyncAudioCommentsUseCase>(),
              gh<_i86.SyncAudioTracksUseCase>(),
              gh<_i87.SyncProjectsUseCase>(),
              gh<_i88.SyncUserProfileUseCase>(),
              gh<_i139.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.lazySingleton<_i148.AddCollaboratorAndSyncProfileService>(
        () => _i148.AddCollaboratorAndSyncProfileService(
              gh<_i143.AddCollaboratorToProjectUseCase>(),
              gh<_i92.UserProfileCacheRepository>(),
            ));
    gh.factory<_i149.ManageCollaboratorsBloc>(
        () => _i149.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i148.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i134.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i141.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i127.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i99.WatchUserProfilesUseCase>(),
            ));
    return this;
  }
}

class _$AppModule extends _i150.AppModule {}
