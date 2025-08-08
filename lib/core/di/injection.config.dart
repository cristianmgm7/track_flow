// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i12;

import 'package:cloud_firestore/cloud_firestore.dart' as _i16;
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:firebase_auth/firebase_auth.dart' as _i15;
import 'package:firebase_storage/firebase_storage.dart' as _i17;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i19;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i22;
import 'package:isar/isar.dart' as _i24;
import 'package:shared_preferences/shared_preferences.dart' as _i54;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i89;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i14;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i192;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i6;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i182;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i183;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i115;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i118;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i120;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i193;
import 'package:trackflow/core/di/app_module.dart' as _i208;
import 'package:trackflow/core/network/network_state_manager.dart' as _i30;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i31;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i32;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i34;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i33;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i35;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i71;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i73;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i75;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i123;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i80;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i36;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i124;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i125;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i72;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i13;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i20;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i41;
import 'package:trackflow/core/session/current_user_service.dart' as _i116;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i99;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i86;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i88;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i96;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i145;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i85;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i142;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i58;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i143;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i90;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i135;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i91;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i92;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i136;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i93;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i163;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i131;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i176;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i68;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i69;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i101;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i7;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i9;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i18;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i132;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i137;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i144;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i160;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i159;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i177;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i190;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i198;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i188;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i204;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i140;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i194;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i201;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i195;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i205;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i196;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i138;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i174;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i175;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i180;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i43;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i139;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i206;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i66;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i67;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i162;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i104;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i161;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i178;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i200;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i186;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i189;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i207;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i106;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i108;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i76;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i107;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i170;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i184;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i133;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i134;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i197;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i77;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i23;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i79;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i78;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i157;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i114;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i166;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i121;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i82;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i83;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i181;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i203;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i130;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i26;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i28;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i70;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i117;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i74;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i48;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i63;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i173;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i191;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i158;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i168;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i171;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i172;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i150;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i151;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i202;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i29;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i84;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i128;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i126;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i141;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i147;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i146;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i97;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i129;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i47;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i149;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i87;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i148;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i167;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i169;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i152;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i155;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i179;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i61;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i62;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i95;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i154;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i153;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i94;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i164;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i185;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i156;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i98;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i187;

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
    gh.singleton<_i6.BlocStateCleanupService>(
        () => _i6.BlocStateCleanupService());
    gh.lazySingleton<_i7.CacheMaintenanceService>(
        () => _i8.CacheMaintenanceServiceImpl());
    gh.factory<_i9.CleanupCacheUseCase>(
        () => _i9.CleanupCacheUseCase(gh<_i7.CacheMaintenanceService>()));
    gh.lazySingleton<_i5.ConflictResolutionServiceImpl<dynamic>>(
        () => _i5.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i10.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i11.DeepLinkService>(() => _i11.DeepLinkService());
    await gh.factoryAsync<_i12.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i13.DynamicLinkService>(() => _i13.DynamicLinkService());
    gh.factory<_i14.ExampleComplexBloc>(() => _i14.ExampleComplexBloc());
    gh.factory<_i14.ExampleConditionalBloc>(
        () => _i14.ExampleConditionalBloc());
    gh.factory<_i14.ExampleNavigationCubit>(
        () => _i14.ExampleNavigationCubit());
    gh.factory<_i14.ExampleSimpleBloc>(() => _i14.ExampleSimpleBloc());
    gh.factory<_i14.ExampleUserProfileBloc>(
        () => _i14.ExampleUserProfileBloc());
    gh.lazySingleton<_i15.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i16.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i17.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i18.GetCacheStorageStatsUseCase>(() =>
        _i18.GetCacheStorageStatsUseCase(gh<_i7.CacheMaintenanceService>()));
    gh.lazySingleton<_i19.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i20.ImageMaintenanceService>(
        () => _i20.ImageMaintenanceService());
    gh.factory<_i21.InitializeAudioPlayerUseCase>(() =>
        _i21.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i22.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i23.InvitationRemoteDataSource>(() =>
        _i23.FirestoreInvitationRemoteDataSource(gh<_i16.FirebaseFirestore>()));
    await gh.factoryAsync<_i24.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i25.MagicLinkLocalDataSource>(
        () => _i25.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i26.MagicLinkRemoteDataSource>(
        () => _i26.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i16.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i27.MagicLinkRepository>(() =>
        _i28.MagicLinkRepositoryImp(gh<_i26.MagicLinkRemoteDataSource>()));
    gh.factory<_i29.NavigationCubit>(() => _i29.NavigationCubit());
    gh.lazySingleton<_i30.NetworkStateManager>(() => _i30.NetworkStateManager(
          gh<_i22.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.lazySingleton<_i31.NotificationLocalDataSource>(
        () => _i31.IsarNotificationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i32.NotificationRemoteDataSource>(() =>
        _i32.FirestoreNotificationRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i33.NotificationRepository>(
        () => _i34.NotificationRepositoryImpl(
              localDataSource: gh<_i31.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i32.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i35.NotificationService>(
        () => _i35.NotificationService(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i36.ObserveNotificationsUseCase>(() =>
        _i36.ObserveNotificationsUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i37.OperationExecutorFactory>(
        () => _i37.OperationExecutorFactory());
    gh.factory<_i38.PauseAudioUseCase>(() => _i38.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i39.PendingOperationsLocalDataSource>(
        () => _i39.IsarPendingOperationsLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i40.PendingOperationsRepository>(() =>
        _i40.PendingOperationsRepositoryImpl(
            gh<_i39.PendingOperationsLocalDataSource>()));
    gh.factory<_i41.PerformanceMetricsCollector>(
        () => _i41.PerformanceMetricsCollector());
    gh.lazySingleton<_i42.PlaybackPersistenceRepository>(
        () => _i43.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i44.PlaylistLocalDataSource>(
        () => _i44.PlaylistLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i45.PlaylistRemoteDataSource>(
        () => _i45.PlaylistRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i46.ProjectRemoteDataSource>(() =>
        _i46.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i47.ProjectsLocalDataSource>(
        () => _i47.ProjectsLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i48.ResendMagicLinkUseCase>(
        () => _i48.ResendMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i49.ResumeAudioUseCase>(() => _i49.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i50.SavePlaybackStateUseCase>(
        () => _i50.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i42.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i51.SeekAudioUseCase>(() =>
        _i51.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i52.SetPlaybackSpeedUseCase>(() => _i52.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i53.SetVolumeUseCase>(() =>
        _i53.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i54.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i55.SkipToNextUseCase>(() => _i55.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i56.SkipToPreviousUseCase>(() => _i56.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i57.StopAudioUseCase>(() =>
        _i57.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i58.SyncMetadataManager>(
        () => _i58.SyncMetadataManager());
    gh.factory<_i59.ToggleRepeatModeUseCase>(() => _i59.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i60.ToggleShuffleUseCase>(() => _i60.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i61.UserProfileLocalDataSource>(
        () => _i61.IsarUserProfileLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i62.UserProfileRemoteDataSource>(
        () => _i62.UserProfileRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i63.ValidateMagicLinkUseCase>(
        () => _i63.ValidateMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.lazySingleton<_i64.AudioCommentLocalDataSource>(
        () => _i64.IsarAudioCommentLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i65.AudioCommentRemoteDataSource>(() =>
        _i65.FirebaseAudioCommentRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i66.AudioTrackLocalDataSource>(
        () => _i66.IsarAudioTrackLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i67.AudioTrackRemoteDataSource>(
        () => _i67.AudioTrackRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i68.CacheStorageLocalDataSource>(
        () => _i68.CacheStorageLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i69.CacheStorageRemoteDataSource>(() =>
        _i69.CacheStorageRemoteDataSourceImpl(gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i70.ConsumeMagicLinkUseCase>(
        () => _i70.ConsumeMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i71.CreateNotificationUseCase>(() =>
        _i71.CreateNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i72.DatabaseHealthMonitor>(
        () => _i72.DatabaseHealthMonitor(gh<_i24.Isar>()));
    gh.factory<_i73.DeleteNotificationUseCase>(() =>
        _i73.DeleteNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i74.GetMagicLinkStatusUseCase>(
        () => _i74.GetMagicLinkStatusUseCase(gh<_i27.MagicLinkRepository>()));
    gh.lazySingleton<_i75.GetUnreadNotificationsCountUseCase>(() =>
        _i75.GetUnreadNotificationsCountUseCase(
            gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i76.GoogleAuthService>(() => _i76.GoogleAuthService(
          gh<_i19.GoogleSignIn>(),
          gh<_i15.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i77.InvitationLocalDataSource>(
        () => _i77.IsarInvitationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i78.InvitationRepository>(
        () => _i79.InvitationRepositoryImpl(
              localDataSource: gh<_i77.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i23.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
            ));
    gh.factory<_i80.MarkAsUnreadUseCase>(
        () => _i80.MarkAsUnreadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i81.MarkNotificationAsReadUseCase>(() =>
        _i81.MarkNotificationAsReadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i82.ObservePendingInvitationsUseCase>(() =>
        _i82.ObservePendingInvitationsUseCase(gh<_i78.InvitationRepository>()));
    gh.lazySingleton<_i83.ObserveSentInvitationsUseCase>(() =>
        _i83.ObserveSentInvitationsUseCase(gh<_i78.InvitationRepository>()));
    gh.lazySingleton<_i84.OnboardingStateLocalDataSource>(() =>
        _i84.OnboardingStateLocalDataSourceImpl(gh<_i54.SharedPreferences>()));
    gh.lazySingleton<_i85.PendingOperationsManager>(
        () => _i85.PendingOperationsManager(
              gh<_i40.PendingOperationsRepository>(),
              gh<_i30.NetworkStateManager>(),
              gh<_i37.OperationExecutorFactory>(),
            ));
    gh.factory<_i86.PlaylistOperationExecutor>(() =>
        _i86.PlaylistOperationExecutor(gh<_i45.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i87.ProjectIncrementalSyncService>(
        () => _i87.ProjectIncrementalSyncService(
              gh<_i46.ProjectRemoteDataSource>(),
              gh<_i47.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i88.ProjectOperationExecutor>(() =>
        _i88.ProjectOperationExecutor(gh<_i46.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i89.SessionStorage>(
        () => _i89.SessionStorageImpl(prefs: gh<_i54.SharedPreferences>()));
    gh.lazySingleton<_i90.SyncAudioCommentsUseCase>(
        () => _i90.SyncAudioCommentsUseCase(
              gh<_i65.AudioCommentRemoteDataSource>(),
              gh<_i64.AudioCommentLocalDataSource>(),
              gh<_i46.ProjectRemoteDataSource>(),
              gh<_i89.SessionStorage>(),
              gh<_i67.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i91.SyncNotificationsUseCase>(
        () => _i91.SyncNotificationsUseCase(
              gh<_i33.NotificationRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i92.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i92.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i87.ProjectIncrementalSyncService>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i93.SyncUserProfileUseCase>(
        () => _i93.SyncUserProfileUseCase(
              gh<_i62.UserProfileRemoteDataSource>(),
              gh<_i61.UserProfileLocalDataSource>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i94.UserProfileCacheRepository>(
        () => _i95.UserProfileCacheRepositoryImpl(
              gh<_i62.UserProfileRemoteDataSource>(),
              gh<_i61.UserProfileLocalDataSource>(),
              gh<_i30.NetworkStateManager>(),
            ));
    gh.factory<_i96.UserProfileOperationExecutor>(() =>
        _i96.UserProfileOperationExecutor(
            gh<_i62.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i97.WatchProjectDetailUseCase>(
        () => _i97.WatchProjectDetailUseCase(
              gh<_i66.AudioTrackLocalDataSource>(),
              gh<_i61.UserProfileLocalDataSource>(),
              gh<_i64.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i98.WatchUserProfilesUseCase>(() =>
        _i98.WatchUserProfilesUseCase(gh<_i94.UserProfileCacheRepository>()));
    gh.factory<_i99.AudioCommentOperationExecutor>(() =>
        _i99.AudioCommentOperationExecutor(
            gh<_i65.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i100.AudioDownloadRepository>(() =>
        _i101.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i69.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i102.AudioStorageRepository>(() =>
        _i103.AudioStorageRepositoryImpl(
            localDataSource: gh<_i68.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i104.AudioTrackIncrementalSyncService>(
        () => _i104.AudioTrackIncrementalSyncService(
              gh<_i67.AudioTrackRemoteDataSource>(),
              gh<_i66.AudioTrackLocalDataSource>(),
              gh<_i46.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i105.AudioTrackOperationExecutor>(() =>
        _i105.AudioTrackOperationExecutor(
            gh<_i67.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i106.AuthRemoteDataSource>(
        () => _i106.AuthRemoteDataSourceImpl(
              gh<_i15.FirebaseAuth>(),
              gh<_i76.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i107.AuthRepository>(() => _i108.AuthRepositoryImpl(
          remote: gh<_i106.AuthRemoteDataSource>(),
          sessionStorage: gh<_i89.SessionStorage>(),
          networkStateManager: gh<_i30.NetworkStateManager>(),
          googleAuthService: gh<_i76.GoogleAuthService>(),
        ));
    gh.lazySingleton<_i109.CacheKeyRepository>(() =>
        _i110.CacheKeyRepositoryImpl(
            localDataSource: gh<_i68.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i111.CacheMaintenanceRepository>(() =>
        _i112.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i68.CacheStorageLocalDataSource>()));
    gh.factory<_i113.CacheTrackUseCase>(() => _i113.CacheTrackUseCase(
          gh<_i100.AudioDownloadRepository>(),
          gh<_i102.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i114.CancelInvitationUseCase>(
        () => _i114.CancelInvitationUseCase(gh<_i78.InvitationRepository>()));
    gh.factory<_i115.CheckAuthenticationStatusUseCase>(() =>
        _i115.CheckAuthenticationStatusUseCase(gh<_i107.AuthRepository>()));
    gh.factory<_i116.CurrentUserService>(
        () => _i116.CurrentUserService(gh<_i89.SessionStorage>()));
    gh.lazySingleton<_i117.GenerateMagicLinkUseCase>(
        () => _i117.GenerateMagicLinkUseCase(
              gh<_i27.MagicLinkRepository>(),
              gh<_i107.AuthRepository>(),
            ));
    gh.lazySingleton<_i118.GetAuthStateUseCase>(
        () => _i118.GetAuthStateUseCase(gh<_i107.AuthRepository>()));
    gh.factory<_i119.GetCachedTrackPathUseCase>(() =>
        _i119.GetCachedTrackPathUseCase(gh<_i102.AudioStorageRepository>()));
    gh.factory<_i120.GetCurrentUserUseCase>(
        () => _i120.GetCurrentUserUseCase(gh<_i107.AuthRepository>()));
    gh.lazySingleton<_i121.GetPendingInvitationsCountUseCase>(() =>
        _i121.GetPendingInvitationsCountUseCase(
            gh<_i78.InvitationRepository>()));
    gh.factory<_i122.GetPlaylistCacheStatusUseCase>(() =>
        _i122.GetPlaylistCacheStatusUseCase(
            gh<_i102.AudioStorageRepository>()));
    gh.factory<_i123.MarkAllNotificationsAsReadUseCase>(
        () => _i123.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i124.NotificationActorBloc>(() => _i124.NotificationActorBloc(
          createNotificationUseCase: gh<_i71.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i81.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i80.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i123.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i73.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i125.NotificationWatcherBloc>(
        () => _i125.NotificationWatcherBloc(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.lazySingleton<_i126.OnboardingRepository>(() =>
        _i127.OnboardingRepositoryImpl(
            gh<_i84.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i128.OnboardingUseCase>(
        () => _i128.OnboardingUseCase(gh<_i126.OnboardingRepository>()));
    gh.factory<_i129.ProjectDetailBloc>(() => _i129.ProjectDetailBloc(
        watchProjectDetail: gh<_i97.WatchProjectDetailUseCase>()));
    gh.factory<_i130.ProjectInvitationWatcherBloc>(
        () => _i130.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i78.InvitationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i131.RemovePlaylistCacheUseCase>(() =>
        _i131.RemovePlaylistCacheUseCase(gh<_i102.AudioStorageRepository>()));
    gh.factory<_i132.RemoveTrackCacheUseCase>(() =>
        _i132.RemoveTrackCacheUseCase(gh<_i102.AudioStorageRepository>()));
    gh.lazySingleton<_i133.SignOutUseCase>(
        () => _i133.SignOutUseCase(gh<_i107.AuthRepository>()));
    gh.lazySingleton<_i134.SignUpUseCase>(
        () => _i134.SignUpUseCase(gh<_i107.AuthRepository>()));
    gh.lazySingleton<_i135.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i135.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i104.AudioTrackIncrementalSyncService>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i136.SyncUserProfileCollaboratorsUseCase>(
        () => _i136.SyncUserProfileCollaboratorsUseCase(
              gh<_i47.ProjectsLocalDataSource>(),
              gh<_i94.UserProfileCacheRepository>(),
            ));
    gh.factory<_i137.WatchTrackCacheStatusUseCase>(() =>
        _i137.WatchTrackCacheStatusUseCase(gh<_i102.AudioStorageRepository>()));
    gh.factory<_i138.AudioSourceResolver>(() => _i139.AudioSourceResolverImpl(
          gh<_i102.AudioStorageRepository>(),
          gh<_i100.AudioDownloadRepository>(),
        ));
    gh.factory<_i140.AudioWaveformBloc>(() => _i140.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i119.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i141.OnboardingBloc>(() => _i141.OnboardingBloc(
          onboardingUseCase: gh<_i128.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i142.SyncDataManager>(() => _i142.SyncDataManager(
          syncProjects: gh<_i92.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i135.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i90.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i93.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i136.SyncUserProfileCollaboratorsUseCase>(),
          syncNotifications: gh<_i91.SyncNotificationsUseCase>(),
        ));
    gh.factory<_i143.SyncStatusProvider>(() => _i143.SyncStatusProvider(
          syncDataManager: gh<_i142.SyncDataManager>(),
          pendingOperationsManager: gh<_i85.PendingOperationsManager>(),
        ));
    gh.factory<_i144.TrackCacheBloc>(() => _i144.TrackCacheBloc(
          cacheTrackUseCase: gh<_i113.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i137.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i132.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i119.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i145.BackgroundSyncCoordinator>(
        () => _i145.BackgroundSyncCoordinator(
              gh<_i30.NetworkStateManager>(),
              gh<_i142.SyncDataManager>(),
              gh<_i85.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i146.PlaylistRepository>(
        () => _i147.PlaylistRepositoryImpl(
              localDataSource: gh<_i44.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i145.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i85.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i148.ProjectsRepository>(
        () => _i149.ProjectsRepositoryImpl(
              localDataSource: gh<_i47.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i145.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i85.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i150.RemoveCollaboratorUseCase>(
        () => _i150.RemoveCollaboratorUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i151.UpdateCollaboratorRoleUseCase>(
        () => _i151.UpdateCollaboratorRoleUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i152.UpdateProjectUseCase>(
        () => _i152.UpdateProjectUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i153.UserProfileRepository>(
        () => _i154.UserProfileRepositoryImpl(
              localDataSource: gh<_i61.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i62.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i145.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i85.PendingOperationsManager>(),
              firestore: gh<_i16.FirebaseFirestore>(),
              sessionStorage: gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i155.WatchAllProjectsUseCase>(
        () => _i155.WatchAllProjectsUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i156.WatchUserProfileUseCase>(
        () => _i156.WatchUserProfileUseCase(
              gh<_i153.UserProfileRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i157.AcceptInvitationUseCase>(
        () => _i157.AcceptInvitationUseCase(
              invitationRepository: gh<_i78.InvitationRepository>(),
              projectRepository: gh<_i148.ProjectsRepository>(),
              userProfileRepository: gh<_i153.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i158.AddCollaboratorToProjectUseCase>(
        () => _i158.AddCollaboratorToProjectUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.AudioCommentRepository>(
        () => _i160.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i65.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i64.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i145.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i85.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i161.AudioTrackRepository>(
        () => _i162.AudioTrackRepositoryImpl(
              gh<_i66.AudioTrackLocalDataSource>(),
              gh<_i145.BackgroundSyncCoordinator>(),
              gh<_i85.PendingOperationsManager>(),
            ));
    gh.factory<_i163.CachePlaylistUseCase>(() => _i163.CachePlaylistUseCase(
          gh<_i100.AudioDownloadRepository>(),
          gh<_i161.AudioTrackRepository>(),
        ));
    gh.factory<_i164.CheckProfileCompletenessUseCase>(() =>
        _i164.CheckProfileCompletenessUseCase(
            gh<_i153.UserProfileRepository>()));
    gh.lazySingleton<_i165.CreateProjectUseCase>(
        () => _i165.CreateProjectUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.DeclineInvitationUseCase>(
        () => _i166.DeclineInvitationUseCase(
              invitationRepository: gh<_i78.InvitationRepository>(),
              projectRepository: gh<_i148.ProjectsRepository>(),
              userProfileRepository: gh<_i153.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i167.DeleteProjectUseCase>(
        () => _i167.DeleteProjectUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i168.FindUserByEmailUseCase>(
        () => _i168.FindUserByEmailUseCase(gh<_i153.UserProfileRepository>()));
    gh.lazySingleton<_i169.GetProjectByIdUseCase>(
        () => _i169.GetProjectByIdUseCase(gh<_i148.ProjectsRepository>()));
    gh.lazySingleton<_i170.GoogleSignInUseCase>(() => _i170.GoogleSignInUseCase(
          gh<_i107.AuthRepository>(),
          gh<_i153.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i171.JoinProjectWithIdUseCase>(
        () => _i171.JoinProjectWithIdUseCase(
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.LeaveProjectUseCase>(() => _i172.LeaveProjectUseCase(
          gh<_i148.ProjectsRepository>(),
          gh<_i89.SessionStorage>(),
        ));
    gh.factory<_i173.MagicLinkBloc>(() => _i173.MagicLinkBloc(
          generateMagicLink: gh<_i117.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i63.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i70.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i48.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i74.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i171.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i107.AuthRepository>(),
        ));
    gh.factory<_i174.PlayAudioUseCase>(() => _i174.PlayAudioUseCase(
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          audioStorageRepository: gh<_i102.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i175.PlayPlaylistUseCase>(() => _i175.PlayPlaylistUseCase(
          playlistRepository: gh<_i146.PlaylistRepository>(),
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i102.AudioStorageRepository>(),
        ));
    gh.factory<_i176.PlaylistCacheBloc>(() => _i176.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i163.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i122.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i131.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i177.ProjectCommentService>(
        () => _i177.ProjectCommentService(gh<_i159.AudioCommentRepository>()));
    gh.lazySingleton<_i178.ProjectTrackService>(() => _i178.ProjectTrackService(
          gh<_i161.AudioTrackRepository>(),
          gh<_i102.AudioStorageRepository>(),
        ));
    gh.factory<_i179.ProjectsBloc>(() => _i179.ProjectsBloc(
          createProject: gh<_i165.CreateProjectUseCase>(),
          updateProject: gh<_i152.UpdateProjectUseCase>(),
          deleteProject: gh<_i167.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i155.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i180.RestorePlaybackStateUseCase>(
        () => _i180.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i42.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i161.AudioTrackRepository>(),
              audioStorageRepository: gh<_i102.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i181.SendInvitationUseCase>(
        () => _i181.SendInvitationUseCase(
              invitationRepository: gh<_i78.InvitationRepository>(),
              notificationService: gh<_i35.NotificationService>(),
              findUserByEmail: gh<_i168.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i27.MagicLinkRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i182.SessionCleanupService>(() => _i182.SessionCleanupService(
          userProfileRepository: gh<_i153.UserProfileRepository>(),
          projectsRepository: gh<_i148.ProjectsRepository>(),
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          audioCommentRepository: gh<_i159.AudioCommentRepository>(),
          invitationRepository: gh<_i78.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i42.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i6.BlocStateCleanupService>(),
          sessionStorage: gh<_i89.SessionStorage>(),
        ));
    gh.factory<_i183.SessionService>(() => _i183.SessionService(
          checkAuthUseCase: gh<_i115.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i128.OnboardingUseCase>(),
          profileUseCase: gh<_i164.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i184.SignInUseCase>(() => _i184.SignInUseCase(
          gh<_i107.AuthRepository>(),
          gh<_i153.UserProfileRepository>(),
        ));
    gh.factory<_i185.UpdateUserProfileUseCase>(
        () => _i185.UpdateUserProfileUseCase(
              gh<_i153.UserProfileRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i186.UploadAudioTrackUseCase>(
        () => _i186.UploadAudioTrackUseCase(
              gh<_i178.ProjectTrackService>(),
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.factory<_i187.UserProfileBloc>(() => _i187.UserProfileBloc(
          updateUserProfileUseCase: gh<_i185.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i156.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i164.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i188.WatchCommentsByTrackUseCase>(() =>
        _i188.WatchCommentsByTrackUseCase(gh<_i177.ProjectCommentService>()));
    gh.lazySingleton<_i189.WatchTracksByProjectIdUseCase>(() =>
        _i189.WatchTracksByProjectIdUseCase(gh<_i161.AudioTrackRepository>()));
    gh.lazySingleton<_i190.AddAudioCommentUseCase>(
        () => _i190.AddAudioCommentUseCase(
              gh<_i177.ProjectCommentService>(),
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i191.AddCollaboratorByEmailUseCase>(
        () => _i191.AddCollaboratorByEmailUseCase(
              gh<_i168.FindUserByEmailUseCase>(),
              gh<_i158.AddCollaboratorToProjectUseCase>(),
              gh<_i35.NotificationService>(),
            ));
    gh.factory<_i192.AppBootstrap>(() => _i192.AppBootstrap(
          sessionService: gh<_i183.SessionService>(),
          performanceCollector: gh<_i41.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i13.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i72.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i193.AppFlowBloc>(() => _i193.AppFlowBloc(
          appBootstrap: gh<_i192.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i145.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i118.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i182.SessionCleanupService>(),
        ));
    gh.lazySingleton<_i194.AudioContextService>(
        () => _i195.AudioContextServiceImpl(
              userProfileRepository: gh<_i153.UserProfileRepository>(),
              audioTrackRepository: gh<_i161.AudioTrackRepository>(),
              projectsRepository: gh<_i148.ProjectsRepository>(),
            ));
    gh.factory<_i196.AudioPlayerService>(() => _i196.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i21.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i174.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i175.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i38.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i49.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i57.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i55.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i56.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i51.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i60.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i59.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i53.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i52.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i50.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i180.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i197.AuthBloc>(() => _i197.AuthBloc(
          signIn: gh<_i184.SignInUseCase>(),
          signUp: gh<_i134.SignUpUseCase>(),
          googleSignIn: gh<_i170.GoogleSignInUseCase>(),
          signOut: gh<_i133.SignOutUseCase>(),
        ));
    gh.lazySingleton<_i198.DeleteAudioCommentUseCase>(
        () => _i198.DeleteAudioCommentUseCase(
              gh<_i177.ProjectCommentService>(),
              gh<_i148.ProjectsRepository>(),
              gh<_i89.SessionStorage>(),
            ));
    gh.lazySingleton<_i199.DeleteAudioTrack>(() => _i199.DeleteAudioTrack(
          gh<_i89.SessionStorage>(),
          gh<_i148.ProjectsRepository>(),
          gh<_i178.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i200.EditAudioTrackUseCase>(
        () => _i200.EditAudioTrackUseCase(
              gh<_i178.ProjectTrackService>(),
              gh<_i148.ProjectsRepository>(),
            ));
    gh.factory<_i201.LoadTrackContextUseCase>(
        () => _i201.LoadTrackContextUseCase(gh<_i194.AudioContextService>()));
    gh.factory<_i202.ManageCollaboratorsBloc>(
        () => _i202.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i150.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i151.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i172.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i98.WatchUserProfilesUseCase>(),
              findUserByEmailUseCase: gh<_i168.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i191.AddCollaboratorByEmailUseCase>(),
            ));
    gh.factory<_i203.ProjectInvitationActorBloc>(
        () => _i203.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i181.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i157.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i166.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i114.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i168.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i204.AudioCommentBloc>(() => _i204.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i188.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i190.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i198.DeleteAudioCommentUseCase>(),
          watchUserProfilesUseCase: gh<_i98.WatchUserProfilesUseCase>(),
        ));
    gh.factory<_i205.AudioContextBloc>(() => _i205.AudioContextBloc(
        loadTrackContextUseCase: gh<_i201.LoadTrackContextUseCase>()));
    gh.factory<_i206.AudioPlayerBloc>(() => _i206.AudioPlayerBloc(
        audioPlayerService: gh<_i196.AudioPlayerService>()));
    gh.factory<_i207.AudioTrackBloc>(() => _i207.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i189.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i199.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i186.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i200.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i208.AppModule {}
