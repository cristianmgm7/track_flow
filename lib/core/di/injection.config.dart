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
    as _i20;
import 'package:isar/isar.dart' as _i22;
import 'package:shared_preferences/shared_preferences.dart' as _i52;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i87;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i199;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i198;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i113;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i116;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_id_usecase.dart'
    as _i118;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i119;
import 'package:trackflow/core/app_flow/domain/usecases/sign_out_usecase.dart'
    as _i181;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i200;
import 'package:trackflow/core/di/app_module.dart' as _i207;
import 'package:trackflow/core/network/network_state_manager.dart' as _i28;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i29;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i30;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i32;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i31;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i33;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i69;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i71;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i73;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i122;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i78;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i79;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i34;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i123;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i124;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i70;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i18;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i39;
import 'package:trackflow/core/session/current_user_service.dart' as _i114;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i37;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i38;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i97;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i103;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i35;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i84;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i86;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i94;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i143;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i83;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i140;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i56;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i88;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i133;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i89;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i90;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i134;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i91;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i161;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i130;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i174;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i66;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i67;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i99;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i101;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i108;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i98;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i107;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i6;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i16;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i117;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i131;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i142;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i62;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i157;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i175;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i186;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i192;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i184;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i201;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i138;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i188;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i195;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i189;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i202;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i190;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i136;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i19;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i36;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i172;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i173;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i178;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i41;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i137;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i203;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i160;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i102;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i159;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i176;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i193;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i194;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i183;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i185;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i204;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i104;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i106;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i74;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i105;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i168;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i180;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i132;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i191;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i75;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i21;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i77;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i76;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i155;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i112;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i164;
import 'package:trackflow/features/invitations/domain/usecases/find_user_by_email_usecase.dart'
    as _i166;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i120;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i80;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i81;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i179;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i197;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i129;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i23;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i24;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i26;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i25;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i115;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i72;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i46;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i61;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i171;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i187;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i156;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i170;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i148;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i149;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i96;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i196;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i27;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i82;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i126;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i127;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i125;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i139;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i42;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i43;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i145;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i144;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i95;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i128;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i45;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i44;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i147;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i85;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i146;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i163;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i167;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i150;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i153;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i177;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i59;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i93;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i152;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i151;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i92;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i162;
