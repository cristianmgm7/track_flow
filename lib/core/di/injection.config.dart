// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i10;

import 'package:cloud_firestore/cloud_firestore.dart' as _i13;
import 'package:connectivity_plus/connectivity_plus.dart' as _i8;
import 'package:firebase_auth/firebase_auth.dart' as _i12;
import 'package:firebase_storage/firebase_storage.dart' as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i16;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i18;
import 'package:isar/isar.dart' as _i19;
import 'package:shared_preferences/shared_preferences.dart' as _i43;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i148;
import 'package:trackflow/core/di/app_module.dart' as _i154;
import 'package:trackflow/core/network/network_info.dart' as _i25;
import 'package:trackflow/core/services/deep_link_service.dart' as _i9;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i11;
import 'package:trackflow/core/session/session_storage.dart' as _i73;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i127;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i147;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i64;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i65;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i94;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i93;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i95;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i99;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i101;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i5;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i15;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i104;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i137;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i149;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i55;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i58;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i57;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i90;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i74;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i83;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i139;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i91;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i116;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i92;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i140;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i27;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i141;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i142;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i17;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i26;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i121;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i122;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i129;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i28;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i143;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i151;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i59;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i62;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i61;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i124;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i146;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i75;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i85;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i152;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/auth/data/data_sources/onboarding_state_local_datasource.dart'
    as _i71;
import 'package:trackflow/features/auth/data/data_sources/user_session_local_datasource.dart'
    as _i53;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i98;
import 'package:trackflow/features/auth/data/repositories/onboarding_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/auth/data/repositories/welcome_screen_repository_impl.dart'
    as _i89;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i97;
import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart'
    as _i118;
import 'package:trackflow/features/auth/domain/repositories/welcome_screen_repository.dart'
    as _i88;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i111;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i113;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i120;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i130;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i131;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i132;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i144;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i20;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i21;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i23;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i22;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i110;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i67;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i37;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i54;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i117;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i69;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i70;
