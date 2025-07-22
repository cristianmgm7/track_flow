// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i11;

import 'package:cloud_firestore/cloud_firestore.dart' as _i14;
import 'package:connectivity_plus/connectivity_plus.dart' as _i9;
import 'package:firebase_auth/firebase_auth.dart' as _i13;
import 'package:firebase_storage/firebase_storage.dart' as _i15;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i17;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i19;
import 'package:isar/isar.dart' as _i20;
import 'package:shared_preferences/shared_preferences.dart' as _i44;
import 'package:trackflow/core/di/app_module.dart' as _i161;
import 'package:trackflow/core/network/network_info.dart' as _i26;
import 'package:trackflow/core/network/network_state_manager.dart' as _i27;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/session/session_storage.dart' as _i72;
import 'package:trackflow/core/session_manager/domain/usecases/check_authentication_status_usecase.dart'
    as _i97;
import 'package:trackflow/core/session_manager/domain/usecases/get_auth_state_usecase.dart'
    as _i99;
import 'package:trackflow/core/session_manager/domain/usecases/get_current_user_id_usecase.dart'
    as _i101;
import 'package:trackflow/core/session_manager/domain/usecases/get_current_user_usecase.dart'
    as _i102;
import 'package:trackflow/core/session_manager/domain/usecases/sign_out_usecase.dart'
    as _i116;
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_bloc.dart'
    as _i143;
import 'package:trackflow/core/session_manager/services/app_session_service.dart'
    as _i131;
import 'package:trackflow/core/session_manager/services/startup_resource_manager.dart'
    as _i128;
import 'package:trackflow/core/session_manager/services/sync_state_manager.dart'
    as _i129;