import 'package:trackflow/features/user_profile/domain/usecases/get_current_user_data_usecase.dart'
    as _i205;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i182;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i154;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i206;

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
    gh.factory<_i18.ImageMaintenanceService>(
        () => _i18.ImageMaintenanceService());
    gh.factory<_i19.InitializeAudioPlayerUseCase>(() =>
        _i19.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i20.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i21.InvitationRemoteDataSource>(() =>
        _i21.FirestoreInvitationRemoteDataSource(gh<_i14.FirebaseFirestore>()));
    await gh.factoryAsync<_i22.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i23.MagicLinkLocalDataSource>(
        () => _i23.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i24.MagicLinkRemoteDataSource>(
        () => _i24.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i14.FirebaseFirestore>(),
              deepLinkService: gh<_i10.DeepLinkService>(),
            ));
    gh.factory<_i25.MagicLinkRepository>(() =>
        _i26.MagicLinkRepositoryImp(gh<_i24.MagicLinkRemoteDataSource>()));
    gh.factory<_i27.NavigationCubit>(() => _i27.NavigationCubit());
    gh.lazySingleton<_i28.NetworkStateManager>(() => _i28.NetworkStateManager(
          gh<_i20.InternetConnectionChecker>(),
          gh<_i9.Connectivity>(),
        ));
    gh.lazySingleton<_i29.NotificationLocalDataSource>(
        () => _i29.IsarNotificationLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i30.NotificationRemoteDataSource>(() =>
        _i30.FirestoreNotificationRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i31.NotificationRepository>(
        () => _i32.NotificationRepositoryImpl(
              localDataSource: gh<_i29.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i30.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i33.NotificationService>(
        () => _i33.NotificationService(gh<_i31.NotificationRepository>()));
    gh.lazySingleton<_i34.ObserveNotificationsUseCase>(() =>
        _i34.ObserveNotificationsUseCase(gh<_i31.NotificationRepository>()));
    gh.factory<_i35.OperationExecutorFactory>(
        () => _i35.OperationExecutorFactory());
    gh.factory<_i36.PauseAudioUseCase>(() => _i36.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i37.PendingOperationsLocalDataSource>(
        () => _i37.IsarPendingOperationsLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i38.PendingOperationsRepository>(() =>
        _i38.PendingOperationsRepositoryImpl(
            gh<_i37.PendingOperationsLocalDataSource>()));
    gh.factory<_i39.PerformanceMetricsCollector>(
        () => _i39.PerformanceMetricsCollector());
    gh.lazySingleton<_i40.PlaybackPersistenceRepository>(
        () => _i41.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i42.PlaylistLocalDataSource>(
        () => _i42.PlaylistLocalDataSourceImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i43.PlaylistRemoteDataSource>(
        () => _i43.PlaylistRemoteDataSourceImpl(gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i44.ProjectRemoteDataSource>(() =>
        _i44.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i45.ProjectsLocalDataSource>(
        () => _i45.ProjectsLocalDataSourceImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i46.ResendMagicLinkUseCase>(
        () => _i46.ResendMagicLinkUseCase(gh<_i25.MagicLinkRepository>()));
    gh.factory<_i47.ResumeAudioUseCase>(() => _i47.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i48.SavePlaybackStateUseCase>(
        () => _i48.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i40.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i49.SeekAudioUseCase>(() =>
        _i49.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i50.SetPlaybackSpeedUseCase>(() => _i50.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i51.SetVolumeUseCase>(() =>
        _i51.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i52.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i53.SkipToNextUseCase>(() => _i53.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i54.SkipToPreviousUseCase>(() => _i54.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i55.StopAudioUseCase>(() =>
        _i55.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i56.SyncMetadataManager>(
        () => _i56.SyncMetadataManager());
    gh.factory<_i57.ToggleRepeatModeUseCase>(() => _i57.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i58.ToggleShuffleUseCase>(() => _i58.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i59.UserProfileLocalDataSource>(
        () => _i59.IsarUserProfileLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i60.UserProfileRemoteDataSource>(
        () => _i60.UserProfileRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i61.ValidateMagicLinkUseCase>(
        () => _i61.ValidateMagicLinkUseCase(gh<_i25.MagicLinkRepository>()));
    gh.lazySingleton<_i62.AudioCommentLocalDataSource>(
        () => _i62.IsarAudioCommentLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i63.AudioCommentRemoteDataSource>(() =>
        _i63.FirebaseAudioCommentRemoteDataSource(
            gh<_i14.FirebaseFirestore>()));
    gh.lazySingleton<_i64.AudioTrackLocalDataSource>(
        () => _i64.IsarAudioTrackLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i65.AudioTrackRemoteDataSource>(
        () => _i65.AudioTrackRemoteDataSourceImpl(
              gh<_i14.FirebaseFirestore>(),
              gh<_i15.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i66.CacheStorageLocalDataSource>(
        () => _i66.CacheStorageLocalDataSourceImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i67.CacheStorageRemoteDataSource>(() =>
        _i67.CacheStorageRemoteDataSourceImpl(gh<_i15.FirebaseStorage>()));
    gh.lazySingleton<_i68.ConsumeMagicLinkUseCase>(
        () => _i68.ConsumeMagicLinkUseCase(gh<_i25.MagicLinkRepository>()));
    gh.factory<_i69.CreateNotificationUseCase>(() =>
        _i69.CreateNotificationUseCase(gh<_i31.NotificationRepository>()));
    gh.factory<_i70.DatabaseHealthMonitor>(
        () => _i70.DatabaseHealthMonitor(gh<_i22.Isar>()));
    gh.factory<_i71.DeleteNotificationUseCase>(() =>
        _i71.DeleteNotificationUseCase(gh<_i31.NotificationRepository>()));
    gh.lazySingleton<_i72.GetMagicLinkStatusUseCase>(
        () => _i72.GetMagicLinkStatusUseCase(gh<_i25.MagicLinkRepository>()));
    gh.lazySingleton<_i73.GetUnreadNotificationsCountUseCase>(() =>
        _i73.GetUnreadNotificationsCountUseCase(
            gh<_i31.NotificationRepository>()));
    gh.lazySingleton<_i74.GoogleAuthService>(() => _i74.GoogleAuthService(
          gh<_i17.GoogleSignIn>(),
          gh<_i13.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i75.InvitationLocalDataSource>(
        () => _i75.IsarInvitationLocalDataSource(gh<_i22.Isar>()));
    gh.lazySingleton<_i76.InvitationRepository>(
        () => _i77.InvitationRepositoryImpl(
              localDataSource: gh<_i75.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i21.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
            ));
    gh.factory<_i78.MarkAsUnreadUseCase>(
        () => _i78.MarkAsUnreadUseCase(gh<_i31.NotificationRepository>()));
    gh.lazySingleton<_i79.MarkNotificationAsReadUseCase>(() =>
        _i79.MarkNotificationAsReadUseCase(gh<_i31.NotificationRepository>()));
    gh.lazySingleton<_i80.ObservePendingInvitationsUseCase>(() =>
        _i80.ObservePendingInvitationsUseCase(gh<_i76.InvitationRepository>()));
    gh.lazySingleton<_i81.ObserveSentInvitationsUseCase>(() =>
        _i81.ObserveSentInvitationsUseCase(gh<_i76.InvitationRepository>()));
    gh.lazySingleton<_i82.OnboardingStateLocalDataSource>(() =>
        _i82.OnboardingStateLocalDataSourceImpl(gh<_i52.SharedPreferences>()));
    gh.lazySingleton<_i83.PendingOperationsManager>(
        () => _i83.PendingOperationsManager(
              gh<_i38.PendingOperationsRepository>(),
              gh<_i28.NetworkStateManager>(),
              gh<_i35.OperationExecutorFactory>(),
            ));
    gh.factory<_i84.PlaylistOperationExecutor>(() =>
        _i84.PlaylistOperationExecutor(gh<_i43.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i85.ProjectIncrementalSyncService>(
        () => _i85.ProjectIncrementalSyncService(
              gh<_i44.ProjectRemoteDataSource>(),
              gh<_i45.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i86.ProjectOperationExecutor>(() =>
        _i86.ProjectOperationExecutor(gh<_i44.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i87.SessionStorage>(
        () => _i87.SessionStorageImpl(prefs: gh<_i52.SharedPreferences>()));
    gh.lazySingleton<_i88.SyncAudioCommentsUseCase>(
        () => _i88.SyncAudioCommentsUseCase(
              gh<_i63.AudioCommentRemoteDataSource>(),
              gh<_i62.AudioCommentLocalDataSource>(),
              gh<_i44.ProjectRemoteDataSource>(),
              gh<_i87.SessionStorage>(),
              gh<_i65.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i89.SyncNotificationsUseCase>(
        () => _i89.SyncNotificationsUseCase(
              gh<_i31.NotificationRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i90.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i90.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i85.ProjectIncrementalSyncService>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i91.SyncUserProfileUseCase>(
        () => _i91.SyncUserProfileUseCase(
              gh<_i60.UserProfileRemoteDataSource>(),
              gh<_i59.UserProfileLocalDataSource>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i92.UserProfileCacheRepository>(
        () => _i93.UserProfileCacheRepositoryImpl(
              gh<_i60.UserProfileRemoteDataSource>(),
              gh<_i59.UserProfileLocalDataSource>(),
              gh<_i28.NetworkStateManager>(),
            ));
    gh.factory<_i94.UserProfileOperationExecutor>(() =>
        _i94.UserProfileOperationExecutor(
            gh<_i60.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i95.WatchProjectDetailUseCase>(
        () => _i95.WatchProjectDetailUseCase(
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i59.UserProfileLocalDataSource>(),
              gh<_i62.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i96.WatchUserProfilesUseCase>(() =>
        _i96.WatchUserProfilesUseCase(gh<_i92.UserProfileCacheRepository>()));
    gh.factory<_i97.AudioCommentOperationExecutor>(() =>
        _i97.AudioCommentOperationExecutor(
            gh<_i63.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i98.AudioDownloadRepository>(() =>
        _i99.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i67.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i100.AudioStorageRepository>(() =>
        _i101.AudioStorageRepositoryImpl(
            localDataSource: gh<_i66.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i102.AudioTrackIncrementalSyncService>(
        () => _i102.AudioTrackIncrementalSyncService(
              gh<_i65.AudioTrackRemoteDataSource>(),
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i44.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i103.AudioTrackOperationExecutor>(() =>
        _i103.AudioTrackOperationExecutor(
            gh<_i65.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i104.AuthRemoteDataSource>(
        () => _i104.AuthRemoteDataSourceImpl(
              gh<_i13.FirebaseAuth>(),
              gh<_i17.GoogleSignIn>(),
              gh<_i74.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i105.AuthRepository>(() => _i106.AuthRepositoryImpl(
          remote: gh<_i104.AuthRemoteDataSource>(),
          sessionStorage: gh<_i87.SessionStorage>(),
          networkStateManager: gh<_i28.NetworkStateManager>(),
          googleAuthService: gh<_i74.GoogleAuthService>(),
        ));
    gh.lazySingleton<_i107.CacheKeyRepository>(() =>
        _i108.CacheKeyRepositoryImpl(
            localDataSource: gh<_i66.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i109.CacheMaintenanceRepository>(() =>
        _i110.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i66.CacheStorageLocalDataSource>()));
    gh.factory<_i111.CacheTrackUseCase>(() => _i111.CacheTrackUseCase(
          gh<_i98.AudioDownloadRepository>(),
          gh<_i100.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i112.CancelInvitationUseCase>(
        () => _i112.CancelInvitationUseCase(gh<_i76.InvitationRepository>()));
    gh.factory<_i113.CheckAuthenticationStatusUseCase>(() =>
        _i113.CheckAuthenticationStatusUseCase(gh<_i105.AuthRepository>()));
    gh.factory<_i114.CurrentUserService>(
        () => _i114.CurrentUserService(gh<_i87.SessionStorage>()));
    gh.lazySingleton<_i115.GenerateMagicLinkUseCase>(
        () => _i115.GenerateMagicLinkUseCase(
              gh<_i25.MagicLinkRepository>(),
              gh<_i105.AuthRepository>(),
            ));
    gh.lazySingleton<_i116.GetAuthStateUseCase>(
        () => _i116.GetAuthStateUseCase(gh<_i105.AuthRepository>()));
    gh.factory<_i117.GetCachedTrackPathUseCase>(() =>
        _i117.GetCachedTrackPathUseCase(gh<_i100.AudioStorageRepository>()));
    gh.factory<_i118.GetCurrentUserIdUseCase>(
        () => _i118.GetCurrentUserIdUseCase(gh<_i105.AuthRepository>()));
    gh.factory<_i119.GetCurrentUserUseCase>(
        () => _i119.GetCurrentUserUseCase(gh<_i105.AuthRepository>()));
    gh.lazySingleton<_i120.GetPendingInvitationsCountUseCase>(() =>
        _i120.GetPendingInvitationsCountUseCase(
            gh<_i76.InvitationRepository>()));
    gh.factory<_i121.GetPlaylistCacheStatusUseCase>(() =>
        _i121.GetPlaylistCacheStatusUseCase(
            gh<_i100.AudioStorageRepository>()));
    gh.factory<_i122.MarkAllNotificationsAsReadUseCase>(
        () => _i122.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i31.NotificationRepository>(),
              currentUserService: gh<_i114.CurrentUserService>(),
            ));
    gh.factory<_i123.NotificationActorBloc>(() => _i123.NotificationActorBloc(
          createNotificationUseCase: gh<_i69.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i79.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i78.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i122.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i71.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i124.NotificationWatcherBloc>(
        () => _i124.NotificationWatcherBloc(
              notificationRepository: gh<_i31.NotificationRepository>(),
              currentUserService: gh<_i114.CurrentUserService>(),
            ));
    gh.lazySingleton<_i125.OnboardingRepository>(() =>
        _i126.OnboardingRepositoryImpl(
            gh<_i82.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i127.OnboardingUseCase>(
        () => _i127.OnboardingUseCase(gh<_i125.OnboardingRepository>()));
    gh.factory<_i128.ProjectDetailBloc>(() => _i128.ProjectDetailBloc(
        watchProjectDetail: gh<_i95.WatchProjectDetailUseCase>()));
    gh.factory<_i129.ProjectInvitationWatcherBloc>(
        () => _i129.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i76.InvitationRepository>(),
              currentUserService: gh<_i114.CurrentUserService>(),
            ));
    gh.factory<_i130.RemovePlaylistCacheUseCase>(() =>
        _i130.RemovePlaylistCacheUseCase(gh<_i100.AudioStorageRepository>()));
    gh.factory<_i131.RemoveTrackCacheUseCase>(() =>
        _i131.RemoveTrackCacheUseCase(gh<_i100.AudioStorageRepository>()));
    gh.lazySingleton<_i132.SignUpUseCase>(
        () => _i132.SignUpUseCase(gh<_i105.AuthRepository>()));
    gh.lazySingleton<_i133.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i133.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i102.AudioTrackIncrementalSyncService>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i134.SyncUserProfileCollaboratorsUseCase>(
        () => _i134.SyncUserProfileCollaboratorsUseCase(
              gh<_i45.ProjectsLocalDataSource>(),
              gh<_i92.UserProfileCacheRepository>(),
            ));
    gh.factory<_i135.WatchTrackCacheStatusUseCase>(() =>
        _i135.WatchTrackCacheStatusUseCase(gh<_i100.AudioStorageRepository>()));
    gh.factory<_i136.AudioSourceResolver>(() => _i137.AudioSourceResolverImpl(
          gh<_i100.AudioStorageRepository>(),
          gh<_i98.AudioDownloadRepository>(),
        ));
    gh.factory<_i138.AudioWaveformBloc>(() => _i138.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i117.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i139.OnboardingBloc>(() => _i139.OnboardingBloc(
          onboardingUseCase: gh<_i127.OnboardingUseCase>(),
          getCurrentUserIdUseCase: gh<_i118.GetCurrentUserIdUseCase>(),
        ));
    gh.factory<_i140.SyncDataManager>(() => _i140.SyncDataManager(
          syncProjects: gh<_i90.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i133.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i88.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i91.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i134.SyncUserProfileCollaboratorsUseCase>(),
          syncNotifications: gh<_i89.SyncNotificationsUseCase>(),
        ));
    gh.factory<_i141.SyncStatusProvider>(() => _i141.SyncStatusProvider(
          syncDataManager: gh<_i140.SyncDataManager>(),
          pendingOperationsManager: gh<_i83.PendingOperationsManager>(),
        ));
    gh.factory<_i142.TrackCacheBloc>(() => _i142.TrackCacheBloc(
          cacheTrackUseCase: gh<_i111.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i135.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i131.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i117.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i143.BackgroundSyncCoordinator>(
        () => _i143.BackgroundSyncCoordinator(
              gh<_i28.NetworkStateManager>(),
              gh<_i140.SyncDataManager>(),
              gh<_i83.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i144.PlaylistRepository>(
        () => _i145.PlaylistRepositoryImpl(
              localDataSource: gh<_i42.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i143.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i83.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i146.ProjectsRepository>(
        () => _i147.ProjectsRepositoryImpl(
              localDataSource: gh<_i45.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i143.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i83.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i148.RemoveCollaboratorUseCase>(
        () => _i148.RemoveCollaboratorUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i149.UpdateCollaboratorRoleUseCase>(
        () => _i149.UpdateCollaboratorRoleUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i150.UpdateProjectUseCase>(
        () => _i150.UpdateProjectUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i151.UserProfileRepository>(
        () => _i152.UserProfileRepositoryImpl(
              localDataSource: gh<_i59.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i60.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i143.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i83.PendingOperationsManager>(),
              firestore: gh<_i14.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i153.WatchAllProjectsUseCase>(
        () => _i153.WatchAllProjectsUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i154.WatchUserProfileUseCase>(
        () => _i154.WatchUserProfileUseCase(
              gh<_i151.UserProfileRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i155.AcceptInvitationUseCase>(
        () => _i155.AcceptInvitationUseCase(
              invitationRepository: gh<_i76.InvitationRepository>(),
              projectRepository: gh<_i146.ProjectsRepository>(),
              userProfileRepository: gh<_i151.UserProfileRepository>(),
              notificationService: gh<_i33.NotificationService>(),
            ));
    gh.lazySingleton<_i156.AddCollaboratorToProjectUseCase>(
        () => _i156.AddCollaboratorToProjectUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i157.AudioCommentRepository>(
        () => _i158.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i63.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i62.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i28.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i143.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i83.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i159.AudioTrackRepository>(
        () => _i160.AudioTrackRepositoryImpl(
              gh<_i64.AudioTrackLocalDataSource>(),
              gh<_i143.BackgroundSyncCoordinator>(),
              gh<_i83.PendingOperationsManager>(),
            ));
    gh.factory<_i161.CachePlaylistUseCase>(() => _i161.CachePlaylistUseCase(
          gh<_i98.AudioDownloadRepository>(),
          gh<_i159.AudioTrackRepository>(),
        ));
    gh.factory<_i162.CheckProfileCompletenessUseCase>(() =>
        _i162.CheckProfileCompletenessUseCase(
            gh<_i151.UserProfileRepository>()));
    gh.lazySingleton<_i163.CreateProjectUseCase>(
        () => _i163.CreateProjectUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i164.DeclineInvitationUseCase>(
        () => _i164.DeclineInvitationUseCase(
              invitationRepository: gh<_i76.InvitationRepository>(),
              projectRepository: gh<_i146.ProjectsRepository>(),
              userProfileRepository: gh<_i151.UserProfileRepository>(),
              notificationService: gh<_i33.NotificationService>(),
            ));
    gh.lazySingleton<_i165.DeleteProjectUseCase>(
        () => _i165.DeleteProjectUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.FindUserByEmailUseCase>(
        () => _i166.FindUserByEmailUseCase(gh<_i151.UserProfileRepository>()));
    gh.lazySingleton<_i167.GetProjectByIdUseCase>(
        () => _i167.GetProjectByIdUseCase(gh<_i146.ProjectsRepository>()));
    gh.lazySingleton<_i168.GoogleSignInUseCase>(() => _i168.GoogleSignInUseCase(
          gh<_i105.AuthRepository>(),
          gh<_i151.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i169.JoinProjectWithIdUseCase>(
        () => _i169.JoinProjectWithIdUseCase(
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i170.LeaveProjectUseCase>(() => _i170.LeaveProjectUseCase(
          gh<_i146.ProjectsRepository>(),
          gh<_i87.SessionStorage>(),
        ));
    gh.factory<_i171.MagicLinkBloc>(() => _i171.MagicLinkBloc(
          generateMagicLink: gh<_i115.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i61.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i68.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i46.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i72.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i169.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i105.AuthRepository>(),
        ));
    gh.factory<_i172.PlayAudioUseCase>(() => _i172.PlayAudioUseCase(
          audioTrackRepository: gh<_i159.AudioTrackRepository>(),
          audioStorageRepository: gh<_i100.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i173.PlayPlaylistUseCase>(() => _i173.PlayPlaylistUseCase(
          playlistRepository: gh<_i144.PlaylistRepository>(),
          audioTrackRepository: gh<_i159.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i100.AudioStorageRepository>(),
        ));
    gh.factory<_i174.PlaylistCacheBloc>(() => _i174.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i161.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i121.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i130.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i175.ProjectCommentService>(
        () => _i175.ProjectCommentService(gh<_i157.AudioCommentRepository>()));
    gh.lazySingleton<_i176.ProjectTrackService>(() => _i176.ProjectTrackService(
          gh<_i159.AudioTrackRepository>(),
          gh<_i100.AudioStorageRepository>(),
        ));
    gh.factory<_i177.ProjectsBloc>(() => _i177.ProjectsBloc(
          createProject: gh<_i163.CreateProjectUseCase>(),
          updateProject: gh<_i150.UpdateProjectUseCase>(),
          deleteProject: gh<_i165.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i153.WatchAllProjectsUseCase>(),
          syncStatusProvider: gh<_i141.SyncStatusProvider>(),
        ));
    gh.factory<_i178.RestorePlaybackStateUseCase>(
        () => _i178.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i40.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i159.AudioTrackRepository>(),
              audioStorageRepository: gh<_i100.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i179.SendInvitationUseCase>(
        () => _i179.SendInvitationUseCase(
              invitationRepository: gh<_i76.InvitationRepository>(),
              notificationService: gh<_i33.NotificationService>(),
              findUserByEmail: gh<_i166.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i25.MagicLinkRepository>(),
              currentUserService: gh<_i114.CurrentUserService>(),
            ));
    gh.lazySingleton<_i180.SignInUseCase>(() => _i180.SignInUseCase(
          gh<_i105.AuthRepository>(),
          gh<_i151.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i181.SignOutUseCase>(() => _i181.SignOutUseCase(
          gh<_i105.AuthRepository>(),
          gh<_i151.UserProfileRepository>(),
        ));
    gh.factory<_i182.UpdateUserProfileUseCase>(
        () => _i182.UpdateUserProfileUseCase(
              gh<_i151.UserProfileRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i183.UploadAudioTrackUseCase>(
        () => _i183.UploadAudioTrackUseCase(
              gh<_i176.ProjectTrackService>(),
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i184.WatchCommentsByTrackUseCase>(() =>
        _i184.WatchCommentsByTrackUseCase(gh<_i175.ProjectCommentService>()));
    gh.lazySingleton<_i185.WatchTracksByProjectIdUseCase>(() =>
        _i185.WatchTracksByProjectIdUseCase(gh<_i159.AudioTrackRepository>()));
    gh.lazySingleton<_i186.AddAudioCommentUseCase>(
        () => _i186.AddAudioCommentUseCase(
              gh<_i175.ProjectCommentService>(),
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i187.AddCollaboratorByEmailUseCase>(
        () => _i187.AddCollaboratorByEmailUseCase(
              gh<_i166.FindUserByEmailUseCase>(),
              gh<_i156.AddCollaboratorToProjectUseCase>(),
              gh<_i33.NotificationService>(),
            ));
    gh.lazySingleton<_i188.AudioContextService>(
        () => _i189.AudioContextServiceImpl(
              userProfileRepository: gh<_i151.UserProfileRepository>(),
              audioTrackRepository: gh<_i159.AudioTrackRepository>(),
              projectsRepository: gh<_i146.ProjectsRepository>(),
            ));
    gh.factory<_i190.AudioPlayerService>(() => _i190.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i19.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i172.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i173.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i36.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i47.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i55.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i53.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i54.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i49.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i58.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i57.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i51.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i50.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i48.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i178.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i191.AuthBloc>(() => _i191.AuthBloc(
          signIn: gh<_i180.SignInUseCase>(),
          signUp: gh<_i132.SignUpUseCase>(),
          googleSignIn: gh<_i168.GoogleSignInUseCase>(),
        ));
    gh.lazySingleton<_i192.DeleteAudioCommentUseCase>(
        () => _i192.DeleteAudioCommentUseCase(
              gh<_i175.ProjectCommentService>(),
              gh<_i146.ProjectsRepository>(),
              gh<_i87.SessionStorage>(),
            ));
    gh.lazySingleton<_i193.DeleteAudioTrack>(() => _i193.DeleteAudioTrack(
          gh<_i87.SessionStorage>(),
          gh<_i146.ProjectsRepository>(),
          gh<_i176.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i194.EditAudioTrackUseCase>(
        () => _i194.EditAudioTrackUseCase(
              gh<_i176.ProjectTrackService>(),
              gh<_i146.ProjectsRepository>(),
            ));
    gh.factory<_i195.LoadTrackContextUseCase>(
        () => _i195.LoadTrackContextUseCase(gh<_i188.AudioContextService>()));
    gh.factory<_i196.ManageCollaboratorsBloc>(() =>
        _i196.ManageCollaboratorsBloc(
          addCollaboratorUseCase: gh<_i156.AddCollaboratorToProjectUseCase>(),
          removeCollaboratorUseCase: gh<_i148.RemoveCollaboratorUseCase>(),
          updateCollaboratorRoleUseCase:
              gh<_i149.UpdateCollaboratorRoleUseCase>(),
          leaveProjectUseCase: gh<_i170.LeaveProjectUseCase>(),
          watchUserProfilesUseCase: gh<_i96.WatchUserProfilesUseCase>(),
          findUserByEmailUseCase: gh<_i166.FindUserByEmailUseCase>(),
          addCollaboratorByEmailUseCase:
              gh<_i187.AddCollaboratorByEmailUseCase>(),
        ));
    gh.factory<_i197.ProjectInvitationActorBloc>(
        () => _i197.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i179.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i155.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i164.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i112.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i166.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i198.SessionService>(() => _i198.SessionService(
          checkAuthUseCase: gh<_i113.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i119.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i127.OnboardingUseCase>(),
          profileUseCase: gh<_i162.CheckProfileCompletenessUseCase>(),
          signOutUseCase: gh<_i181.SignOutUseCase>(),
        ));
    gh.factory<_i199.AppBootstrap>(() => _i199.AppBootstrap(
          sessionService: gh<_i198.SessionService>(),
          performanceCollector: gh<_i39.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i12.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i70.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i200.AppFlowBloc>(() => _i200.AppFlowBloc(
          appBootstrap: gh<_i199.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i143.BackgroundSyncCoordinator>(),
        ));
    gh.factory<_i201.AudioCommentBloc>(() => _i201.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i184.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i186.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i192.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i96.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i202.AudioContextBloc>(() => _i202.AudioContextBloc(
        loadTrackContextUseCase: gh<_i195.LoadTrackContextUseCase>()));
    gh.factory<_i203.AudioPlayerBloc>(() => _i203.AudioPlayerBloc(
        audioPlayerService: gh<_i190.AudioPlayerService>()));
    gh.factory<_i204.AudioTrackBloc>(() => _i204.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i185.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i193.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i183.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i194.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i205.GetCurrentUserDataUseCase>(
        () => _i205.GetCurrentUserDataUseCase(gh<_i198.SessionService>()));
    gh.factory<_i206.UserProfileBloc>(() => _i206.UserProfileBloc(
          updateUserProfileUseCase: gh<_i182.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i154.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i162.CheckProfileCompletenessUseCase>(),
          getCurrentUserDataUseCase: gh<_i205.GetCurrentUserDataUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i207.AppModule {}
