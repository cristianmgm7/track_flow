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
import 'package:shared_preferences/shared_preferences.dart' as _i45;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i70;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i169;
import 'package:trackflow/core/app_flow/services/app_bootstrap.dart' as _i168;
import 'package:trackflow/core/di/app_module.dart' as _i176;
import 'package:trackflow/core/network/network_state_manager.dart'
    as _i27; // ignore: implementation_imports
import 'package:trackflow/core/services/database_health_monitor.dart' as _i62;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i32;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i167;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i94;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i96;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_id_usecase.dart'
    as _i98;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i99;
import 'package:trackflow/core/app_flow/domain/usecases/sign_out_usecase.dart'
    as _i153;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i30;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i31;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i79;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i85;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i28;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i67;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i69;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i76;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i66;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i49;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i71;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i108;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i72;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i109;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i73;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i105;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i147;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i59;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i60;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i81;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i83;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i90;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i92;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i80;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i82;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i89;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i91;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i93;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i97;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i106;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i117;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i55;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i56;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i132;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i131;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i148;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i158;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i163;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i156;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i170;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i113;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i159;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i166;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i160;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i171;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i33;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i161;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i111;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i29;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i146;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i151;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i34;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i172;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i57;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i58;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i134;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i84;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i133;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i149;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i164;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i165;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i155;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i157;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i173;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i86;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i88;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i64;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i140;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i152;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i107;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i162;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i21;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i22;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i24;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i23;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i61;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i95;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i63;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i39;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i54;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i143;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i130;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i141;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i142;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i123;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i124;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i78;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i144;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i25;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i65;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i102;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i103;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i101;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i114;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i35;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i36;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i120;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i119;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i77;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i104;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i38;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i37;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i122;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i68;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i121;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i137;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i138;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i139;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i125;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i128;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i150;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i52;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i53;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i75;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i126;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i74;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i136;
