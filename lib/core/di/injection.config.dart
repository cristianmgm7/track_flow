// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i12;

import 'package:cloud_firestore/cloud_firestore.dart' as _i15;
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:firebase_auth/firebase_auth.dart' as _i14;
import 'package:firebase_storage/firebase_storage.dart' as _i16;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i18;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i20;
import 'package:isar/isar.dart' as _i21;
import 'package:shared_preferences/shared_preferences.dart' as _i47;
import 'package:trackflow/core/app_flow/domain/services/app_flow_coordinator.dart'
    as _i171;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i176;
import 'package:trackflow/core/di/app_module.dart' as _i177;
import 'package:trackflow/core/network/network_info.dart' as _i28;
import 'package:trackflow/core/network/network_state_manager.dart' as _i29;
import 'package:trackflow/core/router/navigation_service.dart' as _i27;
import 'package:trackflow/core/services/app_initialization_coordinator.dart'
    as _i3;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i65;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i13;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i34;
import 'package:trackflow/core/session/data/session_storage.dart' as _i74;
import 'package:trackflow/core/session/domain/services/session_service.dart'
    as _i170;
import 'package:trackflow/core/session/domain/usecases/check_authentication_status_usecase.dart'
    as _i97;
import 'package:trackflow/core/session/domain/usecases/get_auth_state_usecase.dart'
    as _i99;
import 'package:trackflow/core/session/domain/usecases/get_current_user_id_usecase.dart'
    as _i101;
import 'package:trackflow/core/session/domain/usecases/get_current_user_usecase.dart'
    as _i102;