import 'package:trackflow/features/manage_collaborators/data/repositories/collaborator_repository_impl.dart'
    as _i106;
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart'
    as _i105;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i150;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i138;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i114;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i115;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i126;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i134;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i87;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i153;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i24;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i29;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i30;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i32;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i31;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i84;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i123;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i34;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i33;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i36;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i35;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i107;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i109;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i68;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i76;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i78;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i82;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i125;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i49;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i50;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i81;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i52;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i51;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i80;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i133;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i77;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i79;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i86;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i136;

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
    gh.singleton<_i9.DeepLinkService>(() => _i9.DeepLinkService());
    await gh.factoryAsync<_i10.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i11.DynamicLinkService>(() => _i11.DynamicLinkService());
    gh.lazySingleton<_i12.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i13.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i14.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i15.GetCacheStorageStatsUseCase>(() =>
        _i15.GetCacheStorageStatsUseCase(gh<_i5.CacheMaintenanceService>()));
    gh.lazySingleton<_i16.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i17.InitializeAudioPlayerUseCase>(() =>
        _i17.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i18.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i19.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i20.MagicLinkLocalDataSource>(
        () => _i20.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i21.MagicLinkRemoteDataSource>(
        () => _i21.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i13.FirebaseFirestore>(),
              deepLinkService: gh<_i9.DeepLinkService>(),
            ));
    gh.factory<_i22.MagicLinkRepository>(() =>
        _i23.MagicLinkRepositoryImp(gh<_i21.MagicLinkRemoteDataSource>()));
    gh.factory<_i24.NavigationCubit>(() => _i24.NavigationCubit());
    gh.lazySingleton<_i25.NetworkInfo>(
        () => _i25.NetworkInfoImpl(gh<_i18.InternetConnectionChecker>()));
    gh.factory<_i26.PauseAudioUseCase>(() => _i26.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i27.PlaybackPersistenceRepository>(
        () => _i28.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i29.PlaylistLocalDataSource>(
        () => _i29.PlaylistLocalDataSourceImpl(gh<_i19.Isar>()));
    gh.lazySingleton<_i30.PlaylistRemoteDataSource>(
        () => _i30.PlaylistRemoteDataSourceImpl(gh<_i13.FirebaseFirestore>()));
    gh.lazySingleton<_i31.PlaylistRepository>(() => _i32.PlaylistRepositoryImpl(
          localDataSource: gh<_i29.PlaylistLocalDataSource>(),
          remoteDataSource: gh<_i30.PlaylistRemoteDataSource>(),
        ));
    gh.lazySingleton<_i33.ProjectRemoteDataSource>(() =>
        _i33.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i13.FirebaseFirestore>()));
    gh.lazySingleton<_i34.ProjectsLocalDataSource>(
        () => _i34.ProjectsLocalDataSourceImpl(gh<_i19.Isar>()));
    gh.lazySingleton<_i35.ProjectsRepository>(() => _i36.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i33.ProjectRemoteDataSource>(),
          localDataSource: gh<_i34.ProjectsLocalDataSource>(),
          networkInfo: gh<_i25.NetworkInfo>(),
        ));
    gh.lazySingleton<_i37.ResendMagicLinkUseCase>(
        () => _i37.ResendMagicLinkUseCase(gh<_i22.MagicLinkRepository>()));
    gh.factory<_i38.ResumeAudioUseCase>(() => _i38.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i39.SavePlaybackStateUseCase>(
        () => _i39.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i27.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i40.SeekAudioUseCase>(() =>
        _i40.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i41.SetPlaybackSpeedUseCase>(() => _i41.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i42.SetVolumeUseCase>(() =>
        _i42.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i43.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i44.SkipToNextUseCase>(() => _i44.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i45.SkipToPreviousUseCase>(() => _i45.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i46.StopAudioUseCase>(() =>
        _i46.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i47.ToggleRepeatModeUseCase>(() => _i47.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i48.ToggleShuffleUseCase>(() => _i48.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i49.UserProfileLocalDataSource>(
        () => _i49.IsarUserProfileLocalDataSource(gh<_i19.Isar>()));
    gh.lazySingleton<_i50.UserProfileRemoteDataSource>(
        () => _i50.UserProfileRemoteDataSourceImpl(
              gh<_i13.FirebaseFirestore>(),
              gh<_i14.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i51.UserProfileRepository>(
        () => _i52.UserProfileRepositoryImpl(
              gh<_i50.UserProfileRemoteDataSource>(),
              gh<_i49.UserProfileLocalDataSource>(),
              gh<_i25.NetworkInfo>(),
            ));
    gh.lazySingleton<_i53.UserSessionLocalDataSource>(() =>
        _i53.UserSessionLocalDataSourceImpl(gh<_i43.SharedPreferences>()));
    gh.lazySingleton<_i54.ValidateMagicLinkUseCase>(
        () => _i54.ValidateMagicLinkUseCase(gh<_i22.MagicLinkRepository>()));
    gh.lazySingleton<_i55.AudioCommentLocalDataSource>(
        () => _i55.IsarAudioCommentLocalDataSource(gh<_i19.Isar>()));
    gh.lazySingleton<_i56.AudioCommentRemoteDataSource>(() =>
        _i56.FirebaseAudioCommentRemoteDataSource(
            gh<_i13.FirebaseFirestore>()));
    gh.lazySingleton<_i57.AudioCommentRepository>(
        () => _i58.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i56.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i55.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i25.NetworkInfo>(),
            ));
    gh.lazySingleton<_i59.AudioTrackLocalDataSource>(
        () => _i59.IsarAudioTrackLocalDataSource(gh<_i19.Isar>()));
    gh.lazySingleton<_i60.AudioTrackRemoteDataSource>(
        () => _i60.AudioTrackRemoteDataSourceImpl(
              gh<_i13.FirebaseFirestore>(),
              gh<_i14.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i61.AudioTrackRepository>(
        () => _i62.AudioTrackRepositoryImpl(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i25.NetworkInfo>(),
            ));
    gh.lazySingleton<_i63.AuthRemoteDataSource>(
        () => _i63.AuthRemoteDataSourceImpl(
              gh<_i12.FirebaseAuth>(),
              gh<_i16.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i64.CacheStorageLocalDataSource>(
        () => _i64.CacheStorageLocalDataSourceImpl(gh<_i19.Isar>()));
    gh.lazySingleton<_i65.CacheStorageRemoteDataSource>(() =>
        _i65.CacheStorageRemoteDataSourceImpl(gh<_i14.FirebaseStorage>()));
    gh.lazySingleton<_i66.ConsumeMagicLinkUseCase>(
        () => _i66.ConsumeMagicLinkUseCase(gh<_i22.MagicLinkRepository>()));
    gh.lazySingleton<_i67.GetMagicLinkStatusUseCase>(
        () => _i67.GetMagicLinkStatusUseCase(gh<_i22.MagicLinkRepository>()));
    gh.lazySingleton<_i68.GetProjectByIdUseCase>(
        () => _i68.GetProjectByIdUseCase(gh<_i35.ProjectsRepository>()));
    gh.lazySingleton<_i69.ManageCollaboratorsLocalDataSource>(() =>
        _i69.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i34.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i70.ManageCollaboratorsRemoteDataSource>(() =>
        _i70.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i50.UserProfileRemoteDataSource>(),
          firestore: gh<_i13.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i71.OnboardingStateLocalDataSource>(() =>
        _i71.OnboardingStateLocalDataSourceImpl(gh<_i43.SharedPreferences>()));
    gh.lazySingleton<_i72.ProjectCommentService>(
        () => _i72.ProjectCommentService(gh<_i57.AudioCommentRepository>()));
    gh.lazySingleton<_i73.SessionStorage>(
        () => _i73.SessionStorage(prefs: gh<_i43.SharedPreferences>()));
    gh.lazySingleton<_i74.SyncAudioCommentsUseCase>(
        () => _i74.SyncAudioCommentsUseCase(
              gh<_i56.AudioCommentRemoteDataSource>(),
              gh<_i55.AudioCommentLocalDataSource>(),
              gh<_i33.ProjectRemoteDataSource>(),
              gh<_i73.SessionStorage>(),
              gh<_i60.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i75.SyncAudioTracksUseCase>(
        () => _i75.SyncAudioTracksUseCase(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i33.ProjectRemoteDataSource>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i76.SyncProjectsUseCase>(() => _i76.SyncProjectsUseCase(
          gh<_i33.ProjectRemoteDataSource>(),
          gh<_i34.ProjectsLocalDataSource>(),
          gh<_i73.SessionStorage>(),
        ));
    gh.lazySingleton<_i77.SyncUserProfileUseCase>(
        () => _i77.SyncUserProfileUseCase(
              gh<_i50.UserProfileRemoteDataSource>(),
              gh<_i49.UserProfileLocalDataSource>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i78.UpdateProjectUseCase>(() => _i78.UpdateProjectUseCase(
          gh<_i35.ProjectsRepository>(),
          gh<_i73.SessionStorage>(),
        ));
    gh.factory<_i79.UpdateUserProfileUseCase>(
        () => _i79.UpdateUserProfileUseCase(
              gh<_i51.UserProfileRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i80.UserProfileCacheRepository>(
        () => _i81.UserProfileCacheRepositoryImpl(
              gh<_i50.UserProfileRemoteDataSource>(),
              gh<_i49.UserProfileLocalDataSource>(),
              gh<_i25.NetworkInfo>(),
            ));
    gh.lazySingleton<_i82.WatchAllProjectsUseCase>(
        () => _i82.WatchAllProjectsUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i83.WatchCommentsByTrackUseCase>(() =>
        _i83.WatchCommentsByTrackUseCase(gh<_i72.ProjectCommentService>()));
    gh.lazySingleton<_i84.WatchProjectDetailUseCase>(
        () => _i84.WatchProjectDetailUseCase(
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i49.UserProfileLocalDataSource>(),
              gh<_i55.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i85.WatchTracksByProjectIdUseCase>(() =>
        _i85.WatchTracksByProjectIdUseCase(gh<_i61.AudioTrackRepository>()));
    gh.lazySingleton<_i86.WatchUserProfileUseCase>(
        () => _i86.WatchUserProfileUseCase(
              gh<_i51.UserProfileRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i87.WatchUserProfilesUseCase>(() =>
        _i87.WatchUserProfilesUseCase(gh<_i80.UserProfileCacheRepository>()));
    gh.lazySingleton<_i88.WelcomeScreenRepository>(() =>
        _i89.WelcomeScreenRepositoryImpl(
            gh<_i71.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i90.AddAudioCommentUseCase>(
        () => _i90.AddAudioCommentUseCase(
              gh<_i72.ProjectCommentService>(),
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i91.AudioContextService>(
        () => _i92.AudioContextServiceImpl(
              userProfileRepository: gh<_i51.UserProfileRepository>(),
              audioTrackRepository: gh<_i61.AudioTrackRepository>(),
              projectsRepository: gh<_i35.ProjectsRepository>(),
            ));
    gh.lazySingleton<_i93.AudioDownloadRepository>(() =>
        _i94.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i65.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i95.AudioStorageRepository>(() =>
        _i96.AudioStorageRepositoryImpl(
            localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i97.AuthRepository>(() => _i98.AuthRepositoryImpl(
          remote: gh<_i63.AuthRemoteDataSource>(),
          userSessionLocalDataSource: gh<_i53.UserSessionLocalDataSource>(),
          networkInfo: gh<_i25.NetworkInfo>(),
          firestore: gh<_i13.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i49.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i34.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i59.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i55.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i73.SessionStorage>(),
        ));
    gh.lazySingleton<_i99.CacheKeyRepository>(() =>
        _i100.CacheKeyRepositoryImpl(
            localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i101.CacheMaintenanceRepository>(() =>
        _i102.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.factory<_i103.CachePlaylistUseCase>(() => _i103.CachePlaylistUseCase(
          gh<_i93.AudioDownloadRepository>(),
          gh<_i61.AudioTrackRepository>(),
        ));
    gh.factory<_i104.CacheTrackUseCase>(() => _i104.CacheTrackUseCase(
          gh<_i93.AudioDownloadRepository>(),
          gh<_i95.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i105.CollaboratorRepository>(
        () => _i106.CollaboratorRepositoryImpl(
              remoteDataSource: gh<_i70.ManageCollaboratorsRemoteDataSource>(),
              localDataSource: gh<_i69.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i25.NetworkInfo>(),
            ));
    gh.lazySingleton<_i107.CreateProjectUseCase>(
        () => _i107.CreateProjectUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i108.DeleteAudioCommentUseCase>(
        () => _i108.DeleteAudioCommentUseCase(
              gh<_i72.ProjectCommentService>(),
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i109.DeleteProjectUseCase>(
        () => _i109.DeleteProjectUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i110.GenerateMagicLinkUseCase>(
        () => _i110.GenerateMagicLinkUseCase(
              gh<_i22.MagicLinkRepository>(),
              gh<_i97.AuthRepository>(),
            ));
    gh.lazySingleton<_i111.GetAuthStateUseCase>(
        () => _i111.GetAuthStateUseCase(gh<_i97.AuthRepository>()));
    gh.factory<_i112.GetPlaylistCacheStatusUseCase>(() =>
        _i112.GetPlaylistCacheStatusUseCase(gh<_i95.AudioStorageRepository>()));
    gh.lazySingleton<_i113.GoogleSignInUseCase>(
        () => _i113.GoogleSignInUseCase(gh<_i97.AuthRepository>()));
    gh.lazySingleton<_i114.JoinProjectWithIdUseCase>(
        () => _i114.JoinProjectWithIdUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i105.CollaboratorRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i115.LeaveProjectUseCase>(() => _i115.LeaveProjectUseCase(
          gh<_i105.CollaboratorRepository>(),
          gh<_i73.SessionStorage>(),
        ));
    gh.factory<_i116.LoadTrackContextUseCase>(
        () => _i116.LoadTrackContextUseCase(gh<_i91.AudioContextService>()));
    gh.factory<_i117.MagicLinkBloc>(() => _i117.MagicLinkBloc(
          generateMagicLink: gh<_i110.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i54.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i66.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i37.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i67.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i114.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i97.AuthRepository>(),
        ));
    gh.lazySingleton<_i118.OnboardingRepository>(() =>
        _i119.OnboardingRepositoryImpl(
            gh<_i71.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i120.OnboardingUseCase>(() => _i120.OnboardingUseCase(
          gh<_i118.OnboardingRepository>(),
          gh<_i88.WelcomeScreenRepository>(),
        ));
    gh.factory<_i121.PlayAudioUseCase>(() => _i121.PlayAudioUseCase(
          audioTrackRepository: gh<_i61.AudioTrackRepository>(),
          audioStorageRepository: gh<_i95.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i122.PlayPlaylistUseCase>(() => _i122.PlayPlaylistUseCase(
          playlistRepository: gh<_i31.PlaylistRepository>(),
          audioTrackRepository: gh<_i61.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i95.AudioStorageRepository>(),
        ));
    gh.factory<_i123.ProjectDetailBloc>(() => _i123.ProjectDetailBloc(
        watchProjectDetail: gh<_i84.WatchProjectDetailUseCase>()));
    gh.lazySingleton<_i124.ProjectTrackService>(() => _i124.ProjectTrackService(
          gh<_i61.AudioTrackRepository>(),
          gh<_i95.AudioStorageRepository>(),
        ));
    gh.factory<_i125.ProjectsBloc>(() => _i125.ProjectsBloc(
          createProject: gh<_i107.CreateProjectUseCase>(),
          updateProject: gh<_i78.UpdateProjectUseCase>(),
          deleteProject: gh<_i109.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i82.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i126.RemoveCollaboratorUseCase>(
        () => _i126.RemoveCollaboratorUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i105.CollaboratorRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.factory<_i127.RemovePlaylistCacheUseCase>(() =>
        _i127.RemovePlaylistCacheUseCase(gh<_i95.AudioStorageRepository>()));
    gh.factory<_i128.RemoveTrackCacheUseCase>(
        () => _i128.RemoveTrackCacheUseCase(gh<_i95.AudioStorageRepository>()));
    gh.factory<_i129.RestorePlaybackStateUseCase>(
        () => _i129.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i27.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i61.AudioTrackRepository>(),
              audioStorageRepository: gh<_i95.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i130.SignInUseCase>(
        () => _i130.SignInUseCase(gh<_i97.AuthRepository>()));
    gh.lazySingleton<_i131.SignOutUseCase>(
        () => _i131.SignOutUseCase(gh<_i97.AuthRepository>()));
    gh.lazySingleton<_i132.SignUpUseCase>(
        () => _i132.SignUpUseCase(gh<_i97.AuthRepository>()));
    gh.lazySingleton<_i133.SyncUserProfileCollaboratorsUseCase>(
        () => _i133.SyncUserProfileCollaboratorsUseCase(
              gh<_i34.ProjectsLocalDataSource>(),
              gh<_i80.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i134.UpdateCollaboratorRoleUseCase>(
        () => _i134.UpdateCollaboratorRoleUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i105.CollaboratorRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.lazySingleton<_i135.UploadAudioTrackUseCase>(
        () => _i135.UploadAudioTrackUseCase(
              gh<_i124.ProjectTrackService>(),
              gh<_i35.ProjectsRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.factory<_i136.UserProfileBloc>(() => _i136.UserProfileBloc(
          updateUserProfileUseCase: gh<_i79.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i86.WatchUserProfileUseCase>(),
        ));
    gh.factory<_i137.WatchTrackCacheStatusUseCase>(() =>
        _i137.WatchTrackCacheStatusUseCase(gh<_i95.AudioStorageRepository>()));
    gh.lazySingleton<_i138.AddCollaboratorToProjectUseCase>(
        () => _i138.AddCollaboratorToProjectUseCase(
              gh<_i35.ProjectsRepository>(),
              gh<_i105.CollaboratorRepository>(),
              gh<_i73.SessionStorage>(),
            ));
    gh.factory<_i139.AudioCommentBloc>(() => _i139.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i83.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i90.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i108.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i140.AudioContextBloc>(() => _i140.AudioContextBloc(
        loadTrackContextUseCase: gh<_i116.LoadTrackContextUseCase>()));
    gh.factory<_i141.AudioPlayerService>(() => _i141.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i17.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i121.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i122.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i26.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i38.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i46.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i44.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i45.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i40.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i48.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i47.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i42.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i41.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i39.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i129.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i142.AudioSourceResolver>(() => _i143.AudioSourceResolverImpl(
          gh<_i95.AudioStorageRepository>(),
          gh<_i93.AudioDownloadRepository>(),
        ));
    gh.factory<_i144.AuthBloc>(() => _i144.AuthBloc(
          signIn: gh<_i130.SignInUseCase>(),
          signUp: gh<_i132.SignUpUseCase>(),
          signOut: gh<_i131.SignOutUseCase>(),
          googleSignIn: gh<_i113.GoogleSignInUseCase>(),
          getAuthState: gh<_i111.GetAuthStateUseCase>(),
          onboarding: gh<_i120.OnboardingUseCase>(),
        ));
    gh.lazySingleton<_i145.DeleteAudioTrack>(() => _i145.DeleteAudioTrack(
          gh<_i73.SessionStorage>(),
          gh<_i35.ProjectsRepository>(),
          gh<_i124.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i146.EditAudioTrackUseCase>(
        () => _i146.EditAudioTrackUseCase(
              gh<_i124.ProjectTrackService>(),
              gh<_i35.ProjectsRepository>(),
            ));
    gh.factory<_i147.PlaylistCacheBloc>(() => _i147.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i103.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i112.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i127.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i148.StartupResourceManager>(
        () => _i148.StartupResourceManager(
              gh<_i74.SyncAudioCommentsUseCase>(),
              gh<_i75.SyncAudioTracksUseCase>(),
              gh<_i76.SyncProjectsUseCase>(),
              gh<_i77.SyncUserProfileUseCase>(),
              gh<_i133.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i149.TrackCacheBloc>(() => _i149.TrackCacheBloc(
          cacheTrackUseCase: gh<_i104.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i137.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i128.RemoveTrackCacheUseCase>(),
        ));
    gh.lazySingleton<_i150.AddCollaboratorAndSyncProfileService>(
        () => _i150.AddCollaboratorAndSyncProfileService(
              gh<_i138.AddCollaboratorToProjectUseCase>(),
              gh<_i80.UserProfileCacheRepository>(),
            ));
    gh.factory<_i151.AudioPlayerBloc>(() => _i151.AudioPlayerBloc(
        audioPlayerService: gh<_i141.AudioPlayerService>()));
    gh.factory<_i152.AudioTrackBloc>(() => _i152.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i85.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i145.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i135.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i146.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i153.ManageCollaboratorsBloc>(
        () => _i153.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i150.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i126.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i134.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i115.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i87.WatchUserProfilesUseCase>(),
            ));
    return this;
  }
}

class _$AppModule extends _i154.AppModule {}