import 'package:trackflow/features/user_profile/domain/usecases/get_current_user_data_usecase.dart'
    as _i174;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i154;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i129;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i175;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i3.AudioPlaybackService>(
      () => _i4.AudioPlaybackServiceImpl(),
    );
    gh.lazySingleton<_i5.AudioTrackConflictResolutionService>(
      () => _i5.AudioTrackConflictResolutionService(),
    );
    gh.lazySingleton<_i6.CacheMaintenanceService>(
      () => _i7.CacheMaintenanceServiceImpl(),
    );
    gh.factory<_i8.CleanupCacheUseCase>(
      () => _i8.CleanupCacheUseCase(gh<_i6.CacheMaintenanceService>()),
    );
    gh.lazySingleton<_i5.ConflictResolutionServiceImpl<dynamic>>(
      () => _i5.ConflictResolutionServiceImpl<dynamic>(),
    );
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
    gh.factory<_i16.GetCacheStorageStatsUseCase>(
      () => _i16.GetCacheStorageStatsUseCase(gh<_i6.CacheMaintenanceService>()),
    );
    gh.lazySingleton<_i17.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i18.InitializeAudioPlayerUseCase>(
      () => _i18.InitializeAudioPlayerUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i19.InternetConnectionChecker>(
      () => appModule.internetConnectionChecker,
    );
    await gh.factoryAsync<_i20.Isar>(() => appModule.isar, preResolve: true);
    gh.lazySingleton<_i21.MagicLinkLocalDataSource>(
      () => _i21.MagicLinkLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i22.MagicLinkRemoteDataSource>(
      () => _i22.MagicLinkRemoteDataSourceImpl(
        firestore: gh<_i14.FirebaseFirestore>(),
        deepLinkService: gh<_i10.DeepLinkService>(),
      ),
    );
    gh.factory<_i23.MagicLinkRepository>(
      () => _i24.MagicLinkRepositoryImp(gh<_i22.MagicLinkRemoteDataSource>()),
    );
    gh.factory<_i25.NavigationCubit>(() => _i25.NavigationCubit());
    gh.lazySingleton<_i27.NetworkStateManager>(
      () => _i27.NetworkStateManager(
        gh<_i19.InternetConnectionChecker>(),
        gh<_i9.Connectivity>(),
      ),
    );
    gh.factory<_i28.OperationExecutorFactory>(
      () => _i28.OperationExecutorFactory(),
    );
    gh.factory<_i29.PauseAudioUseCase>(
      () => _i29.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i30.PendingOperationsLocalDataSource>(
      () => _i30.IsarPendingOperationsLocalDataSource(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i31.PendingOperationsRepository>(
      () => _i31.PendingOperationsRepositoryImpl(
        gh<_i30.PendingOperationsLocalDataSource>(),
      ),
    );
    gh.factory<_i32.PerformanceMetricsCollector>(
      () => _i32.PerformanceMetricsCollector(),
    );
    gh.lazySingleton<_i33.PlaybackPersistenceRepository>(
      () => _i34.PlaybackPersistenceRepositoryImpl(),
    );
    gh.lazySingleton<_i35.PlaylistLocalDataSource>(
      () => _i35.PlaylistLocalDataSourceImpl(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i36.PlaylistRemoteDataSource>(
      () => _i36.PlaylistRemoteDataSourceImpl(gh<_i14.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
      () => _i5.ProjectConflictResolutionService(),
    );
    gh.lazySingleton<_i37.ProjectRemoteDataSource>(
      () => _i37.ProjectsRemoteDatasSourceImpl(
        firestore: gh<_i14.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i38.ProjectsLocalDataSource>(
      () => _i38.ProjectsLocalDataSourceImpl(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i39.ResendMagicLinkUseCase>(
      () => _i39.ResendMagicLinkUseCase(gh<_i23.MagicLinkRepository>()),
    );
    gh.factory<_i40.ResumeAudioUseCase>(
      () => _i40.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i41.SavePlaybackStateUseCase>(
      () => _i41.SavePlaybackStateUseCase(
        persistenceRepository: gh<_i33.PlaybackPersistenceRepository>(),
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i42.SeekAudioUseCase>(
      () => _i42.SeekAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i43.SetPlaybackSpeedUseCase>(
      () => _i43.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i44.SetVolumeUseCase>(
      () => _i44.SetVolumeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    await gh.factoryAsync<_i45.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i46.SkipToNextUseCase>(
      () => _i46.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i47.SkipToPreviousUseCase>(
      () => _i47.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i48.StopAudioUseCase>(
      () => _i48.StopAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i49.SyncMetadataManager>(
      () => _i49.SyncMetadataManager(),
    );
    gh.factory<_i50.ToggleRepeatModeUseCase>(
      () => _i50.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i51.ToggleShuffleUseCase>(
      () => _i51.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i52.UserProfileLocalDataSource>(
      () => _i52.IsarUserProfileLocalDataSource(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i53.UserProfileRemoteDataSource>(
      () => _i53.UserProfileRemoteDataSourceImpl(
        gh<_i14.FirebaseFirestore>(),
        gh<_i15.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i54.ValidateMagicLinkUseCase>(
      () => _i54.ValidateMagicLinkUseCase(gh<_i23.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i55.AudioCommentLocalDataSource>(
      () => _i55.IsarAudioCommentLocalDataSource(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i56.AudioCommentRemoteDataSource>(
      () => _i56.FirebaseAudioCommentRemoteDataSource(
        gh<_i14.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i57.AudioTrackLocalDataSource>(
      () => _i57.IsarAudioTrackLocalDataSource(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i58.AudioTrackRemoteDataSource>(
      () => _i58.AudioTrackRemoteDataSourceImpl(
        gh<_i14.FirebaseFirestore>(),
        gh<_i15.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i59.CacheStorageLocalDataSource>(
      () => _i59.CacheStorageLocalDataSourceImpl(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i60.CacheStorageRemoteDataSource>(
      () => _i60.CacheStorageRemoteDataSourceImpl(gh<_i15.FirebaseStorage>()),
    );
    gh.lazySingleton<_i61.ConsumeMagicLinkUseCase>(
      () => _i61.ConsumeMagicLinkUseCase(gh<_i23.MagicLinkRepository>()),
    );
    gh.factory<_i62.DatabaseHealthMonitor>(
      () => _i62.DatabaseHealthMonitor(gh<_i20.Isar>()),
    );
    gh.lazySingleton<_i63.GetMagicLinkStatusUseCase>(
      () => _i63.GetMagicLinkStatusUseCase(gh<_i23.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i64.GoogleAuthService>(
      () => _i64.GoogleAuthService(
        gh<_i17.GoogleSignIn>(),
        gh<_i13.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i65.OnboardingStateLocalDataSource>(
      () =>
          _i65.OnboardingStateLocalDataSourceImpl(gh<_i45.SharedPreferences>()),
    );
    gh.lazySingleton<_i66.PendingOperationsManager>(
      () => _i66.PendingOperationsManager(
        gh<_i31.PendingOperationsRepository>(),
        gh<_i27.NetworkStateManager>(),
        gh<_i28.OperationExecutorFactory>(),
      ),
    );
    gh.factory<_i67.PlaylistOperationExecutor>(
      () => _i67.PlaylistOperationExecutor(gh<_i36.PlaylistRemoteDataSource>()),
    );
    gh.lazySingleton<_i68.ProjectIncrementalSyncService>(
      () => _i68.ProjectIncrementalSyncService(
        gh<_i37.ProjectRemoteDataSource>(),
        gh<_i38.ProjectsLocalDataSource>(),
      ),
    );
    gh.factory<_i69.ProjectOperationExecutor>(
      () => _i69.ProjectOperationExecutor(gh<_i37.ProjectRemoteDataSource>()),
    );
    gh.lazySingleton<_i70.SessionStorage>(
      () => _i70.SessionStorageImpl(prefs: gh<_i45.SharedPreferences>()),
    );
    gh.lazySingleton<_i71.SyncAudioCommentsUseCase>(
      () => _i71.SyncAudioCommentsUseCase(
        gh<_i56.AudioCommentRemoteDataSource>(),
        gh<_i55.AudioCommentLocalDataSource>(),
        gh<_i37.ProjectRemoteDataSource>(),
        gh<_i70.SessionStorage>(),
        gh<_i58.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i72.SyncProjectsUsingSimpleServiceUseCase>(
      () => _i72.SyncProjectsUsingSimpleServiceUseCase(
        gh<_i68.ProjectIncrementalSyncService>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i73.SyncUserProfileUseCase>(
      () => _i73.SyncUserProfileUseCase(
        gh<_i53.UserProfileRemoteDataSource>(),
        gh<_i52.UserProfileLocalDataSource>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i74.UserProfileCacheRepository>(
      () => _i75.UserProfileCacheRepositoryImpl(
        gh<_i53.UserProfileRemoteDataSource>(),
        gh<_i52.UserProfileLocalDataSource>(),
        gh<_i27.NetworkStateManager>(),
      ),
    );
    gh.factory<_i76.UserProfileOperationExecutor>(
      () => _i76.UserProfileOperationExecutor(
        gh<_i53.UserProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i77.WatchProjectDetailUseCase>(
      () => _i77.WatchProjectDetailUseCase(
        gh<_i57.AudioTrackLocalDataSource>(),
        gh<_i52.UserProfileLocalDataSource>(),
        gh<_i55.AudioCommentLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i78.WatchUserProfilesUseCase>(
      () =>
          _i78.WatchUserProfilesUseCase(gh<_i74.UserProfileCacheRepository>()),
    );
    gh.factory<_i79.AudioCommentOperationExecutor>(
      () => _i79.AudioCommentOperationExecutor(
        gh<_i56.AudioCommentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i80.AudioDownloadRepository>(
      () => _i81.AudioDownloadRepositoryImpl(
        remoteDataSource: gh<_i60.CacheStorageRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i82.AudioStorageRepository>(
      () => _i83.AudioStorageRepositoryImpl(
        localDataSource: gh<_i59.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i84.AudioTrackIncrementalSyncService>(
      () => _i84.AudioTrackIncrementalSyncService(
        gh<_i58.AudioTrackRemoteDataSource>(),
        gh<_i57.AudioTrackLocalDataSource>(),
        gh<_i37.ProjectRemoteDataSource>(),
      ),
    );
    gh.factory<_i85.AudioTrackOperationExecutor>(
      () => _i85.AudioTrackOperationExecutor(
        gh<_i58.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i86.AuthRemoteDataSource>(
      () => _i86.AuthRemoteDataSourceImpl(
        gh<_i13.FirebaseAuth>(),
        gh<_i17.GoogleSignIn>(),
        gh<_i64.GoogleAuthService>(),
      ),
    );
    gh.lazySingleton<_i87.AuthRepository>(
      () => _i88.AuthRepositoryImpl(
        remote: gh<_i86.AuthRemoteDataSource>(),
        sessionStorage: gh<_i70.SessionStorage>(),
        networkStateManager: gh<_i27.NetworkStateManager>(),
        googleAuthService: gh<_i64.GoogleAuthService>(),
      ),
    );
    gh.lazySingleton<_i89.CacheKeyRepository>(
      () => _i90.CacheKeyRepositoryImpl(
        localDataSource: gh<_i59.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i91.CacheMaintenanceRepository>(
      () => _i92.CacheMaintenanceRepositoryImpl(
        localDataSource: gh<_i59.CacheStorageLocalDataSource>(),
      ),
    );
    gh.factory<_i93.CacheTrackUseCase>(
      () => _i93.CacheTrackUseCase(
        gh<_i80.AudioDownloadRepository>(),
        gh<_i82.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i94.CheckAuthenticationStatusUseCase>(
      () => _i94.CheckAuthenticationStatusUseCase(gh<_i87.AuthRepository>()),
    );
    gh.lazySingleton<_i95.GenerateMagicLinkUseCase>(
      () => _i95.GenerateMagicLinkUseCase(
        gh<_i23.MagicLinkRepository>(),
        gh<_i87.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i96.GetAuthStateUseCase>(
      () => _i96.GetAuthStateUseCase(gh<_i87.AuthRepository>()),
    );
    gh.factory<_i97.GetCachedTrackPathUseCase>(
      () => _i97.GetCachedTrackPathUseCase(gh<_i82.AudioStorageRepository>()),
    );
    gh.factory<_i98.GetCurrentUserIdUseCase>(
      () => _i98.GetCurrentUserIdUseCase(gh<_i87.AuthRepository>()),
    );
    gh.factory<_i99.GetCurrentUserUseCase>(
      () => _i99.GetCurrentUserUseCase(gh<_i87.AuthRepository>()),
    );
    gh.factory<_i100.GetPlaylistCacheStatusUseCase>(
      () => _i100.GetPlaylistCacheStatusUseCase(
        gh<_i82.AudioStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i101.OnboardingRepository>(
      () => _i102.OnboardingRepositoryImpl(
        gh<_i65.OnboardingStateLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i103.OnboardingUseCase>(
      () => _i103.OnboardingUseCase(gh<_i101.OnboardingRepository>()),
    );
    gh.factory<_i104.ProjectDetailBloc>(
      () => _i104.ProjectDetailBloc(
        watchProjectDetail: gh<_i77.WatchProjectDetailUseCase>(),
      ),
    );
    gh.factory<_i105.RemovePlaylistCacheUseCase>(
      () => _i105.RemovePlaylistCacheUseCase(gh<_i82.AudioStorageRepository>()),
    );
    gh.factory<_i106.RemoveTrackCacheUseCase>(
      () => _i106.RemoveTrackCacheUseCase(gh<_i82.AudioStorageRepository>()),
    );
    gh.lazySingleton<_i107.SignUpUseCase>(
      () => _i107.SignUpUseCase(gh<_i87.AuthRepository>()),
    );
    gh.lazySingleton<_i108.SyncAudioTracksUsingSimpleServiceUseCase>(
      () => _i108.SyncAudioTracksUsingSimpleServiceUseCase(
        gh<_i84.AudioTrackIncrementalSyncService>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i109.SyncUserProfileCollaboratorsUseCase>(
      () => _i109.SyncUserProfileCollaboratorsUseCase(
        gh<_i38.ProjectsLocalDataSource>(),
        gh<_i74.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i110.WatchTrackCacheStatusUseCase>(
      () =>
          _i110.WatchTrackCacheStatusUseCase(gh<_i82.AudioStorageRepository>()),
    );
    gh.factory<_i111.AudioSourceResolver>(
      () => _i112.AudioSourceResolverImpl(
        gh<_i82.AudioStorageRepository>(),
        gh<_i80.AudioDownloadRepository>(),
      ),
    );
    gh.factory<_i113.AudioWaveformBloc>(
      () => _i113.AudioWaveformBloc(
        audioPlaybackService: gh<_i3.AudioPlaybackService>(),
        getCachedTrackPathUseCase: gh<_i97.GetCachedTrackPathUseCase>(),
      ),
    );
    gh.factory<_i114.OnboardingBloc>(
      () => _i114.OnboardingBloc(
        onboardingUseCase: gh<_i103.OnboardingUseCase>(),
        getCurrentUserIdUseCase: gh<_i98.GetCurrentUserIdUseCase>(),
      ),
    );
    gh.factory<_i115.SyncDataManager>(
      () => _i115.SyncDataManager(
        syncProjects: gh<_i72.SyncProjectsUsingSimpleServiceUseCase>(),
        syncAudioTracks: gh<_i108.SyncAudioTracksUsingSimpleServiceUseCase>(),
        syncAudioComments: gh<_i71.SyncAudioCommentsUseCase>(),
        syncUserProfile: gh<_i73.SyncUserProfileUseCase>(),
        syncUserProfileCollaborators:
            gh<_i109.SyncUserProfileCollaboratorsUseCase>(),
      ),
    );
    gh.factory<_i116.SyncStatusProvider>(
      () => _i116.SyncStatusProvider(
        syncDataManager: gh<_i115.SyncDataManager>(),
        pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.factory<_i117.TrackCacheBloc>(
      () => _i117.TrackCacheBloc(
        cacheTrackUseCase: gh<_i93.CacheTrackUseCase>(),
        watchTrackCacheStatusUseCase: gh<_i110.WatchTrackCacheStatusUseCase>(),
        removeTrackCacheUseCase: gh<_i106.RemoveTrackCacheUseCase>(),
        getCachedTrackPathUseCase: gh<_i97.GetCachedTrackPathUseCase>(),
      ),
    );
    gh.lazySingleton<_i118.BackgroundSyncCoordinator>(
      () => _i118.BackgroundSyncCoordinator(
        gh<_i27.NetworkStateManager>(),
        gh<_i115.SyncDataManager>(),
        gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i119.PlaylistRepository>(
      () => _i120.PlaylistRepositoryImpl(
        localDataSource: gh<_i35.PlaylistLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i118.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i121.ProjectsRepository>(
      () => _i122.ProjectsRepositoryImpl(
        localDataSource: gh<_i38.ProjectsLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i118.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i123.RemoveCollaboratorUseCase>(
      () => _i123.RemoveCollaboratorUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i124.UpdateCollaboratorRoleUseCase>(
      () => _i124.UpdateCollaboratorRoleUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i125.UpdateProjectUseCase>(
      () => _i125.UpdateProjectUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i126.UserProfileRepository>(
      () => _i127.UserProfileRepositoryImpl(
        localDataSource: gh<_i52.UserProfileLocalDataSource>(),
        remoteDataSource: gh<_i53.UserProfileRemoteDataSource>(),
        networkStateManager: gh<_i27.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i118.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
        firestore: gh<_i14.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i128.WatchAllProjectsUseCase>(
      () => _i128.WatchAllProjectsUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i129.WatchUserProfileUseCase>(
      () => _i129.WatchUserProfileUseCase(
        gh<_i126.UserProfileRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i130.AddCollaboratorToProjectUseCase>(
      () => _i130.AddCollaboratorToProjectUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i131.AudioCommentRepository>(
      () => _i132.AudioCommentRepositoryImpl(
        remoteDataSource: gh<_i56.AudioCommentRemoteDataSource>(),
        localDataSource: gh<_i55.AudioCommentLocalDataSource>(),
        networkStateManager: gh<_i27.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i118.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i133.AudioTrackRepository>(
      () => _i134.AudioTrackRepositoryImpl(
        gh<_i57.AudioTrackLocalDataSource>(),
        gh<_i118.BackgroundSyncCoordinator>(),
        gh<_i66.PendingOperationsManager>(),
      ),
    );
    gh.factory<_i135.CachePlaylistUseCase>(
      () => _i135.CachePlaylistUseCase(
        gh<_i80.AudioDownloadRepository>(),
        gh<_i133.AudioTrackRepository>(),
      ),
    );
    gh.factory<_i136.CheckProfileCompletenessUseCase>(
      () => _i136.CheckProfileCompletenessUseCase(
        gh<_i126.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i137.CreateProjectUseCase>(
      () => _i137.CreateProjectUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i138.DeleteProjectUseCase>(
      () => _i138.DeleteProjectUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i139.GetProjectByIdUseCase>(
      () => _i139.GetProjectByIdUseCase(gh<_i121.ProjectsRepository>()),
    );
    gh.lazySingleton<_i140.GoogleSignInUseCase>(
      () => _i140.GoogleSignInUseCase(
        gh<_i87.AuthRepository>(),
        gh<_i126.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i141.JoinProjectWithIdUseCase>(
      () => _i141.JoinProjectWithIdUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i142.LeaveProjectUseCase>(
      () => _i142.LeaveProjectUseCase(
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.factory<_i143.MagicLinkBloc>(
      () => _i143.MagicLinkBloc(
        generateMagicLink: gh<_i95.GenerateMagicLinkUseCase>(),
        validateMagicLink: gh<_i54.ValidateMagicLinkUseCase>(),
        consumeMagicLink: gh<_i61.ConsumeMagicLinkUseCase>(),
        resendMagicLink: gh<_i39.ResendMagicLinkUseCase>(),
        getMagicLinkStatus: gh<_i63.GetMagicLinkStatusUseCase>(),
        joinProjectWithId: gh<_i141.JoinProjectWithIdUseCase>(),
        authRepository: gh<_i87.AuthRepository>(),
      ),
    );
    gh.factory<_i144.ManageCollaboratorsBloc>(
      () => _i144.ManageCollaboratorsBloc(
        addCollaboratorUseCase: gh<_i130.AddCollaboratorToProjectUseCase>(),
        removeCollaboratorUseCase: gh<_i123.RemoveCollaboratorUseCase>(),
        updateCollaboratorRoleUseCase:
            gh<_i124.UpdateCollaboratorRoleUseCase>(),
        leaveProjectUseCase: gh<_i142.LeaveProjectUseCase>(),
        watchUserProfilesUseCase: gh<_i78.WatchUserProfilesUseCase>(),
      ),
    );
    gh.factory<_i145.PlayAudioUseCase>(
      () => _i145.PlayAudioUseCase(
        audioTrackRepository: gh<_i133.AudioTrackRepository>(),
        audioStorageRepository: gh<_i82.AudioStorageRepository>(),
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i146.PlayPlaylistUseCase>(
      () => _i146.PlayPlaylistUseCase(
        playlistRepository: gh<_i119.PlaylistRepository>(),
        audioTrackRepository: gh<_i133.AudioTrackRepository>(),
        playbackService: gh<_i3.AudioPlaybackService>(),
        audioStorageRepository: gh<_i82.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i147.PlaylistCacheBloc>(
      () => _i147.PlaylistCacheBloc(
        cachePlaylistUseCase: gh<_i135.CachePlaylistUseCase>(),
        getPlaylistCacheStatusUseCase:
            gh<_i100.GetPlaylistCacheStatusUseCase>(),
        removePlaylistCacheUseCase: gh<_i105.RemovePlaylistCacheUseCase>(),
      ),
    );
    gh.lazySingleton<_i148.ProjectCommentService>(
      () => _i148.ProjectCommentService(gh<_i131.AudioCommentRepository>()),
    );
    gh.lazySingleton<_i149.ProjectTrackService>(
      () => _i149.ProjectTrackService(
        gh<_i133.AudioTrackRepository>(),
        gh<_i82.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i150.ProjectsBloc>(
      () => _i150.ProjectsBloc(
        createProject: gh<_i137.CreateProjectUseCase>(),
        updateProject: gh<_i125.UpdateProjectUseCase>(),
        deleteProject: gh<_i138.DeleteProjectUseCase>(),
        watchAllProjects: gh<_i128.WatchAllProjectsUseCase>(),
        syncStatusProvider: gh<_i116.SyncStatusProvider>(),
      ),
    );
    gh.factory<_i151.RestorePlaybackStateUseCase>(
      () => _i151.RestorePlaybackStateUseCase(
        persistenceRepository: gh<_i33.PlaybackPersistenceRepository>(),
        audioTrackRepository: gh<_i133.AudioTrackRepository>(),
        audioStorageRepository: gh<_i82.AudioStorageRepository>(),
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i152.SignInUseCase>(
      () => _i152.SignInUseCase(
        gh<_i87.AuthRepository>(),
        gh<_i126.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i153.SignOutUseCase>(
      () => _i153.SignOutUseCase(
        gh<_i87.AuthRepository>(),
        gh<_i126.UserProfileRepository>(),
      ),
    );
    gh.factory<_i154.UpdateUserProfileUseCase>(
      () => _i154.UpdateUserProfileUseCase(
        gh<_i126.UserProfileRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i155.UploadAudioTrackUseCase>(
      () => _i155.UploadAudioTrackUseCase(
        gh<_i149.ProjectTrackService>(),
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i156.WatchCommentsByTrackUseCase>(
      () =>
          _i156.WatchCommentsByTrackUseCase(gh<_i148.ProjectCommentService>()),
    );
    gh.lazySingleton<_i157.WatchTracksByProjectIdUseCase>(
      () =>
          _i157.WatchTracksByProjectIdUseCase(gh<_i133.AudioTrackRepository>()),
    );
    gh.lazySingleton<_i158.AddAudioCommentUseCase>(
      () => _i158.AddAudioCommentUseCase(
        gh<_i148.ProjectCommentService>(),
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i159.AudioContextService>(
      () => _i160.AudioContextServiceImpl(
        userProfileRepository: gh<_i126.UserProfileRepository>(),
        audioTrackRepository: gh<_i133.AudioTrackRepository>(),
        projectsRepository: gh<_i121.ProjectsRepository>(),
      ),
    );
    gh.factory<_i161.AudioPlayerService>(
      () => _i161.AudioPlayerService(
        initializeAudioPlayerUseCase: gh<_i18.InitializeAudioPlayerUseCase>(),
        playAudioUseCase: gh<_i145.PlayAudioUseCase>(),
        playPlaylistUseCase: gh<_i146.PlayPlaylistUseCase>(),
        pauseAudioUseCase: gh<_i29.PauseAudioUseCase>(),
        resumeAudioUseCase: gh<_i40.ResumeAudioUseCase>(),
        stopAudioUseCase: gh<_i48.StopAudioUseCase>(),
        skipToNextUseCase: gh<_i46.SkipToNextUseCase>(),
        skipToPreviousUseCase: gh<_i47.SkipToPreviousUseCase>(),
        seekAudioUseCase: gh<_i42.SeekAudioUseCase>(),
        toggleShuffleUseCase: gh<_i51.ToggleShuffleUseCase>(),
        toggleRepeatModeUseCase: gh<_i50.ToggleRepeatModeUseCase>(),
        setVolumeUseCase: gh<_i44.SetVolumeUseCase>(),
        setPlaybackSpeedUseCase: gh<_i43.SetPlaybackSpeedUseCase>(),
        savePlaybackStateUseCase: gh<_i41.SavePlaybackStateUseCase>(),
        restorePlaybackStateUseCase: gh<_i151.RestorePlaybackStateUseCase>(),
        playbackService: gh<_i3.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i162.AuthBloc>(
      () => _i162.AuthBloc(
        signIn: gh<_i152.SignInUseCase>(),
        signUp: gh<_i107.SignUpUseCase>(),
        googleSignIn: gh<_i140.GoogleSignInUseCase>(),
      ),
    );
    gh.lazySingleton<_i163.DeleteAudioCommentUseCase>(
      () => _i163.DeleteAudioCommentUseCase(
        gh<_i148.ProjectCommentService>(),
        gh<_i121.ProjectsRepository>(),
        gh<_i70.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i164.DeleteAudioTrack>(
      () => _i164.DeleteAudioTrack(
        gh<_i70.SessionStorage>(),
        gh<_i121.ProjectsRepository>(),
        gh<_i149.ProjectTrackService>(),
      ),
    );
    gh.lazySingleton<_i165.EditAudioTrackUseCase>(
      () => _i165.EditAudioTrackUseCase(
        gh<_i149.ProjectTrackService>(),
        gh<_i121.ProjectsRepository>(),
      ),
    );
    gh.factory<_i166.LoadTrackContextUseCase>(
      () => _i166.LoadTrackContextUseCase(gh<_i159.AudioContextService>()),
    );
    gh.factory<_i167.SessionService>(
      () => _i167.SessionService(
        checkAuthUseCase: gh<_i94.CheckAuthenticationStatusUseCase>(),
        getCurrentUserUseCase: gh<_i99.GetCurrentUserUseCase>(),
        onboardingUseCase: gh<_i103.OnboardingUseCase>(),
        profileUseCase: gh<_i136.CheckProfileCompletenessUseCase>(),
        signOutUseCase: gh<_i153.SignOutUseCase>(),
      ),
    );
    gh.factory<_i168.AppBootstrap>(
      () => _i168.AppBootstrap(
        sessionService: gh<_i167.SessionService>(),
        performanceCollector: gh<_i32.PerformanceMetricsCollector>(),
        dynamicLinkService: gh<_i12.DynamicLinkService>(),
        databaseHealthMonitor: gh<_i62.DatabaseHealthMonitor>(),
      ),
    );
    gh.factory<_i169.AppFlowBloc>(
      () => _i169.AppFlowBloc(
        appBootstrap: gh<_i168.AppBootstrap>(),
        backgroundSyncCoordinator: gh<_i118.BackgroundSyncCoordinator>(),
      ),
    );
    gh.factory<_i170.AudioCommentBloc>(
      () => _i170.AudioCommentBloc(
        watchCommentsByTrackUseCase: gh<_i156.WatchCommentsByTrackUseCase>(),
        addAudioCommentUseCase: gh<_i158.AddAudioCommentUseCase>(),
        deleteAudioCommentUseCase: gh<_i163.DeleteAudioCommentUseCase>(),
        watchUserProfilesUseCase: gh<_i78.WatchUserProfilesUseCase>(),
      ),
    );
    gh.factory<_i171.AudioContextBloc>(
      () => _i171.AudioContextBloc(
        loadTrackContextUseCase: gh<_i166.LoadTrackContextUseCase>(),
      ),
    );
    gh.factory<_i172.AudioPlayerBloc>(
      () => _i172.AudioPlayerBloc(
        audioPlayerService: gh<_i161.AudioPlayerService>(),
      ),
    );
    gh.factory<_i173.AudioTrackBloc>(
      () => _i173.AudioTrackBloc(
        watchAudioTracksByProject: gh<_i157.WatchTracksByProjectIdUseCase>(),
        deleteAudioTrack: gh<_i164.DeleteAudioTrack>(),
        uploadAudioTrackUseCase: gh<_i155.UploadAudioTrackUseCase>(),
        editAudioTrackUseCase: gh<_i165.EditAudioTrackUseCase>(),
      ),
    );
    gh.factory<_i174.GetCurrentUserDataUseCase>(
      () => _i174.GetCurrentUserDataUseCase(gh<_i167.SessionService>()),
    );
    gh.factory<_i175.UserProfileBloc>(
      () => _i175.UserProfileBloc(
        updateUserProfileUseCase: gh<_i154.UpdateUserProfileUseCase>(),
        watchUserProfileUseCase: gh<_i129.WatchUserProfileUseCase>(),
        checkProfileCompletenessUseCase:
            gh<_i136.CheckProfileCompletenessUseCase>(),
        getCurrentUserDataUseCase: gh<_i174.GetCurrentUserDataUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i176.AppModule {}
