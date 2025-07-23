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
import 'package:shared_preferences/shared_preferences.dart' as _i47;
import 'package:trackflow/core/app_flow/domain/services/app_flow_coordinator.dart'
    as _i163;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i168;
import 'package:trackflow/core/di/app_module.dart' as _i169;
import 'package:trackflow/core/network/network_info.dart' as _i27;
import 'package:trackflow/core/network/network_state_manager.dart' as _i28;
import 'package:trackflow/core/router/navigation_service.dart' as _i26;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/session/data/session_storage.dart' as _i68;
import 'package:trackflow/core/session/domain/services/session_service.dart'
    as _i162;
import 'package:trackflow/core/session/domain/usecases/check_authentication_status_usecase.dart'
    as _i91;
import 'package:trackflow/core/session/domain/usecases/get_auth_state_usecase.dart'
    as _i93;
import 'package:trackflow/core/session/domain/usecases/get_current_user_id_usecase.dart'
    as _i95;
import 'package:trackflow/core/session/domain/usecases/get_current_user_usecase.dart'
    as _i96;
import 'package:trackflow/core/session/domain/usecases/sign_out_usecase.dart'
    as _i147;
import 'package:trackflow/core/sync/background_sync_coordinator.dart' as _i114;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i31;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i32;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i78;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i83;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i29;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i67;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i75;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i66;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i129;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i97;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i141;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i61;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i62;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i80;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i82;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i87;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i89;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i79;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i81;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i86;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i88;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i90;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i94;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i106;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i113;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i57;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i126;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i125;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i142;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i153;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i158;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i151;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i164;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i109;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i154;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i161;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i155;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i165;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i33;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i156;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i107;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i30;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i139;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i140;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i34;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i108;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i166;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i58;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i59;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i128;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i127;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i143;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i159;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i160;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i70;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i149;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i152;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i167;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i85;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i84;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i134;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i146;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i104;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i157;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i21;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i22;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i24;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i23;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i63;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i92;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i64;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i41;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i55;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i137;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i124;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i135;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i136;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i117;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i118;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i77;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i138;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i25;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i65;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i99;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i100;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i98;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i110;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i35;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i36;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i38;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i37;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i76;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i101;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i40;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i39;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i116;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i115;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i131;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i132;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i133;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i71;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i119;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i122;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i144;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i53;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i54;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i74;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i121;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i120;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i73;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i130;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i105;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i72;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i148;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i123;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i150;

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
    gh.factory<_i26.NavigationService>(() => _i26.NavigationService());
    gh.lazySingleton<_i27.NetworkInfo>(
        () => _i27.NetworkInfoImpl(gh<_i19.InternetConnectionChecker>()));
    gh.lazySingleton<_i28.NetworkStateManager>(() => _i28.NetworkStateManager(
          gh<_i19.InternetConnectionChecker>(),
          gh<_i9.Connectivity>(),
        ));
    gh.factory<_i29.OperationExecutorFactory>(
        () => _i29.OperationExecutorFactory());
    gh.factory<_i30.PauseAudioUseCase>(() => _i30.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i31.PendingOperationsLocalDataSource>(
        () => _i31.IsarPendingOperationsLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i32.PendingOperationsRepository>(() =>
        _i32.PendingOperationsRepositoryImpl(
            gh<_i31.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i33.PlaybackPersistenceRepository>(
        () => _i34.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i35.PlaylistLocalDataSource>(
        () => _i35.PlaylistLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i36.PlaylistRemoteDataSource>(
        () => _i36.PlaylistRemoteDataSourceImpl(gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i37.PlaylistRepository>(() => _i38.PlaylistRepositoryImpl(
          localDataSource: gh<_i35.PlaylistLocalDataSource>(),
          remoteDataSource: gh<_i36.PlaylistRemoteDataSource>(),
        ));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i39.ProjectRemoteDataSource>(() =>
        _i39.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i40.ProjectsLocalDataSource>(
        () => _i40.ProjectsLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i41.ResendMagicLinkUseCase>(
        () => _i41.ResendMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.factory<_i42.ResumeAudioUseCase>(() => _i42.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i43.SavePlaybackStateUseCase>(
        () => _i43.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i33.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i44.SeekAudioUseCase>(() =>
        _i44.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i45.SetPlaybackSpeedUseCase>(() => _i45.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i46.SetVolumeUseCase>(() =>
        _i46.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i47.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i48.SkipToNextUseCase>(() => _i48.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i49.SkipToPreviousUseCase>(() => _i49.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i50.StopAudioUseCase>(() =>
        _i50.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i51.ToggleRepeatModeUseCase>(() => _i51.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i52.ToggleShuffleUseCase>(() => _i52.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i53.UserProfileLocalDataSource>(
        () => _i53.IsarUserProfileLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i54.UserProfileRemoteDataSource>(
        () => _i54.UserProfileRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i55.ValidateMagicLinkUseCase>(
        () => _i55.ValidateMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i56.AudioCommentLocalDataSource>(
        () => _i56.IsarAudioCommentLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i57.AudioCommentRemoteDataSource>(() =>
        _i57.FirebaseAudioCommentRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i58.AudioTrackLocalDataSource>(
        () => _i58.IsarAudioTrackLocalDataSource(gh<_i20.Isar>()));
    gh.lazySingleton<_i59.AudioTrackRemoteDataSource>(
        () => _i59.AudioTrackRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i60.AuthRemoteDataSource>(
        () => _i60.AuthRemoteDataSourceImpl(
              gh<_i13.FirebaseAuth>(),
              gh<_i17.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i61.CacheStorageLocalDataSource>(
        () => _i61.CacheStorageLocalDataSourceImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i62.CacheStorageRemoteDataSource>(() =>
        _i62.CacheStorageRemoteDataSourceImpl(gh<_i15.FirebaseStorage>()));
    gh.lazySingleton<_i63.ConsumeMagicLinkUseCase>(
        () => _i63.ConsumeMagicLinkUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i64.GetMagicLinkStatusUseCase>(
        () => _i64.GetMagicLinkStatusUseCase(gh<_i23.MagicLinkRepository>()));
    gh.lazySingleton<_i28.NetworkInfo>(
        () => _i28.NetworkInfoImpl(gh<_i28.NetworkStateManager>()));
    gh.lazySingleton<_i65.OnboardingStateLocalDataSource>(() =>
        _i65.OnboardingStateLocalDataSourceImpl(gh<_i47.SharedPreferences>()));
    gh.lazySingleton<_i66.PendingOperationsManager>(
        () => _i66.PendingOperationsManager(
              gh<_i32.PendingOperationsRepository>(),
              gh<_i28.NetworkStateManager>(),
              gh<_i29.OperationExecutorFactory>(),
            ));
    gh.factory<_i67.ProjectOperationExecutor>(() =>
        _i67.ProjectOperationExecutor(gh<_i39.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i68.SessionStorage>(
        () => _i68.SessionStorageImpl(prefs: gh<_i47.SharedPreferences>()));
    gh.lazySingleton<_i69.SyncAudioCommentsUseCase>(
        () => _i69.SyncAudioCommentsUseCase(
              gh<_i57.AudioCommentRemoteDataSource>(),
              gh<_i56.AudioCommentLocalDataSource>(),
              gh<_i39.ProjectRemoteDataSource>(),
              gh<_i68.SessionStorage>(),
              gh<_i59.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i70.SyncAudioTracksUseCase>(
        () => _i70.SyncAudioTracksUseCase(
              gh<_i59.AudioTrackRemoteDataSource>(),
              gh<_i58.AudioTrackLocalDataSource>(),
              gh<_i39.ProjectRemoteDataSource>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i71.SyncProjectsUseCase>(() => _i71.SyncProjectsUseCase(
          gh<_i39.ProjectRemoteDataSource>(),
          gh<_i40.ProjectsLocalDataSource>(),
          gh<_i68.SessionStorage>(),
        ));
    gh.lazySingleton<_i72.SyncUserProfileUseCase>(
        () => _i72.SyncUserProfileUseCase(
              gh<_i54.UserProfileRemoteDataSource>(),
              gh<_i53.UserProfileLocalDataSource>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i73.UserProfileCacheRepository>(
        () => _i74.UserProfileCacheRepositoryImpl(
              gh<_i54.UserProfileRemoteDataSource>(),
              gh<_i53.UserProfileLocalDataSource>(),
              gh<_i27.NetworkInfo>(),
            ));
    gh.factory<_i75.UserProfileOperationExecutor>(() =>
        _i75.UserProfileOperationExecutor(
            gh<_i54.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i76.WatchProjectDetailUseCase>(
        () => _i76.WatchProjectDetailUseCase(
              gh<_i58.AudioTrackLocalDataSource>(),
              gh<_i53.UserProfileLocalDataSource>(),
              gh<_i56.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i77.WatchUserProfilesUseCase>(() =>
        _i77.WatchUserProfilesUseCase(gh<_i73.UserProfileCacheRepository>()));
    gh.factory<_i78.AudioCommentOperationExecutor>(() =>
        _i78.AudioCommentOperationExecutor(
            gh<_i57.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i79.AudioDownloadRepository>(() =>
        _i80.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i62.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i81.AudioStorageRepository>(() =>
        _i82.AudioStorageRepositoryImpl(
            localDataSource: gh<_i61.CacheStorageLocalDataSource>()));
    gh.factory<_i83.AudioTrackOperationExecutor>(() =>
        _i83.AudioTrackOperationExecutor(
            gh<_i59.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i84.AuthRepository>(() => _i85.AuthRepositoryImpl(
          remote: gh<_i60.AuthRemoteDataSource>(),
          sessionStorage: gh<_i68.SessionStorage>(),
          networkInfo: gh<_i27.NetworkInfo>(),
        ));
    gh.lazySingleton<_i86.CacheKeyRepository>(() => _i87.CacheKeyRepositoryImpl(
        localDataSource: gh<_i61.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i88.CacheMaintenanceRepository>(() =>
        _i89.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i61.CacheStorageLocalDataSource>()));
    gh.factory<_i90.CacheTrackUseCase>(() => _i90.CacheTrackUseCase(
          gh<_i79.AudioDownloadRepository>(),
          gh<_i81.AudioStorageRepository>(),
        ));
    gh.factory<_i91.CheckAuthenticationStatusUseCase>(
        () => _i91.CheckAuthenticationStatusUseCase(gh<_i84.AuthRepository>()));
    gh.lazySingleton<_i92.GenerateMagicLinkUseCase>(
        () => _i92.GenerateMagicLinkUseCase(
              gh<_i23.MagicLinkRepository>(),
              gh<_i84.AuthRepository>(),
            ));
    gh.lazySingleton<_i93.GetAuthStateUseCase>(
        () => _i93.GetAuthStateUseCase(gh<_i84.AuthRepository>()));
    gh.factory<_i94.GetCachedTrackPathUseCase>(() =>
        _i94.GetCachedTrackPathUseCase(gh<_i81.AudioStorageRepository>()));
    gh.factory<_i95.GetCurrentUserIdUseCase>(
        () => _i95.GetCurrentUserIdUseCase(gh<_i84.AuthRepository>()));
    gh.factory<_i96.GetCurrentUserUseCase>(
        () => _i96.GetCurrentUserUseCase(gh<_i84.AuthRepository>()));
    gh.factory<_i97.GetPlaylistCacheStatusUseCase>(() =>
        _i97.GetPlaylistCacheStatusUseCase(gh<_i81.AudioStorageRepository>()));
    gh.lazySingleton<_i98.OnboardingRepository>(() =>
        _i99.OnboardingRepositoryImpl(
            gh<_i65.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i100.OnboardingUseCase>(
        () => _i100.OnboardingUseCase(gh<_i98.OnboardingRepository>()));
    gh.factory<_i101.ProjectDetailBloc>(() => _i101.ProjectDetailBloc(
        watchProjectDetail: gh<_i76.WatchProjectDetailUseCase>()));
    gh.factory<_i102.RemovePlaylistCacheUseCase>(() =>
        _i102.RemovePlaylistCacheUseCase(gh<_i81.AudioStorageRepository>()));
    gh.factory<_i103.RemoveTrackCacheUseCase>(
        () => _i103.RemoveTrackCacheUseCase(gh<_i81.AudioStorageRepository>()));
    gh.lazySingleton<_i104.SignUpUseCase>(
        () => _i104.SignUpUseCase(gh<_i84.AuthRepository>()));
    gh.lazySingleton<_i105.SyncUserProfileCollaboratorsUseCase>(
        () => _i105.SyncUserProfileCollaboratorsUseCase(
              gh<_i40.ProjectsLocalDataSource>(),
              gh<_i73.UserProfileCacheRepository>(),
            ));
    gh.factory<_i106.WatchTrackCacheStatusUseCase>(() =>
        _i106.WatchTrackCacheStatusUseCase(gh<_i81.AudioStorageRepository>()));
    gh.factory<_i107.AudioSourceResolver>(() => _i108.AudioSourceResolverImpl(
          gh<_i81.AudioStorageRepository>(),
          gh<_i79.AudioDownloadRepository>(),
        ));
    gh.factory<_i109.AudioWaveformBloc>(() => _i109.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i94.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i110.OnboardingBloc>(() => _i110.OnboardingBloc(
          onboardingUseCase: gh<_i100.OnboardingUseCase>(),
          getCurrentUserIdUseCase: gh<_i95.GetCurrentUserIdUseCase>(),
        ));
    gh.factory<_i111.SyncDataManager>(() => _i111.SyncDataManager(
          syncProjects: gh<_i71.SyncProjectsUseCase>(),
          syncAudioTracks: gh<_i70.SyncAudioTracksUseCase>(),
          syncAudioComments: gh<_i69.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i72.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i105.SyncUserProfileCollaboratorsUseCase>(),
        ));
    gh.factory<_i112.SyncStatusProvider>(() => _i112.SyncStatusProvider(
          syncDataManager: gh<_i111.SyncDataManager>(),
          pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
        ));
    gh.factory<_i113.TrackCacheBloc>(() => _i113.TrackCacheBloc(
          cacheTrackUseCase: gh<_i90.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i106.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i103.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i94.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i114.BackgroundSyncCoordinator>(
        () => _i114.BackgroundSyncCoordinator(
              gh<_i28.NetworkStateManager>(),
              gh<_i111.SyncDataManager>(),
              gh<_i66.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i115.ProjectsRepository>(
        () => _i116.ProjectsRepositoryImpl(
              remoteDataSource: gh<_i39.ProjectRemoteDataSource>(),
              localDataSource: gh<_i40.ProjectsLocalDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i114.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i117.RemoveCollaboratorUseCase>(
        () => _i117.RemoveCollaboratorUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i118.UpdateCollaboratorRoleUseCase>(
        () => _i118.UpdateCollaboratorRoleUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i119.UpdateProjectUseCase>(
        () => _i119.UpdateProjectUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i120.UserProfileRepository>(
        () => _i121.UserProfileRepositoryImpl(
              localDataSource: gh<_i53.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i54.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i114.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
              firestore: gh<_i14.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i122.WatchAllProjectsUseCase>(
        () => _i122.WatchAllProjectsUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i123.WatchUserProfileUseCase>(
        () => _i123.WatchUserProfileUseCase(
              gh<_i120.UserProfileRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i124.AddCollaboratorToProjectUseCase>(
        () => _i124.AddCollaboratorToProjectUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i125.AudioCommentRepository>(
        () => _i126.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i57.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i56.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i114.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i127.AudioTrackRepository>(
        () => _i128.AudioTrackRepositoryImpl(
              gh<_i59.AudioTrackRemoteDataSource>(),
              gh<_i58.AudioTrackLocalDataSource>(),
              gh<_i28.NetworkStateManager>(),
              gh<_i114.BackgroundSyncCoordinator>(),
              gh<_i66.PendingOperationsManager>(),
            ));
    gh.factory<_i129.CachePlaylistUseCase>(() => _i129.CachePlaylistUseCase(
          gh<_i79.AudioDownloadRepository>(),
          gh<_i127.AudioTrackRepository>(),
        ));
    gh.factory<_i130.CheckProfileCompletenessUseCase>(() =>
        _i130.CheckProfileCompletenessUseCase(
            gh<_i120.UserProfileRepository>()));
    gh.lazySingleton<_i131.CreateProjectUseCase>(
        () => _i131.CreateProjectUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i132.DeleteProjectUseCase>(
        () => _i132.DeleteProjectUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i133.GetProjectByIdUseCase>(
        () => _i133.GetProjectByIdUseCase(gh<_i115.ProjectsRepository>()));
    gh.lazySingleton<_i134.GoogleSignInUseCase>(() => _i134.GoogleSignInUseCase(
          gh<_i84.AuthRepository>(),
          gh<_i120.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i135.JoinProjectWithIdUseCase>(
        () => _i135.JoinProjectWithIdUseCase(
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i136.LeaveProjectUseCase>(() => _i136.LeaveProjectUseCase(
          gh<_i115.ProjectsRepository>(),
          gh<_i68.SessionStorage>(),
        ));
    gh.factory<_i137.MagicLinkBloc>(() => _i137.MagicLinkBloc(
          generateMagicLink: gh<_i92.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i55.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i63.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i41.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i64.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i135.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i84.AuthRepository>(),
        ));
    gh.factory<_i138.ManageCollaboratorsBloc>(() =>
        _i138.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i124.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i117.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i118.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i136.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i77.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i139.PlayAudioUseCase>(() => _i139.PlayAudioUseCase(
          audioTrackRepository: gh<_i127.AudioTrackRepository>(),
          audioStorageRepository: gh<_i81.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i140.PlayPlaylistUseCase>(() => _i140.PlayPlaylistUseCase(
          playlistRepository: gh<_i37.PlaylistRepository>(),
          audioTrackRepository: gh<_i127.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i81.AudioStorageRepository>(),
        ));
    gh.factory<_i141.PlaylistCacheBloc>(() => _i141.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i129.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i97.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i102.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i142.ProjectCommentService>(
        () => _i142.ProjectCommentService(gh<_i125.AudioCommentRepository>()));
    gh.lazySingleton<_i143.ProjectTrackService>(() => _i143.ProjectTrackService(
          gh<_i127.AudioTrackRepository>(),
          gh<_i81.AudioStorageRepository>(),
        ));
    gh.factory<_i144.ProjectsBloc>(() => _i144.ProjectsBloc(
          createProject: gh<_i131.CreateProjectUseCase>(),
          updateProject: gh<_i119.UpdateProjectUseCase>(),
          deleteProject: gh<_i132.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i122.WatchAllProjectsUseCase>(),
          syncStatusProvider: gh<_i112.SyncStatusProvider>(),
        ));
    gh.factory<_i145.RestorePlaybackStateUseCase>(
        () => _i145.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i33.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i127.AudioTrackRepository>(),
              audioStorageRepository: gh<_i81.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i146.SignInUseCase>(() => _i146.SignInUseCase(
          gh<_i84.AuthRepository>(),
          gh<_i120.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i147.SignOutUseCase>(() => _i147.SignOutUseCase(
          gh<_i84.AuthRepository>(),
          gh<_i120.UserProfileRepository>(),
        ));
    gh.factory<_i148.UpdateUserProfileUseCase>(
        () => _i148.UpdateUserProfileUseCase(
              gh<_i120.UserProfileRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i149.UploadAudioTrackUseCase>(
        () => _i149.UploadAudioTrackUseCase(
              gh<_i143.ProjectTrackService>(),
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.factory<_i150.UserProfileBloc>(() => _i150.UserProfileBloc(
          updateUserProfileUseCase: gh<_i148.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i123.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i130.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i151.WatchCommentsByTrackUseCase>(() =>
        _i151.WatchCommentsByTrackUseCase(gh<_i142.ProjectCommentService>()));
    gh.lazySingleton<_i152.WatchTracksByProjectIdUseCase>(() =>
        _i152.WatchTracksByProjectIdUseCase(gh<_i127.AudioTrackRepository>()));
    gh.lazySingleton<_i153.AddAudioCommentUseCase>(
        () => _i153.AddAudioCommentUseCase(
              gh<_i142.ProjectCommentService>(),
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i154.AudioContextService>(
        () => _i155.AudioContextServiceImpl(
              userProfileRepository: gh<_i120.UserProfileRepository>(),
              audioTrackRepository: gh<_i127.AudioTrackRepository>(),
              projectsRepository: gh<_i115.ProjectsRepository>(),
            ));
    gh.factory<_i156.AudioPlayerService>(() => _i156.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i18.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i139.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i140.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i30.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i42.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i50.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i48.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i49.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i44.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i52.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i51.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i46.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i45.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i43.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i145.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i157.AuthBloc>(() => _i157.AuthBloc(
          signIn: gh<_i146.SignInUseCase>(),
          signUp: gh<_i104.SignUpUseCase>(),
          googleSignIn: gh<_i134.GoogleSignInUseCase>(),
        ));
    gh.lazySingleton<_i158.DeleteAudioCommentUseCase>(
        () => _i158.DeleteAudioCommentUseCase(
              gh<_i142.ProjectCommentService>(),
              gh<_i115.ProjectsRepository>(),
              gh<_i68.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.DeleteAudioTrack>(() => _i159.DeleteAudioTrack(
          gh<_i68.SessionStorage>(),
          gh<_i115.ProjectsRepository>(),
          gh<_i143.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i160.EditAudioTrackUseCase>(
        () => _i160.EditAudioTrackUseCase(
              gh<_i143.ProjectTrackService>(),
              gh<_i115.ProjectsRepository>(),
            ));
    gh.factory<_i161.LoadTrackContextUseCase>(
        () => _i161.LoadTrackContextUseCase(gh<_i154.AudioContextService>()));
    gh.factory<_i162.SessionService>(() => _i162.SessionService(
          checkAuthUseCase: gh<_i91.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i96.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i100.OnboardingUseCase>(),
          profileUseCase: gh<_i130.CheckProfileCompletenessUseCase>(),
          signOutUseCase: gh<_i147.SignOutUseCase>(),
        ));
    gh.lazySingleton<_i163.AppFlowCoordinator>(() => _i163.AppFlowCoordinator(
          sessionService: gh<_i162.SessionService>(),
          syncDataManager: gh<_i111.SyncDataManager>(),
        ));
    gh.factory<_i164.AudioCommentBloc>(() => _i164.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i151.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i153.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i158.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i77.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i165.AudioContextBloc>(() => _i165.AudioContextBloc(
        loadTrackContextUseCase: gh<_i161.LoadTrackContextUseCase>()));
    gh.factory<_i166.AudioPlayerBloc>(() => _i166.AudioPlayerBloc(
        audioPlayerService: gh<_i156.AudioPlayerService>()));
    gh.factory<_i167.AudioTrackBloc>(() => _i167.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i152.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i159.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i149.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i160.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i168.AppFlowBloc>(
        () => _i168.AppFlowBloc(coordinator: gh<_i163.AppFlowCoordinator>()));
    return this;
  }
}

class _$AppModule extends _i169.AppModule {}
