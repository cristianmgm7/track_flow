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
import 'package:isar/isar.dart' as _i21;
import 'package:shared_preferences/shared_preferences.dart' as _i51;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i86;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i196;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i195;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i111;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i114;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_id_usecase.dart'
    as _i116;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i117;
import 'package:trackflow/core/app_flow/domain/usecases/sign_out_usecase.dart'
    as _i180;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i197;
import 'package:trackflow/core/di/app_module.dart' as _i204;
import 'package:trackflow/core/network/network_state_manager.dart' as _i27;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i28;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i29;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i31;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i30;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i32;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i68;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i70;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i72;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i120;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i77;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i78;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i33;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i121;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i122;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i69;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i38;
import 'package:trackflow/core/session/current_user_service.dart' as _i112;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i36;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i95;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i101;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i34;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i83;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i85;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i92;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i82;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i138;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i55;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i139;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i87;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i131;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i88;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i132;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i89;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i159;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i173;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i65;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i66;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i97;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i99;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i106;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i108;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i98;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i105;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i107;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i115;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i129;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i133;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i140;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i61;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i62;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i156;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i155;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i174;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i185;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i190;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i183;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i198;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i136;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i186;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i193;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i187;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i199;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i188;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i134;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i35;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i171;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i172;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i177;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i40;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i135;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i200;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i63;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i64;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i100;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i157;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i175;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i191;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i192;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i182;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i184;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i201;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i102;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i104;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i73;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i103;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i166;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i179;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i130;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i189;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i20;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i76;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i75;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i153;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i110;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i162;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i118;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i79;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i80;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i178;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i194;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i127;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i22;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i23;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i25;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i24;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i67;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i113;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i71;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i45;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i60;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i154;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i167;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i168;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i146;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i147;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i94;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i170;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i26;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i81;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i124;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i125;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i123;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i137;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i41;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i42;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i143;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i142;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i93;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i126;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i44;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i43;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i145;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i84;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i144;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i161;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i163;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i148;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i151;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i176;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i58;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i59;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i91;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i150;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i149;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i90;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i160;
import 'package:trackflow/features/user_profile/domain/usecases/find_user_by_email_usecase.dart'
    as _i164;