import 'package:trackflow/core/session/domain/usecases/sign_out_usecase.dart'
    as _i155;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i32;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i33;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i84;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i89;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i30;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i72;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i73;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i81;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i120;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i6;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i67;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i71;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i117;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i51;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i75;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i76;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_usecase.dart'
    as _i77;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i78;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i137;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i149;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i62;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i63;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i86;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i88;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i93;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i95;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i85;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i87;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i92;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i94;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i9;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i17;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i119;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i57;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i58;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i134;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i133;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i150;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i161;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i166;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i159;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i172;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i115;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i162;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i169;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i163;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i173;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i35;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i4;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i164;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i113;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i19;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i31;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i147;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i148;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i153;
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
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i36;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i5;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i114;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i174;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i59;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i136;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i135;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i151;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i167;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i168;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i157;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i160;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i175;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i61;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i91;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i90;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i142;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i154;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i110;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i165;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i22;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i23;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i25;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i24;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i64;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i98;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i41;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i56;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i145;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i132;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i143;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i144;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i125;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i126;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i83;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i146;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i26;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i70;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i105;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i106;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i104;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i116;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i37;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i38;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i122;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i121;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i82;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i107;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i40;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i39;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i68;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i124;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i69;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i123;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i139;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i140;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i141;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i127;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i130;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i152;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i54;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i55;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i80;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i129;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i128;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i79;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i138;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i156;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i131;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i158;

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
    gh.factory<_i3.AppInitializationCoordinator>(
        () => _i3.AppInitializationCoordinator());
    gh.lazySingleton<_i4.AudioPlaybackService>(
        () => _i5.AudioPlaybackServiceImpl());
    gh.lazySingleton<_i6.AudioTrackConflictResolutionService>(
        () => _i6.AudioTrackConflictResolutionService());
    gh.lazySingleton<_i7.CacheMaintenanceService>(
        () => _i8.CacheMaintenanceServiceImpl());
    gh.factory<_i9.CleanupCacheUseCase>(
        () => _i9.CleanupCacheUseCase(gh<_i7.CacheMaintenanceService>()));
    gh.lazySingleton<_i6.ConflictResolutionServiceImpl<dynamic>>(
        () => _i6.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i10.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i11.DeepLinkService>(() => _i11.DeepLinkService());
    await gh.factoryAsync<_i12.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i13.DynamicLinkService>(() => _i13.DynamicLinkService());
    gh.lazySingleton<_i14.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i15.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i16.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i17.GetCacheStorageStatsUseCase>(() =>
        _i17.GetCacheStorageStatsUseCase(gh<_i7.CacheMaintenanceService>()));
    gh.lazySingleton<_i18.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i19.InitializeAudioPlayerUseCase>(() =>
        _i19.InitializeAudioPlayerUseCase(
            playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i20.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i21.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i22.MagicLinkLocalDataSource>(
        () => _i22.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i23.MagicLinkRemoteDataSource>(
        () => _i23.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i15.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i24.MagicLinkRepository>(() =>
        _i25.MagicLinkRepositoryImp(gh<_i23.MagicLinkRemoteDataSource>()));
    gh.factory<_i26.NavigationCubit>(() => _i26.NavigationCubit());
    gh.factory<_i27.NavigationService>(() => _i27.NavigationService());
    gh.lazySingleton<_i28.NetworkInfo>(
        () => _i28.NetworkInfoImpl(gh<_i20.InternetConnectionChecker>()));
    gh.lazySingleton<_i29.NetworkStateManager>(() => _i29.NetworkStateManager(
          gh<_i20.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.factory<_i30.OperationExecutorFactory>(
        () => _i30.OperationExecutorFactory());
    gh.factory<_i31.PauseAudioUseCase>(() => _i31.PauseAudioUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i32.PendingOperationsLocalDataSource>(
        () => _i32.IsarPendingOperationsLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i33.PendingOperationsRepository>(() =>
        _i33.PendingOperationsRepositoryImpl(
            gh<_i32.PendingOperationsLocalDataSource>()));
    gh.factory<_i34.PerformanceMetricsCollector>(
        () => _i34.PerformanceMetricsCollector());
    gh.lazySingleton<_i35.PlaybackPersistenceRepository>(
        () => _i36.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i37.PlaylistLocalDataSource>(
        () => _i37.PlaylistLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i38.PlaylistRemoteDataSource>(
        () => _i38.PlaylistRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i6.ProjectConflictResolutionService>(
        () => _i6.ProjectConflictResolutionService());
    gh.lazySingleton<_i39.ProjectRemoteDataSource>(() =>
        _i39.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i40.ProjectsLocalDataSource>(
        () => _i40.ProjectsLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i41.ResendMagicLinkUseCase>(
        () => _i41.ResendMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.factory<_i42.ResumeAudioUseCase>(() => _i42.ResumeAudioUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i43.SavePlaybackStateUseCase>(
        () => _i43.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i35.PlaybackPersistenceRepository>(),
              playbackService: gh<_i4.AudioPlaybackService>(),
            ));
    gh.factory<_i44.SeekAudioUseCase>(() =>
        _i44.SeekAudioUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i45.SetPlaybackSpeedUseCase>(() => _i45.SetPlaybackSpeedUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i46.SetVolumeUseCase>(() =>
        _i46.SetVolumeUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    await gh.factoryAsync<_i47.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i48.SkipToNextUseCase>(() => _i48.SkipToNextUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i49.SkipToPreviousUseCase>(() => _i49.SkipToPreviousUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i50.StopAudioUseCase>(() =>
        _i50.StopAudioUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i51.SyncMetadataManager>(
        () => _i51.SyncMetadataManager());
    gh.factory<_i52.ToggleRepeatModeUseCase>(() => _i52.ToggleRepeatModeUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i53.ToggleShuffleUseCase>(() => _i53.ToggleShuffleUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i54.UserProfileLocalDataSource>(
        () => _i54.IsarUserProfileLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i55.UserProfileRemoteDataSource>(
        () => _i55.UserProfileRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i56.ValidateMagicLinkUseCase>(
        () => _i56.ValidateMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.lazySingleton<_i57.AudioCommentLocalDataSource>(
        () => _i57.IsarAudioCommentLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i58.AudioCommentRemoteDataSource>(() =>
        _i58.FirebaseAudioCommentRemoteDataSource(
            gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i59.AudioTrackLocalDataSource>(
        () => _i59.IsarAudioTrackLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i60.AudioTrackRemoteDataSource>(
        () => _i60.AudioTrackRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i61.AuthRemoteDataSource>(
        () => _i61.AuthRemoteDataSourceImpl(
              gh<_i14.FirebaseAuth>(),
              gh<_i18.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i62.CacheStorageLocalDataSource>(
        () => _i62.CacheStorageLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i63.CacheStorageRemoteDataSource>(() =>
        _i63.CacheStorageRemoteDataSourceImpl(gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i64.ConsumeMagicLinkUseCase>(
        () => _i64.ConsumeMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.factory<_i65.DatabaseHealthMonitor>(
        () => _i65.DatabaseHealthMonitor(gh<_i21.Isar>()));
    gh.lazySingleton<_i66.GetMagicLinkStatusUseCase>(
        () => _i66.GetMagicLinkStatusUseCase(gh<_i24.MagicLinkRepository>()));
    gh.lazySingleton<_i67.IncrementalSyncService<_i68.ProjectDTO>>(
        () => _i69.ProjectIncrementalSyncService(
              gh<_i39.ProjectRemoteDataSource>(),
              gh<_i40.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i29.NetworkInfo>(
        () => _i29.NetworkInfoImpl(gh<_i29.NetworkStateManager>()));
    gh.lazySingleton<_i70.OnboardingStateLocalDataSource>(() =>
        _i70.OnboardingStateLocalDataSourceImpl(gh<_i47.SharedPreferences>()));
    gh.lazySingleton<_i71.PendingOperationsManager>(
        () => _i71.PendingOperationsManager(
              gh<_i33.PendingOperationsRepository>(),
              gh<_i29.NetworkStateManager>(),
              gh<_i30.OperationExecutorFactory>(),
            ));
    gh.factory<_i72.PlaylistOperationExecutor>(() =>
        _i72.PlaylistOperationExecutor(gh<_i38.PlaylistRemoteDataSource>()));
    gh.factory<_i73.ProjectOperationExecutor>(() =>
        _i73.ProjectOperationExecutor(gh<_i39.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i74.SessionStorage>(
        () => _i74.SessionStorageImpl(prefs: gh<_i47.SharedPreferences>()));
    gh.lazySingleton<_i75.SyncAudioCommentsUseCase>(
        () => _i75.SyncAudioCommentsUseCase(
              gh<_i58.AudioCommentRemoteDataSource>(),
              gh<_i57.AudioCommentLocalDataSource>(),
              gh<_i39.ProjectRemoteDataSource>(),
              gh<_i74.SessionStorage>(),
              gh<_i60.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i76.SyncAudioTracksUseCase>(
        () => _i76.SyncAudioTracksUseCase(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i39.ProjectRemoteDataSource>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i77.SyncProjectsUseCase>(() => _i77.SyncProjectsUseCase(
          gh<_i39.ProjectRemoteDataSource>(),
          gh<_i40.ProjectsLocalDataSource>(),
          gh<_i74.SessionStorage>(),
          gh<_i21.Isar>(),
        ));
    gh.lazySingleton<_i78.SyncUserProfileUseCase>(
        () => _i78.SyncUserProfileUseCase(
              gh<_i55.UserProfileRemoteDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i79.UserProfileCacheRepository>(
        () => _i80.UserProfileCacheRepositoryImpl(
              gh<_i55.UserProfileRemoteDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i28.NetworkInfo>(),
            ));
    gh.factory<_i81.UserProfileOperationExecutor>(() =>
        _i81.UserProfileOperationExecutor(
            gh<_i55.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i82.WatchProjectDetailUseCase>(
        () => _i82.WatchProjectDetailUseCase(
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i54.UserProfileLocalDataSource>(),
              gh<_i57.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i83.WatchUserProfilesUseCase>(() =>
        _i83.WatchUserProfilesUseCase(gh<_i79.UserProfileCacheRepository>()));
    gh.factory<_i84.AudioCommentOperationExecutor>(() =>
        _i84.AudioCommentOperationExecutor(
            gh<_i58.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i85.AudioDownloadRepository>(() =>
        _i86.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i63.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i87.AudioStorageRepository>(() =>
        _i88.AudioStorageRepositoryImpl(
            localDataSource: gh<_i62.CacheStorageLocalDataSource>()));
    gh.factory<_i89.AudioTrackOperationExecutor>(() =>
        _i89.AudioTrackOperationExecutor(
            gh<_i60.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i90.AuthRepository>(() => _i91.AuthRepositoryImpl(
          remote: gh<_i61.AuthRemoteDataSource>(),
          sessionStorage: gh<_i74.SessionStorage>(),
          networkInfo: gh<_i28.NetworkInfo>(),
        ));
    gh.lazySingleton<_i92.CacheKeyRepository>(() => _i93.CacheKeyRepositoryImpl(
        localDataSource: gh<_i62.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i94.CacheMaintenanceRepository>(() =>
        _i95.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i62.CacheStorageLocalDataSource>()));
    gh.factory<_i96.CacheTrackUseCase>(() => _i96.CacheTrackUseCase(
          gh<_i85.AudioDownloadRepository>(),
          gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i97.CheckAuthenticationStatusUseCase>(
        () => _i97.CheckAuthenticationStatusUseCase(gh<_i90.AuthRepository>()));
    gh.lazySingleton<_i98.GenerateMagicLinkUseCase>(
        () => _i98.GenerateMagicLinkUseCase(
              gh<_i24.MagicLinkRepository>(),
              gh<_i90.AuthRepository>(),
            ));
    gh.lazySingleton<_i99.GetAuthStateUseCase>(
        () => _i99.GetAuthStateUseCase(gh<_i90.AuthRepository>()));
    gh.factory<_i100.GetCachedTrackPathUseCase>(() =>
        _i100.GetCachedTrackPathUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i101.GetCurrentUserIdUseCase>(
        () => _i101.GetCurrentUserIdUseCase(gh<_i90.AuthRepository>()));
    gh.factory<_i102.GetCurrentUserUseCase>(
        () => _i102.GetCurrentUserUseCase(gh<_i90.AuthRepository>()));
    gh.factory<_i103.GetPlaylistCacheStatusUseCase>(() =>
        _i103.GetPlaylistCacheStatusUseCase(gh<_i87.AudioStorageRepository>()));
    gh.lazySingleton<_i104.OnboardingRepository>(() =>
        _i105.OnboardingRepositoryImpl(
            gh<_i70.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i106.OnboardingUseCase>(
        () => _i106.OnboardingUseCase(gh<_i104.OnboardingRepository>()));
    gh.factory<_i107.ProjectDetailBloc>(() => _i107.ProjectDetailBloc(
        watchProjectDetail: gh<_i82.WatchProjectDetailUseCase>()));
    gh.factory<_i108.RemovePlaylistCacheUseCase>(() =>
        _i108.RemovePlaylistCacheUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i109.RemoveTrackCacheUseCase>(
        () => _i109.RemoveTrackCacheUseCase(gh<_i87.AudioStorageRepository>()));
    gh.lazySingleton<_i110.SignUpUseCase>(
        () => _i110.SignUpUseCase(gh<_i90.AuthRepository>()));
    gh.lazySingleton<_i111.SyncUserProfileCollaboratorsUseCase>(
        () => _i111.SyncUserProfileCollaboratorsUseCase(
              gh<_i40.ProjectsLocalDataSource>(),
              gh<_i79.UserProfileCacheRepository>(),
            ));
    gh.factory<_i112.WatchTrackCacheStatusUseCase>(() =>
        _i112.WatchTrackCacheStatusUseCase(gh<_i87.AudioStorageRepository>()));
    gh.factory<_i113.AudioSourceResolver>(() => _i114.AudioSourceResolverImpl(
          gh<_i87.AudioStorageRepository>(),
          gh<_i85.AudioDownloadRepository>(),
        ));
    gh.factory<_i115.AudioWaveformBloc>(() => _i115.AudioWaveformBloc(
          audioPlaybackService: gh<_i4.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i100.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i116.OnboardingBloc>(() => _i116.OnboardingBloc(
          onboardingUseCase: gh<_i106.OnboardingUseCase>(),
          getCurrentUserIdUseCase: gh<_i101.GetCurrentUserIdUseCase>(),
        ));
    gh.factory<_i117.SyncDataManager>(() => _i117.SyncDataManager(
          syncProjects: gh<_i77.SyncProjectsUseCase>(),
          syncAudioTracks: gh<_i76.SyncAudioTracksUseCase>(),
          syncAudioComments: gh<_i75.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i78.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i111.SyncUserProfileCollaboratorsUseCase>(),
        ));
    gh.factory<_i118.SyncStatusProvider>(() => _i118.SyncStatusProvider(
          syncDataManager: gh<_i117.SyncDataManager>(),
          pendingOperationsManager: gh<_i71.PendingOperationsManager>(),
        ));
    gh.factory<_i119.TrackCacheBloc>(() => _i119.TrackCacheBloc(
          cacheTrackUseCase: gh<_i96.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i112.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i109.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i100.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i120.BackgroundSyncCoordinator>(
        () => _i120.BackgroundSyncCoordinator(
              gh<_i29.NetworkStateManager>(),
              gh<_i117.SyncDataManager>(),
              gh<_i71.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i121.PlaylistRepository>(
        () => _i122.PlaylistRepositoryImpl(
              localDataSource: gh<_i37.PlaylistLocalDataSource>(),
              remoteDataSource: gh<_i38.PlaylistRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i120.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i71.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i123.ProjectsRepository>(
        () => _i124.ProjectsRepositoryImpl(
              remoteDataSource: gh<_i39.ProjectRemoteDataSource>(),
              localDataSource: gh<_i40.ProjectsLocalDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i120.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i71.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i125.RemoveCollaboratorUseCase>(
        () => _i125.RemoveCollaboratorUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i126.UpdateCollaboratorRoleUseCase>(
        () => _i126.UpdateCollaboratorRoleUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i127.UpdateProjectUseCase>(
        () => _i127.UpdateProjectUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i128.UserProfileRepository>(
        () => _i129.UserProfileRepositoryImpl(
              localDataSource: gh<_i54.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i55.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i120.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i71.PendingOperationsManager>(),
              firestore: gh<_i15.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i130.WatchAllProjectsUseCase>(
        () => _i130.WatchAllProjectsUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i131.WatchUserProfileUseCase>(
        () => _i131.WatchUserProfileUseCase(
              gh<_i128.UserProfileRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i132.AddCollaboratorToProjectUseCase>(
        () => _i132.AddCollaboratorToProjectUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i133.AudioCommentRepository>(
        () => _i134.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i58.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i57.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i120.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i71.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i135.AudioTrackRepository>(
        () => _i136.AudioTrackRepositoryImpl(
              gh<_i60.AudioTrackRemoteDataSource>(),
              gh<_i59.AudioTrackLocalDataSource>(),
              gh<_i29.NetworkStateManager>(),
              gh<_i120.BackgroundSyncCoordinator>(),
              gh<_i71.PendingOperationsManager>(),
            ));
    gh.factory<_i137.CachePlaylistUseCase>(() => _i137.CachePlaylistUseCase(
          gh<_i85.AudioDownloadRepository>(),
          gh<_i135.AudioTrackRepository>(),
        ));
    gh.factory<_i138.CheckProfileCompletenessUseCase>(() =>
        _i138.CheckProfileCompletenessUseCase(
            gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i139.CreateProjectUseCase>(
        () => _i139.CreateProjectUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i140.DeleteProjectUseCase>(
        () => _i140.DeleteProjectUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i141.GetProjectByIdUseCase>(
        () => _i141.GetProjectByIdUseCase(gh<_i123.ProjectsRepository>()));
    gh.lazySingleton<_i142.GoogleSignInUseCase>(() => _i142.GoogleSignInUseCase(
          gh<_i90.AuthRepository>(),
          gh<_i128.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i143.JoinProjectWithIdUseCase>(
        () => _i143.JoinProjectWithIdUseCase(
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i144.LeaveProjectUseCase>(() => _i144.LeaveProjectUseCase(
          gh<_i123.ProjectsRepository>(),
          gh<_i74.SessionStorage>(),
        ));
    gh.factory<_i145.MagicLinkBloc>(() => _i145.MagicLinkBloc(
          generateMagicLink: gh<_i98.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i56.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i64.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i41.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i66.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i143.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i90.AuthRepository>(),
        ));
    gh.factory<_i146.ManageCollaboratorsBloc>(() =>
        _i146.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i132.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i125.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i126.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i144.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i83.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i147.PlayAudioUseCase>(() => _i147.PlayAudioUseCase(
          audioTrackRepository: gh<_i135.AudioTrackRepository>(),
          audioStorageRepository: gh<_i87.AudioStorageRepository>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
        ));
    gh.factory<_i148.PlayPlaylistUseCase>(() => _i148.PlayPlaylistUseCase(
          playlistRepository: gh<_i121.PlaylistRepository>(),
          audioTrackRepository: gh<_i135.AudioTrackRepository>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
          audioStorageRepository: gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i149.PlaylistCacheBloc>(() => _i149.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i137.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i103.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i108.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i150.ProjectCommentService>(
        () => _i150.ProjectCommentService(gh<_i133.AudioCommentRepository>()));
    gh.lazySingleton<_i151.ProjectTrackService>(() => _i151.ProjectTrackService(
          gh<_i135.AudioTrackRepository>(),
          gh<_i87.AudioStorageRepository>(),
        ));
    gh.factory<_i152.ProjectsBloc>(() => _i152.ProjectsBloc(
          createProject: gh<_i139.CreateProjectUseCase>(),
          updateProject: gh<_i127.UpdateProjectUseCase>(),
          deleteProject: gh<_i140.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i130.WatchAllProjectsUseCase>(),
          syncStatusProvider: gh<_i118.SyncStatusProvider>(),
        ));
    gh.factory<_i153.RestorePlaybackStateUseCase>(
        () => _i153.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i35.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i135.AudioTrackRepository>(),
              audioStorageRepository: gh<_i87.AudioStorageRepository>(),
              playbackService: gh<_i4.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i154.SignInUseCase>(() => _i154.SignInUseCase(
          gh<_i90.AuthRepository>(),
          gh<_i128.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i155.SignOutUseCase>(() => _i155.SignOutUseCase(
          gh<_i90.AuthRepository>(),
          gh<_i128.UserProfileRepository>(),
        ));
    gh.factory<_i156.UpdateUserProfileUseCase>(
        () => _i156.UpdateUserProfileUseCase(
              gh<_i128.UserProfileRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i157.UploadAudioTrackUseCase>(
        () => _i157.UploadAudioTrackUseCase(
              gh<_i151.ProjectTrackService>(),
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.factory<_i158.UserProfileBloc>(() => _i158.UserProfileBloc(
          updateUserProfileUseCase: gh<_i156.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i131.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i138.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i159.WatchCommentsByTrackUseCase>(() =>
        _i159.WatchCommentsByTrackUseCase(gh<_i150.ProjectCommentService>()));
    gh.lazySingleton<_i160.WatchTracksByProjectIdUseCase>(() =>
        _i160.WatchTracksByProjectIdUseCase(gh<_i135.AudioTrackRepository>()));
    gh.lazySingleton<_i161.AddAudioCommentUseCase>(
        () => _i161.AddAudioCommentUseCase(
              gh<_i150.ProjectCommentService>(),
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i162.AudioContextService>(
        () => _i163.AudioContextServiceImpl(
              userProfileRepository: gh<_i128.UserProfileRepository>(),
              audioTrackRepository: gh<_i135.AudioTrackRepository>(),
              projectsRepository: gh<_i123.ProjectsRepository>(),
            ));
    gh.factory<_i164.AudioPlayerService>(() => _i164.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i19.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i147.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i148.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i31.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i42.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i50.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i48.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i49.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i44.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i53.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i52.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i46.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i45.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i43.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i153.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
        ));
    gh.factory<_i165.AuthBloc>(() => _i165.AuthBloc(
          signIn: gh<_i154.SignInUseCase>(),
          signUp: gh<_i110.SignUpUseCase>(),
          googleSignIn: gh<_i142.GoogleSignInUseCase>(),
        ));
    gh.lazySingleton<_i166.DeleteAudioCommentUseCase>(
        () => _i166.DeleteAudioCommentUseCase(
              gh<_i150.ProjectCommentService>(),
              gh<_i123.ProjectsRepository>(),
              gh<_i74.SessionStorage>(),
            ));
    gh.lazySingleton<_i167.DeleteAudioTrack>(() => _i167.DeleteAudioTrack(
          gh<_i74.SessionStorage>(),
          gh<_i123.ProjectsRepository>(),
          gh<_i151.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i168.EditAudioTrackUseCase>(
        () => _i168.EditAudioTrackUseCase(
              gh<_i151.ProjectTrackService>(),
              gh<_i123.ProjectsRepository>(),
            ));
    gh.factory<_i169.LoadTrackContextUseCase>(
        () => _i169.LoadTrackContextUseCase(gh<_i162.AudioContextService>()));
    gh.factory<_i170.SessionService>(() => _i170.SessionService(
          checkAuthUseCase: gh<_i97.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i102.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i106.OnboardingUseCase>(),
          profileUseCase: gh<_i138.CheckProfileCompletenessUseCase>(),
          signOutUseCase: gh<_i155.SignOutUseCase>(),
        ));
    gh.lazySingleton<_i171.AppFlowCoordinator>(() => _i171.AppFlowCoordinator(
          sessionService: gh<_i170.SessionService>(),
          syncDataManager: gh<_i117.SyncDataManager>(),
        ));
    gh.factory<_i172.AudioCommentBloc>(() => _i172.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i159.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i161.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i166.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i83.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i173.AudioContextBloc>(() => _i173.AudioContextBloc(
        loadTrackContextUseCase: gh<_i169.LoadTrackContextUseCase>()));
    gh.factory<_i174.AudioPlayerBloc>(() => _i174.AudioPlayerBloc(
        audioPlayerService: gh<_i164.AudioPlayerService>()));
    gh.factory<_i175.AudioTrackBloc>(() => _i175.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i160.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i167.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i157.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i168.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i176.AppFlowBloc>(
        () => _i176.AppFlowBloc(coordinator: gh<_i171.AppFlowCoordinator>()));
    return this;
  }
}

class _$AppModule extends _i177.AppModule {}