import 'package:trackflow/core/sync/background_sync_coordinator.dart' as _i133;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i29;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i95;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i127;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i64;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i65;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i86;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i88;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i92;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i94;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i85;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i87;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i91;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i93;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i130;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i55;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i58;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i57;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i71;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i141;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i147;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i73;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i80;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i158;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i124;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i144;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i154;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i145;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i159;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i30;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i121;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i122;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i28;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i109;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i114;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i31;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i123;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i132;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i59;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i62;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i61;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i111;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i148;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i150;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i74;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i139;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i82;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i160;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i90;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i89;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i104;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i115;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i117;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i125;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i21;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i22;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i24;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i23;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i67;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i98;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i38;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i54;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i155;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i142;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i152;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i153;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i136;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i137;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i84;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i156;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i25;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i69;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i106;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i107;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i105;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i126;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i32;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i33;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i35;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i34;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i81;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i110;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i37;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i36;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i135;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i134;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i146;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i149;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i151;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i75;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i138;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i140;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i157;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i50;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i51;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i79;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i53;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i52;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i78;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i66;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i118;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i76;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i77;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i83;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i119;

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
    gh.lazySingleton<_i5.AudioTrackConflictResolutionService>(
        () => _i5.AudioTrackConflictResolutionService());
    gh.lazySingleton<_i6.CacheMaintenanceService>(
        () => _i7.CacheMaintenanceServiceImpl());
    gh.factory<_i8.CleanupCacheUseCase>(
        () => _i8.CleanupCacheUseCase(gh<_i6.CacheMaintenanceService>()));
    gh.lazySingleton<_i5.ConflictResolutionServiceImpl<dynamic>>(
        () => _i5.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i9.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i10.DeepLinkService>(() => _i10.DeepLinkService());
    await gh.factoryAsync<_i11.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i12.DynamicLinkService>(() => _i12.DynamicLinkService());
    gh.lazySingleton<_i13.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i14.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i15.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i16.GetCacheStorageStatsUseCase>(() =>
        _i16.GetCacheStorageStatsUseCase(gh<_i6.CacheMaintenanceService>()));
    gh.lazySingleton<_i17.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i18.InitializeAudioPlayerUseCase>(() =>
        _i18.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i19.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i20.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i21.MagicLinkLocalDataSource>(
        () => _i21.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i22.MagicLinkRemoteDataSource>(
        () => _i22.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i14.FirebaseFirestore>(),
              deepLinkService: gh<_i10.DeepLinkService>(),
            ));
    gh.factory<_i23.MagicLinkRepository>(() =>
        _i24.MagicLinkRepositoryImp(gh<_i22.MagicLinkRemoteDataSource>()));
    gh.factory<_i25.NavigationCubit>(() => _i25.NavigationCubit());
    gh.lazySingleton<_i26.NetworkInfo>(
        () => _i26.NetworkInfoImpl(gh<_i19.InternetConnectionChecker>()));
    gh.lazySingleton<_i27.NetworkStateManager>(() => _i27.NetworkStateManager(
          gh<_i19.InternetConnectionChecker>(),
          gh<_i9.Connectivity>(),
        ));
    gh.factory<_i28.PauseAudioUseCase>(() => _i28.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i29.PendingOperationsRepository>(
        () => _i29.PendingOperationsRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i30.PlaybackPersistenceRepository>(
        () => _i31.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i32.PlaylistLocalDataSource>(
        () => _i32.PlaylistLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i33.PlaylistRemoteDataSource>(
        () => _i33.PlaylistRemoteDataSourceImpl(gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i34.PlaylistRepository>(() => _i35.PlaylistRepositoryImpl(
          localDataSource: gh<_i32.PlaylistLocalDataSource>(),
          remoteDataSource: gh<_i33.PlaylistRemoteDataSource>(),
        ));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i36.ProjectRemoteDataSource>(() =>
        _i36.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i37.ProjectsLocalDataSource>(
        () => _i37.ProjectsLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i38.ResendMagicLinkUseCase>(
        () => _i38.ResendMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.factory<_i39.ResumeAudioUseCase>(() => _i39.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i40.SavePlaybackStateUseCase>(
        () => _i40.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i30.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i41.SeekAudioUseCase>(() =>
        _i41.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i42.SetPlaybackSpeedUseCase>(() => _i42.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i43.SetVolumeUseCase>(() =>
        _i43.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i44.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i45.SkipToNextUseCase>(() => _i45.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i46.SkipToPreviousUseCase>(() => _i46.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i47.StopAudioUseCase>(() =>
        _i47.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i48.ToggleRepeatModeUseCase>(() => _i48.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i49.ToggleShuffleUseCase>(() => _i49.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i50.UserProfileLocalDataSource>(
        () => _i50.IsarUserProfileLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i51.UserProfileRemoteDataSource>(
        () => _i51.UserProfileRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i52.UserProfileRepository>(
        () => _i53.UserProfileRepositoryImpl(
              localDataSource: gh<_i50.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i51.UserProfileRemoteDataSource>(),
              networkInfo: gh<_i26.NetworkInfo>(),
              firestore: gh<_i14.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i54.ValidateMagicLinkUseCase>(
        () => _i54.ValidateMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i55.AudioCommentLocalDataSource>(
        () => _i55.IsarAudioCommentLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i56.AudioCommentRemoteDataSource>(() =>
        _i56.FirebaseAudioCommentRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i57.AudioCommentRepository>(
        () => _i58.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i56.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i55.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i26.NetworkInfo>(),
            ));
    gh.lazySingleton<_i59.AudioTrackLocalDataSource>(
        () => _i59.IsarAudioTrackLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i60.AudioTrackRemoteDataSource>(
        () => _i60.AudioTrackRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i61.AudioTrackRepository>(
        () => _i62.AudioTrackRepositoryImpl(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i26.NetworkInfo>(),
            ));
    gh.lazySingleton<_i63.AuthRemoteDataSource>(
        () => _i63.AuthRemoteDataSourceImpl(
              gh<_i13.FirebaseAuth>(),
              gh<_i17.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i64.CacheStorageLocalDataSource>(
        () => _i64.CacheStorageLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i65.CacheStorageRemoteDataSource>(() =>
        _i65.CacheStorageRemoteDataSourceImpl(gh<_i15.FirebaseStorage>()));
    gh.factory<_i66.CheckProfileCompletenessUseCase>(() =>
        _i66.CheckProfileCompletenessUseCase(gh<_i52.UserProfileRepository>()));
    gh.lazySingleton<_i67.ConsumeMagicLinkUseCase>(
        () => _i67.ConsumeMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i68.GetMagicLinkStatusUseCase>(
        () => _i68.GetMagicLinkStatusUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i27.NetworkInfo>(
        () => _i27.NetworkInfoImpl(gh<_i27.NetworkStateManager>()));
    gh.lazySingleton<_i69.OnboardingStateLocalDataSource>(() =>
        _i69.OnboardingStateLocalDataSourceImpl(gh<_i44.SharedPreferences>()));
    gh.lazySingleton<_i70.PendingOperationsManager>(
        () => _i70.PendingOperationsManager(
              gh<_i29.PendingOperationsRepository>(),
              gh<_i27.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i71.ProjectCommentService>(
        () => _i71.ProjectCommentService(gh<_i57.AudioCommentRepository>()));
    gh.lazySingleton<_i72.SessionStorage>(
        () => _i72.SessionStorageImpl(prefs: gh<_i44.SharedPreferences>()));
    gh.lazySingleton<_i73.SyncAudioCommentsUseCase>(
        () => _i73.SyncAudioCommentsUseCase(
              gh<_i56.AudioCommentRemoteDataSource>(),
              gh<_i55.AudioCommentLocalDataSource>(),
              gh<_i36.ProjectRemoteDataSource>(),
              gh<_i72.SessionStorage>(),
              gh<_i60.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i74.SyncAudioTracksUseCase>(
        () => _i74.SyncAudioTracksUseCase(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i36.ProjectRemoteDataSource>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i75.SyncProjectsUseCase>(() => _i75.SyncProjectsUseCase(
          gh<_i36.ProjectRemoteDataSource>(),
          gh<_i37.ProjectsLocalDataSource>(),
          gh<_i72.SessionStorage>(),
        ));
    gh.lazySingleton<_i76.SyncUserProfileUseCase>(
        () => _i76.SyncUserProfileUseCase(
              gh<_i51.UserProfileRemoteDataSource>(),
              gh<_i50.UserProfileLocalDataSource>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.factory<_i77.UpdateUserProfileUseCase>(
        () => _i77.UpdateUserProfileUseCase(
              gh<_i52.UserProfileRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i78.UserProfileCacheRepository>(
        () => _i79.UserProfileCacheRepositoryImpl(
              gh<_i51.UserProfileRemoteDataSource>(),
              gh<_i50.UserProfileLocalDataSource>(),
              gh<_i26.NetworkInfo>(),
            ));
    gh.lazySingleton<_i80.WatchCommentsByTrackUseCase>(() =>
        _i80.WatchCommentsByTrackUseCase(gh<_i71.ProjectCommentService>()));
    gh.lazySingleton<_i81.WatchProjectDetailUseCase>(
        () => _i81.WatchProjectDetailUseCase(
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i50.UserProfileLocalDataSource>(),
              gh<_i55.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i82.WatchTracksByProjectIdUseCase>(() =>
        _i82.WatchTracksByProjectIdUseCase(gh<_i61.AudioTrackRepository>()));
    gh.lazySingleton<_i83.WatchUserProfileUseCase>(
        () => _i83.WatchUserProfileUseCase(
              gh<_i52.UserProfileRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i84.WatchUserProfilesUseCase>(() =>
        _i84.WatchUserProfilesUseCase(gh<_i78.UserProfileCacheRepository>()));
    gh.lazySingleton<_i85.AudioDownloadRepository>(() =>
        _i86.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i65.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i87.AudioStorageRepository>(() =>
        _i88.AudioStorageRepositoryImpl(
            localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i89.AuthRepository>(() => _i90.AuthRepositoryImpl(
          remote: gh<_i63.AuthRemoteDataSource>(),
          sessionStorage: gh<_i72.SessionStorage>(),
          networkInfo: gh<_i26.NetworkInfo>(),
        ));
    gh.lazySingleton<_i91.CacheKeyRepository>(() => _i92.CacheKeyRepositoryImpl(
        localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i93.CacheMaintenanceRepository>(() =>
        _i94.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i64.CacheStorageLocalDataSource>()));
    gh.factory<_i95.CachePlaylistUseCase>(() => _i95.CachePlaylistUseCase(
          gh<_i85.AudioDownloadRepository>(),
          gh<_i61.AudioTrackRepository>(),
        ));
    gh.factory<_i96.CacheTrackUseCase>(() => _i96.CacheTrackUseCase(
          gh<_i85.AudioDownloadRepository>(),
          gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i97.CheckAuthenticationStatusUseCase>(
        () => _i97.CheckAuthenticationStatusUseCase(gh<_i89.AuthRepository>()));
    gh.lazySingleton<_i98.GenerateMagicLinkUseCase>(
        () => _i98.GenerateMagicLinkUseCase(
              gh<_i23.MagicLinkRepository>(),
              gh<_i89.AuthRepository>(),
            ));
    gh.lazySingleton<_i99.GetAuthStateUseCase>(
        () => _i99.GetAuthStateUseCase(gh<_i89.AuthRepository>()));
    gh.factory<_i100.GetCachedTrackPathUseCase>(() =>
        _i100.GetCachedTrackPathUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i101.GetCurrentUserIdUseCase>(
        () => _i101.GetCurrentUserIdUseCase(gh<_i89.AuthRepository>()));
    gh.factory<_i102.GetCurrentUserUseCase>(
        () => _i102.GetCurrentUserUseCase(gh<_i89.AuthRepository>()));
    gh.factory<_i103.GetPlaylistCacheStatusUseCase>(() =>
        _i103.GetPlaylistCacheStatusUseCase(gh<_i87.AudioStorageRepository>()));
    gh.lazySingleton<_i104.GoogleSignInUseCase>(() => _i104.GoogleSignInUseCase(
          gh<_i89.AuthRepository>(),
          gh<_i52.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i105.OnboardingRepository>(() =>
        _i106.OnboardingRepositoryImpl(
            gh<_i69.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i107.OnboardingUseCase>(
        () => _i107.OnboardingUseCase(gh<_i105.OnboardingRepository>()));
    gh.factory<_i108.PlayAudioUseCase>(() => _i108.PlayAudioUseCase(
          audioTrackRepository: gh<_i61.AudioTrackRepository>(),
          audioStorageRepository: gh<_i87.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i109.PlayPlaylistUseCase>(() => _i109.PlayPlaylistUseCase(
          playlistRepository: gh<_i34.PlaylistRepository>(),
          audioTrackRepository: gh<_i61.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i110.ProjectDetailBloc>(() => _i110.ProjectDetailBloc(
        watchProjectDetail: gh<_i81.WatchProjectDetailUseCase>()));
    gh.lazySingleton<_i111.ProjectTrackService>(() => _i111.ProjectTrackService(
          gh<_i61.AudioTrackRepository>(),
          gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i112.RemovePlaylistCacheUseCase>(() =>
        _i112.RemovePlaylistCacheUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i113.RemoveTrackCacheUseCase>(
        () => _i113.RemoveTrackCacheUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i114.RestorePlaybackStateUseCase>(
        () => _i114.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i30.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i61.AudioTrackRepository>(),
              audioStorageRepository: gh<_i87.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i115.SignInUseCase>(() => _i115.SignInUseCase(
          gh<_i89.AuthRepository>(),
          gh<_i52.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i116.SignOutUseCase>(() => _i116.SignOutUseCase(
          gh<_i89.AuthRepository>(),
          gh<_i52.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i117.SignUpUseCase>(
        () => _i117.SignUpUseCase(gh<_i89.AuthRepository>()));
    gh.lazySingleton<_i118.SyncUserProfileCollaboratorsUseCase>(
        () => _i118.SyncUserProfileCollaboratorsUseCase(
              gh<_i37.ProjectsLocalDataSource>(),
              gh<_i78.UserProfileCacheRepository>(),
            ));
    gh.factory<_i119.UserProfileBloc>(() => _i119.UserProfileBloc(
          updateUserProfileUseCase: gh<_i77.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i83.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i66.CheckProfileCompletenessUseCase>(),
        ));
    gh.factory<_i120.WatchTrackCacheStatusUseCase>(() =>
        _i120.WatchTrackCacheStatusUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i121.AudioPlayerService>(() => _i121.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i18.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i108.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i109.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i28.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i39.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i47.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i45.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i46.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i41.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i49.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i48.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i43.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i42.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i40.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i114.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i122.AudioSourceResolver>(() => _i123.AudioSourceResolverImpl(
          gh<_i87.AudioStorageRepository>(),
          gh<_i85.AudioDownloadRepository>(),
        ));
    gh.factory<_i124.AudioWaveformBloc>(() => _i124.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i100.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i125.AuthBloc>(() => _i125.AuthBloc(
          signIn: gh<_i115.SignInUseCase>(),
          signUp: gh<_i117.SignUpUseCase>(),
          googleSignIn: gh<_i104.GoogleSignInUseCase>(),
        ));
    gh.factory<_i126.OnboardingBloc>(() => _i126.OnboardingBloc(
          onboardingUseCase: gh<_i107.OnboardingUseCase>(),
          getCurrentUserIdUseCase: gh<_i101.GetCurrentUserIdUseCase>(),
        ));
    gh.factory<_i127.PlaylistCacheBloc>(() => _i127.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i95.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i103.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i112.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i128.StartupResourceManager>(
        () => _i128.StartupResourceManager(
              gh<_i73.SyncAudioCommentsUseCase>(),
              gh<_i74.SyncAudioTracksUseCase>(),
              gh<_i75.SyncProjectsUseCase>(),
              gh<_i76.SyncUserProfileUseCase>(),
              gh<_i118.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.lazySingleton<_i129.SyncStateManager>(
        () => _i129.SyncStateManager(gh<_i128.StartupResourceManager>()));
    gh.factory<_i130.TrackCacheBloc>(() => _i130.TrackCacheBloc(
          cacheTrackUseCase: gh<_i96.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i120.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i113.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i100.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i131.AppSessionService>(() => _i131.AppSessionService(
          checkAuthUseCase: gh<_i97.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i102.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i107.OnboardingUseCase>(),
          profileUseCase: gh<_i66.CheckProfileCompletenessUseCase>(),
          signOutUseCase: gh<_i116.SignOutUseCase>(),
          syncStateManager: gh<_i129.SyncStateManager>(),
        ));
    gh.factory<_i132.AudioPlayerBloc>(() => _i132.AudioPlayerBloc(
        audioPlayerService: gh<_i121.AudioPlayerService>()));
    gh.lazySingleton<_i133.BackgroundSyncCoordinator>(
        () => _i133.BackgroundSyncCoordinator(
              gh<_i27.NetworkStateManager>(),
              gh<_i129.SyncStateManager>(),
              gh<_i70.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i134.ProjectsRepository>(
        () => _i135.ProjectsRepositoryImpl(
              remoteDataSource: gh<_i36.ProjectRemoteDataSource>(),
              localDataSource: gh<_i37.ProjectsLocalDataSource>(),
              networkInfo: gh<_i26.NetworkInfo>(),
              backgroundSyncCoordinator: gh<_i133.BackgroundSyncCoordinator>(),
            ));
    gh.lazySingleton<_i136.RemoveCollaboratorUseCase>(
        () => _i136.RemoveCollaboratorUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i137.UpdateCollaboratorRoleUseCase>(
        () => _i137.UpdateCollaboratorRoleUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i138.UpdateProjectUseCase>(
        () => _i138.UpdateProjectUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i139.UploadAudioTrackUseCase>(
        () => _i139.UploadAudioTrackUseCase(
              gh<_i111.ProjectTrackService>(),
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i140.WatchAllProjectsUseCase>(
        () => _i140.WatchAllProjectsUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i141.AddAudioCommentUseCase>(
        () => _i141.AddAudioCommentUseCase(
              gh<_i71.ProjectCommentService>(),
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i142.AddCollaboratorToProjectUseCase>(
        () => _i142.AddCollaboratorToProjectUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.factory<_i143.AppFlowBloc>(() => _i143.AppFlowBloc(
          sessionService: gh<_i131.AppSessionService>(),
          backgroundSyncCoordinator: gh<_i133.BackgroundSyncCoordinator>(),
        ));
    gh.lazySingleton<_i144.AudioContextService>(
        () => _i145.AudioContextServiceImpl(
              userProfileRepository: gh<_i52.UserProfileRepository>(),
              audioTrackRepository: gh<_i61.AudioTrackRepository>(),
              projectsRepository: gh<_i134.ProjectsRepository>(),
            ));
    gh.lazySingleton<_i146.CreateProjectUseCase>(
        () => _i146.CreateProjectUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i147.DeleteAudioCommentUseCase>(
        () => _i147.DeleteAudioCommentUseCase(
              gh<_i71.ProjectCommentService>(),
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i148.DeleteAudioTrack>(() => _i148.DeleteAudioTrack(
          gh<_i72.SessionStorage>(),
          gh<_i134.ProjectsRepository>(),
          gh<_i111.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i149.DeleteProjectUseCase>(
        () => _i149.DeleteProjectUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i150.EditAudioTrackUseCase>(
        () => _i150.EditAudioTrackUseCase(
              gh<_i111.ProjectTrackService>(),
              gh<_i134.ProjectsRepository>(),
            ));
    gh.lazySingleton<_i151.GetProjectByIdUseCase>(
        () => _i151.GetProjectByIdUseCase(gh<_i134.ProjectsRepository>()));
    gh.lazySingleton<_i152.JoinProjectWithIdUseCase>(
        () => _i152.JoinProjectWithIdUseCase(
              gh<_i134.ProjectsRepository>(),
              gh<_i72.SessionStorage>(),
            ));
    gh.lazySingleton<_i153.LeaveProjectUseCase>(() => _i153.LeaveProjectUseCase(
          gh<_i134.ProjectsRepository>(),
          gh<_i72.SessionStorage>(),
        ));
    gh.factory<_i154.LoadTrackContextUseCase>(
        () => _i154.LoadTrackContextUseCase(gh<_i144.AudioContextService>()));
    gh.factory<_i155.MagicLinkBloc>(() => _i155.MagicLinkBloc(
          generateMagicLink: gh<_i98.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i54.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i67.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i38.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i68.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i152.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i89.AuthRepository>(),
        ));
    gh.factory<_i156.ManageCollaboratorsBloc>(() =>
        _i156.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i142.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i136.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i137.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i153.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i84.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i157.ProjectsBloc>(() => _i157.ProjectsBloc(
          createProject: gh<_i146.CreateProjectUseCase>(),
          updateProject: gh<_i138.UpdateProjectUseCase>(),
          deleteProject: gh<_i149.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i140.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i158.AudioCommentBloc>(() => _i158.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i80.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i141.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i147.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i84.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i159.AudioContextBloc>(() => _i159.AudioContextBloc(
        loadTrackContextUseCase: gh<_i154.LoadTrackContextUseCase>()));
    gh.factory<_i160.AudioTrackBloc>(() => _i160.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i82.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i148.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i139.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i150.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i161.AppModule {}