import 'package:trackflow/features/user_profile/domain/usecases/get_current_user_data_usecase.dart'
    as _i202;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i181;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i152;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i203;

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
    gh.lazySingleton<_i20.InvitationRemoteDataSource>(() =>
        _i20.FirestoreInvitationRemoteDataSource(gh<_i14.FirebaseFirestore>()));
    await gh.factoryAsync<_i21.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i22.MagicLinkLocalDataSource>(
        () => _i22.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i23.MagicLinkRemoteDataSource>(
        () => _i23.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i14.FirebaseFirestore>(),
              deepLinkService: gh<_i10.DeepLinkService>(),
            ));
    gh.factory<_i24.MagicLinkRepository>(() =>
        _i25.MagicLinkRepositoryImp(gh<_i23.MagicLinkRemoteDataSource>()));
    gh.factory<_i26.NavigationCubit>(() => _i26.NavigationCubit());
    gh.lazySingleton<_i27.NetworkStateManager>(() => _i27.NetworkStateManager(
          gh<_i19.InternetConnectionChecker>(),
          gh<_i9.Connectivity>(),
        ));
    gh.lazySingleton<_i28.NotificationLocalDataSource>(
        () => _i28.IsarNotificationLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i29.NotificationRemoteDataSource>(() =>
        _i29.FirestoreNotificationRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i30.NotificationRepository>(
        () => _i31.NotificationRepositoryImpl(
              localDataSource: gh<_i28.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i29.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i27.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i32.NotificationService>(
        () => _i32.NotificationService(gh<_i30.NotificationRepository>()));
    gh.lazySingleton<_i33.ObserveNotificationsUseCase>(() =>
        _i33.ObserveNotificationsUseCase(gh<_i30.NotificationRepository>()));
    gh.factory<_i34.OperationExecutorFactory>(
        () => _i34.OperationExecutorFactory());
    gh.factory<_i35.PauseAudioUseCase>(() => _i35.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i36.PendingOperationsLocalDataSource>(
        () => _i36.IsarPendingOperationsLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i37.PendingOperationsRepository>(() =>
        _i37.PendingOperationsRepositoryImpl(
            gh<_i36.PendingOperationsLocalDataSource>()));
    gh.factory<_i38.PerformanceMetricsCollector>(
        () => _i38.PerformanceMetricsCollector());
    gh.lazySingleton<_i39.PlaybackPersistenceRepository>(
        () => _i40.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i41.PlaylistLocalDataSource>(
        () => _i41.PlaylistLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i42.PlaylistRemoteDataSource>(
        () => _i42.PlaylistRemoteDataSourceImpl(gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i43.ProjectRemoteDataSource>(() =>
        _i43.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i44.ProjectsLocalDataSource>(
        () => _i44.ProjectsLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i45.ResendMagicLinkUseCase>(
        () => _i45.ResendMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.factory<_i46.ResumeAudioUseCase>(() => _i46.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i47.SavePlaybackStateUseCase>(
        () => _i47.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i39.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i48.SeekAudioUseCase>(() =>
        _i48.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i49.SetPlaybackSpeedUseCase>(() => _i49.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i50.SetVolumeUseCase>(() =>
        _i50.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i51.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i52.SkipToNextUseCase>(() => _i52.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i53.SkipToPreviousUseCase>(() => _i53.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i54.StopAudioUseCase>(() =>
        _i54.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i55.SyncMetadataManager>(
        () => _i55.SyncMetadataManager());
    gh.factory<_i56.ToggleRepeatModeUseCase>(() => _i56.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i57.ToggleShuffleUseCase>(() => _i57.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i58.UserProfileLocalDataSource>(
        () => _i58.IsarUserProfileLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i59.UserProfileRemoteDataSource>(
        () => _i59.UserProfileRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i60.ValidateMagicLinkUseCase>(
        () => _i60.ValidateMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.lazySingleton<_i61.AudioCommentLocalDataSource>(
        () => _i61.IsarAudioCommentLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i62.AudioCommentRemoteDataSource>(() =>
        _i62.FirebaseAudioCommentRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i63.AudioTrackLocalDataSource>(
        () => _i63.IsarAudioTrackLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i64.AudioTrackRemoteDataSource>(
        () => _i64.AudioTrackRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i65.CacheStorageLocalDataSource>(
        () => _i65.CacheStorageLocalDataSourceImpl(gh<_i21.Isar>()));
    gh.lazySingleton<_i66.CacheStorageRemoteDataSource>(() =>
        _i66.CacheStorageRemoteDataSourceImpl(gh<_i15.FirebaseStorage>()));
    gh.lazySingleton<_i67.ConsumeMagicLinkUseCase>(
        () => _i67.ConsumeMagicLinkUseCase(gh<_i24.MagicLinkRepository>()));
    gh.factory<_i68.CreateNotificationUseCase>(() =>
        _i68.CreateNotificationUseCase(gh<_i30.NotificationRepository>()));
    gh.factory<_i69.DatabaseHealthMonitor>(
        () => _i69.DatabaseHealthMonitor(gh<_i21.Isar>()));
    gh.factory<_i70.DeleteNotificationUseCase>(() =>
        _i70.DeleteNotificationUseCase(gh<_i30.NotificationRepository>()));
    gh.lazySingleton<_i71.GetMagicLinkStatusUseCase>(
        () => _i71.GetMagicLinkStatusUseCase(gh<_i24.MagicLinkRepository>()));
    gh.lazySingleton<_i72.GetUnreadNotificationsCountUseCase>(() =>
        _i72.GetUnreadNotificationsCountUseCase(
            gh<_i30.NotificationRepository>()));
    gh.lazySingleton<_i73.GoogleAuthService>(() => _i73.GoogleAuthService(
          gh<_i17.GoogleSignIn>(),
          gh<_i13.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i74.InvitationLocalDataSource>(
        () => _i74.IsarInvitationLocalDataSource(gh<_i21.Isar>()));
    gh.lazySingleton<_i75.InvitationRepository>(
        () => _i76.InvitationRepositoryImpl(
              localDataSource: gh<_i74.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i20.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i27.NetworkStateManager>(),
            ));
    gh.factory<_i77.MarkAsUnreadUseCase>(
        () => _i77.MarkAsUnreadUseCase(gh<_i30.NotificationRepository>()));
    gh.lazySingleton<_i78.MarkNotificationAsReadUseCase>(() =>
        _i78.MarkNotificationAsReadUseCase(gh<_i30.NotificationRepository>()));
    gh.lazySingleton<_i79.ObservePendingInvitationsUseCase>(() =>
        _i79.ObservePendingInvitationsUseCase(gh<_i75.InvitationRepository>()));
    gh.lazySingleton<_i80.ObserveSentInvitationsUseCase>(() =>
        _i80.ObserveSentInvitationsUseCase(gh<_i75.InvitationRepository>()));
    gh.lazySingleton<_i81.OnboardingStateLocalDataSource>(() =>
        _i81.OnboardingStateLocalDataSourceImpl(gh<_i51.SharedPreferences>()));
    gh.lazySingleton<_i82.PendingOperationsManager>(
        () => _i82.PendingOperationsManager(
              gh<_i37.PendingOperationsRepository>(),
              gh<_i27.NetworkStateManager>(),
              gh<_i34.OperationExecutorFactory>(),
            ));
    gh.factory<_i83.PlaylistOperationExecutor>(() =>
        _i83.PlaylistOperationExecutor(gh<_i42.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i84.ProjectIncrementalSyncService>(
        () => _i84.ProjectIncrementalSyncService(
              gh<_i43.ProjectRemoteDataSource>(),
              gh<_i44.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i85.ProjectOperationExecutor>(() =>
        _i85.ProjectOperationExecutor(gh<_i43.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i86.SessionStorage>(
        () => _i86.SessionStorageImpl(prefs: gh<_i51.SharedPreferences>()));
    gh.lazySingleton<_i87.SyncAudioCommentsUseCase>(
        () => _i87.SyncAudioCommentsUseCase(
              gh<_i62.AudioCommentRemoteDataSource>(),
              gh<_i61.AudioCommentLocalDataSource>(),
              gh<_i43.ProjectRemoteDataSource>(),
              gh<_i86.SessionStorage>(),
              gh<_i64.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i88.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i88.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i84.ProjectIncrementalSyncService>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i89.SyncUserProfileUseCase>(
        () => _i89.SyncUserProfileUseCase(
              gh<_i59.UserProfileRemoteDataSource>(),
              gh<_i58.UserProfileLocalDataSource>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i90.UserProfileCacheRepository>(
        () => _i91.UserProfileCacheRepositoryImpl(
              gh<_i59.UserProfileRemoteDataSource>(),
              gh<_i58.UserProfileLocalDataSource>(),
              gh<_i27.NetworkStateManager>(),
            ));
    gh.factory<_i92.UserProfileOperationExecutor>(() =>
        _i92.UserProfileOperationExecutor(
            gh<_i59.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i93.WatchProjectDetailUseCase>(
        () => _i93.WatchProjectDetailUseCase(
              gh<_i63.AudioTrackLocalDataSource>(),
              gh<_i58.UserProfileLocalDataSource>(),
              gh<_i61.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i94.WatchUserProfilesUseCase>(() =>
        _i94.WatchUserProfilesUseCase(gh<_i90.UserProfileCacheRepository>()));
    gh.factory<_i95.AudioCommentOperationExecutor>(() =>
        _i95.AudioCommentOperationExecutor(
            gh<_i62.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i96.AudioDownloadRepository>(() =>
        _i97.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i66.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i98.AudioStorageRepository>(() =>
        _i99.AudioStorageRepositoryImpl(
            localDataSource: gh<_i65.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i100.AudioTrackIncrementalSyncService>(
        () => _i100.AudioTrackIncrementalSyncService(
              gh<_i64.AudioTrackRemoteDataSource>(),
              gh<_i63.AudioTrackLocalDataSource>(),
              gh<_i43.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i101.AudioTrackOperationExecutor>(() =>
        _i101.AudioTrackOperationExecutor(
            gh<_i64.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i102.AuthRemoteDataSource>(
        () => _i102.AuthRemoteDataSourceImpl(
              gh<_i13.FirebaseAuth>(),
              gh<_i17.GoogleSignIn>(),
              gh<_i73.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i103.AuthRepository>(() => _i104.AuthRepositoryImpl(
          remote: gh<_i102.AuthRemoteDataSource>(),
          sessionStorage: gh<_i86.SessionStorage>(),
          networkStateManager: gh<_i27.NetworkStateManager>(),
          googleAuthService: gh<_i73.GoogleAuthService>(),
        ));
    gh.lazySingleton<_i105.CacheKeyRepository>(() =>
        _i106.CacheKeyRepositoryImpl(
            localDataSource: gh<_i65.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i107.CacheMaintenanceRepository>(() =>
        _i108.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i65.CacheStorageLocalDataSource>()));
    gh.factory<_i109.CacheTrackUseCase>(() => _i109.CacheTrackUseCase(
          gh<_i96.AudioDownloadRepository>(),
          gh<_i98.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i110.CancelInvitationUseCase>(
        () => _i110.CancelInvitationUseCase(gh<_i75.InvitationRepository>()));
    gh.factory<_i111.CheckAuthenticationStatusUseCase>(() =>
        _i111.CheckAuthenticationStatusUseCase(gh<_i103.AuthRepository>()));
    gh.factory<_i112.CurrentUserService>(
        () => _i112.CurrentUserService(gh<_i86.SessionStorage>()));
    gh.lazySingleton<_i113.GenerateMagicLinkUseCase>(
        () => _i113.GenerateMagicLinkUseCase(
              gh<_i24.MagicLinkRepository>(),
              gh<_i103.AuthRepository>(),
            ));
    gh.lazySingleton<_i114.GetAuthStateUseCase>(
        () => _i114.GetAuthStateUseCase(gh<_i103.AuthRepository>()));
    gh.factory<_i115.GetCachedTrackPathUseCase>(() =>
        _i115.GetCachedTrackPathUseCase(gh<_i98.AudioStorageRepository>()));
    gh.factory<_i116.GetCurrentUserIdUseCase>(
        () => _i116.GetCurrentUserIdUseCase(gh<_i103.AuthRepository>()));
    gh.factory<_i117.GetCurrentUserUseCase>(
        () => _i117.GetCurrentUserUseCase(gh<_i103.AuthRepository>()));
    gh.lazySingleton<_i118.GetPendingInvitationsCountUseCase>(() =>
        _i118.GetPendingInvitationsCountUseCase(
            gh<_i75.InvitationRepository>()));
    gh.factory<_i119.GetPlaylistCacheStatusUseCase>(() =>
        _i119.GetPlaylistCacheStatusUseCase(gh<_i98.AudioStorageRepository>()));
    gh.factory<_i120.MarkAllNotificationsAsReadUseCase>(
        () => _i120.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i30.NotificationRepository>(),
              currentUserService: gh<_i112.CurrentUserService>(),
            ));
    gh.factory<_i121.NotificationActorBloc>(() => _i121.NotificationActorBloc(
          createNotificationUseCase: gh<_i68.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i78.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i77.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i120.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i70.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i122.NotificationWatcherBloc>(
        () => _i122.NotificationWatcherBloc(
              notificationRepository: gh<_i30.NotificationRepository>(),
              currentUserService: gh<_i112.CurrentUserService>(),
            ));
    gh.lazySingleton<_i123.OnboardingRepository>(() =>
        _i124.OnboardingRepositoryImpl(
            gh<_i81.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i125.OnboardingUseCase>(
        () => _i125.OnboardingUseCase(gh<_i123.OnboardingRepository>()));
    gh.factory<_i126.ProjectDetailBloc>(() => _i126.ProjectDetailBloc(
        watchProjectDetail: gh<_i93.WatchProjectDetailUseCase>()));
    gh.factory<_i127.ProjectInvitationWatcherBloc>(
        () => _i127.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i75.InvitationRepository>(),
              currentUserService: gh<_i112.CurrentUserService>(),
            ));
    gh.factory<_i128.RemovePlaylistCacheUseCase>(() =>
        _i128.RemovePlaylistCacheUseCase(gh<_i98.AudioStorageRepository>()));
    gh.factory<_i129.RemoveTrackCacheUseCase>(
        () => _i129.RemoveTrackCacheUseCase(gh<_i98.AudioStorageRepository>()));
    gh.lazySingleton<_i130.SignUpUseCase>(
        () => _i130.SignUpUseCase(gh<_i103.AuthRepository>()));
    gh.lazySingleton<_i131.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i131.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i100.AudioTrackIncrementalSyncService>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i132.SyncUserProfileCollaboratorsUseCase>(
        () => _i132.SyncUserProfileCollaboratorsUseCase(
              gh<_i44.ProjectsLocalDataSource>(),
              gh<_i90.UserProfileCacheRepository>(),
            ));
    gh.factory<_i133.WatchTrackCacheStatusUseCase>(() =>
        _i133.WatchTrackCacheStatusUseCase(gh<_i98.AudioStorageRepository>()));
    gh.factory<_i134.AudioSourceResolver>(() => _i135.AudioSourceResolverImpl(
          gh<_i98.AudioStorageRepository>(),
          gh<_i96.AudioDownloadRepository>(),
        ));
    gh.factory<_i136.AudioWaveformBloc>(() => _i136.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i115.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i137.OnboardingBloc>(() => _i137.OnboardingBloc(
          onboardingUseCase: gh<_i125.OnboardingUseCase>(),
          getCurrentUserIdUseCase: gh<_i116.GetCurrentUserIdUseCase>(),
        ));
    gh.factory<_i138.SyncDataManager>(() => _i138.SyncDataManager(
          syncProjects: gh<_i88.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i131.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i87.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i89.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i132.SyncUserProfileCollaboratorsUseCase>(),
        ));
    gh.factory<_i139.SyncStatusProvider>(() => _i139.SyncStatusProvider(
          syncDataManager: gh<_i138.SyncDataManager>(),
          pendingOperationsManager: gh<_i82.PendingOperationsManager>(),
        ));
    gh.factory<_i140.TrackCacheBloc>(() => _i140.TrackCacheBloc(
          cacheTrackUseCase: gh<_i109.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i133.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i129.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i115.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i141.BackgroundSyncCoordinator>(
        () => _i141.BackgroundSyncCoordinator(
              gh<_i27.NetworkStateManager>(),
              gh<_i138.SyncDataManager>(),
              gh<_i82.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i142.PlaylistRepository>(
        () => _i143.PlaylistRepositoryImpl(
              localDataSource: gh<_i41.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i141.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i82.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i144.ProjectsRepository>(
        () => _i145.ProjectsRepositoryImpl(
              localDataSource: gh<_i44.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i141.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i82.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i146.RemoveCollaboratorUseCase>(
        () => _i146.RemoveCollaboratorUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i147.UpdateCollaboratorRoleUseCase>(
        () => _i147.UpdateCollaboratorRoleUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i148.UpdateProjectUseCase>(
        () => _i148.UpdateProjectUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i149.UserProfileRepository>(
        () => _i150.UserProfileRepositoryImpl(
              localDataSource: gh<_i58.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i59.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i27.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i141.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i82.PendingOperationsManager>(),
              firestore: gh<_i14.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i151.WatchAllProjectsUseCase>(
        () => _i151.WatchAllProjectsUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i152.WatchUserProfileUseCase>(
        () => _i152.WatchUserProfileUseCase(
              gh<_i149.UserProfileRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i153.AcceptInvitationUseCase>(
        () => _i153.AcceptInvitationUseCase(
              invitationRepository: gh<_i75.InvitationRepository>(),
              projectRepository: gh<_i144.ProjectsRepository>(),
              userProfileRepository: gh<_i149.UserProfileRepository>(),
              notificationService: gh<_i32.NotificationService>(),
            ));
    gh.lazySingleton<_i154.AddCollaboratorToProjectUseCase>(
        () => _i154.AddCollaboratorToProjectUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i155.AudioCommentRepository>(
        () => _i156.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i62.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i61.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i27.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i141.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i82.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i157.AudioTrackRepository>(
        () => _i158.AudioTrackRepositoryImpl(
              gh<_i63.AudioTrackLocalDataSource>(),
              gh<_i141.BackgroundSyncCoordinator>(),
              gh<_i82.PendingOperationsManager>(),
            ));
    gh.factory<_i159.CachePlaylistUseCase>(() => _i159.CachePlaylistUseCase(
          gh<_i96.AudioDownloadRepository>(),
          gh<_i157.AudioTrackRepository>(),
        ));
    gh.factory<_i160.CheckProfileCompletenessUseCase>(() =>
        _i160.CheckProfileCompletenessUseCase(
            gh<_i149.UserProfileRepository>()));
    gh.lazySingleton<_i161.CreateProjectUseCase>(
        () => _i161.CreateProjectUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i162.DeclineInvitationUseCase>(
        () => _i162.DeclineInvitationUseCase(
              invitationRepository: gh<_i75.InvitationRepository>(),
              projectRepository: gh<_i144.ProjectsRepository>(),
              userProfileRepository: gh<_i149.UserProfileRepository>(),
              notificationService: gh<_i32.NotificationService>(),
            ));
    gh.lazySingleton<_i163.DeleteProjectUseCase>(
        () => _i163.DeleteProjectUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i164.FindUserByEmailUseCase>(
        () => _i164.FindUserByEmailUseCase(gh<_i149.UserProfileRepository>()));
    gh.lazySingleton<_i165.GetProjectByIdUseCase>(
        () => _i165.GetProjectByIdUseCase(gh<_i144.ProjectsRepository>()));
    gh.lazySingleton<_i166.GoogleSignInUseCase>(() => _i166.GoogleSignInUseCase(
          gh<_i103.AuthRepository>(),
          gh<_i149.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i167.JoinProjectWithIdUseCase>(
        () => _i167.JoinProjectWithIdUseCase(
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i168.LeaveProjectUseCase>(() => _i168.LeaveProjectUseCase(
          gh<_i144.ProjectsRepository>(),
          gh<_i86.SessionStorage>(),
        ));
    gh.factory<_i169.MagicLinkBloc>(() => _i169.MagicLinkBloc(
          generateMagicLink: gh<_i113.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i60.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i67.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i45.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i71.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i167.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i103.AuthRepository>(),
        ));
    gh.factory<_i170.ManageCollaboratorsBloc>(() =>
        _i170.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i154.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i146.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i147.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i168.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i94.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i171.PlayAudioUseCase>(() => _i171.PlayAudioUseCase(
          audioTrackRepository: gh<_i157.AudioTrackRepository>(),
          audioStorageRepository: gh<_i98.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i172.PlayPlaylistUseCase>(() => _i172.PlayPlaylistUseCase(
          playlistRepository: gh<_i142.PlaylistRepository>(),
          audioTrackRepository: gh<_i157.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i98.AudioStorageRepository>(),
        ));
    gh.factory<_i173.PlaylistCacheBloc>(() => _i173.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i159.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i119.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i128.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i174.ProjectCommentService>(
        () => _i174.ProjectCommentService(gh<_i155.AudioCommentRepository>()));
    gh.lazySingleton<_i175.ProjectTrackService>(() => _i175.ProjectTrackService(
          gh<_i157.AudioTrackRepository>(),
          gh<_i98.AudioStorageRepository>(),
        ));
    gh.factory<_i176.ProjectsBloc>(() => _i176.ProjectsBloc(
          createProject: gh<_i161.CreateProjectUseCase>(),
          updateProject: gh<_i148.UpdateProjectUseCase>(),
          deleteProject: gh<_i163.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i151.WatchAllProjectsUseCase>(),
          syncStatusProvider: gh<_i139.SyncStatusProvider>(),
        ));
    gh.factory<_i177.RestorePlaybackStateUseCase>(
        () => _i177.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i39.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i157.AudioTrackRepository>(),
              audioStorageRepository: gh<_i98.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i178.SendInvitationUseCase>(
        () => _i178.SendInvitationUseCase(
              invitationRepository: gh<_i75.InvitationRepository>(),
              notificationService: gh<_i32.NotificationService>(),
              findUserByEmail: gh<_i164.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i24.MagicLinkRepository>(),
              currentUserService: gh<_i112.CurrentUserService>(),
            ));
    gh.lazySingleton<_i179.SignInUseCase>(() => _i179.SignInUseCase(
          gh<_i103.AuthRepository>(),
          gh<_i149.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i180.SignOutUseCase>(() => _i180.SignOutUseCase(
          gh<_i103.AuthRepository>(),
          gh<_i149.UserProfileRepository>(),
        ));
    gh.factory<_i181.UpdateUserProfileUseCase>(
        () => _i181.UpdateUserProfileUseCase(
              gh<_i149.UserProfileRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i182.UploadAudioTrackUseCase>(
        () => _i182.UploadAudioTrackUseCase(
              gh<_i175.ProjectTrackService>(),
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i183.WatchCommentsByTrackUseCase>(() =>
        _i183.WatchCommentsByTrackUseCase(gh<_i174.ProjectCommentService>()));
    gh.lazySingleton<_i184.WatchTracksByProjectIdUseCase>(() =>
        _i184.WatchTracksByProjectIdUseCase(gh<_i157.AudioTrackRepository>()));
    gh.lazySingleton<_i185.AddAudioCommentUseCase>(
        () => _i185.AddAudioCommentUseCase(
              gh<_i174.ProjectCommentService>(),
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i186.AudioContextService>(
        () => _i187.AudioContextServiceImpl(
              userProfileRepository: gh<_i149.UserProfileRepository>(),
              audioTrackRepository: gh<_i157.AudioTrackRepository>(),
              projectsRepository: gh<_i144.ProjectsRepository>(),
            ));
    gh.factory<_i188.AudioPlayerService>(() => _i188.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i18.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i171.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i172.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i35.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i46.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i54.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i52.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i53.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i48.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i57.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i56.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i50.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i49.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i47.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i177.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i189.AuthBloc>(() => _i189.AuthBloc(
          signIn: gh<_i179.SignInUseCase>(),
          signUp: gh<_i130.SignUpUseCase>(),
          googleSignIn: gh<_i166.GoogleSignInUseCase>(),
        ));
    gh.lazySingleton<_i190.DeleteAudioCommentUseCase>(
        () => _i190.DeleteAudioCommentUseCase(
              gh<_i174.ProjectCommentService>(),
              gh<_i144.ProjectsRepository>(),
              gh<_i86.SessionStorage>(),
            ));
    gh.lazySingleton<_i191.DeleteAudioTrack>(() => _i191.DeleteAudioTrack(
          gh<_i86.SessionStorage>(),
          gh<_i144.ProjectsRepository>(),
          gh<_i175.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i192.EditAudioTrackUseCase>(
        () => _i192.EditAudioTrackUseCase(
              gh<_i175.ProjectTrackService>(),
              gh<_i144.ProjectsRepository>(),
            ));
    gh.factory<_i193.LoadTrackContextUseCase>(
        () => _i193.LoadTrackContextUseCase(gh<_i186.AudioContextService>()));
    gh.factory<_i194.ProjectInvitationActorBloc>(
        () => _i194.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i178.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i153.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i162.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i110.CancelInvitationUseCase>(),
            ));
    gh.factory<_i195.SessionService>(() => _i195.SessionService(
          checkAuthUseCase: gh<_i111.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i117.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i125.OnboardingUseCase>(),
          profileUseCase: gh<_i160.CheckProfileCompletenessUseCase>(),
          signOutUseCase: gh<_i180.SignOutUseCase>(),
        ));
    gh.factory<_i196.AppBootstrap>(() => _i196.AppBootstrap(
          sessionService: gh<_i195.SessionService>(),
          performanceCollector: gh<_i38.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i12.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i69.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i197.AppFlowBloc>(() => _i197.AppFlowBloc(
          appBootstrap: gh<_i196.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i141.BackgroundSyncCoordinator>(),
        ));
    gh.factory<_i198.AudioCommentBloc>(() => _i198.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i183.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i185.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i190.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i94.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i199.AudioContextBloc>(() => _i199.AudioContextBloc(
        loadTrackContextUseCase: gh<_i193.LoadTrackContextUseCase>()));
    gh.factory<_i200.AudioPlayerBloc>(() => _i200.AudioPlayerBloc(
        audioPlayerService: gh<_i188.AudioPlayerService>()));
    gh.factory<_i201.AudioTrackBloc>(() => _i201.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i184.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i191.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i182.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i192.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i202.GetCurrentUserDataUseCase>(
        () => _i202.GetCurrentUserDataUseCase(gh<_i195.SessionService>()));
    gh.factory<_i203.UserProfileBloc>(() => _i203.UserProfileBloc(
          updateUserProfileUseCase: gh<_i181.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i152.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i160.CheckProfileCompletenessUseCase>(),
          getCurrentUserDataUseCase: gh<_i202.GetCurrentUserDataUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i204.AppModule {}
