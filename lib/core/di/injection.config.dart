// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i13;

import 'package:cloud_firestore/cloud_firestore.dart' as _i17;
import 'package:connectivity_plus/connectivity_plus.dart' as _i11;
import 'package:firebase_auth/firebase_auth.dart' as _i16;
import 'package:firebase_storage/firebase_storage.dart' as _i18;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i20;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i23;
import 'package:isar/isar.dart' as _i25;
import 'package:shared_preferences/shared_preferences.dart' as _i55;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i90;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i15;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i193;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i7;
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
    as _i194;
import 'package:trackflow/core/di/app_module.dart' as _i210;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i6;
import 'package:trackflow/core/network/network_state_manager.dart' as _i31;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i32;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i33;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i35;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i34;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i36;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i72;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i74;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i76;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i123;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i37;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i124;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i125;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i73;
import 'package:trackflow/core/services/deep_link_service.dart' as _i12;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i14;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i21;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i42;
import 'package:trackflow/core/session/current_user_service.dart' as _i116;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i40;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i41;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i99;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i38;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i87;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i89;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i97;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i144;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i5;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i86;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i59;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i142;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i91;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i134;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i92;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i93;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i135;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i94;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i163;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i130;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i176;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i69;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i101;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i9;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i109;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i8;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i10;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i19;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i131;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i136;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i143;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i65;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i66;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i160;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i159;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i177;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i191;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i188;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i206;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i139;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i195;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i202;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i196;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i207;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i197;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i137;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i22;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i174;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i175;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i180;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i44;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i138;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i208;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i67;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i68;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i162;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i104;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i161;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i178;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i200;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i201;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i186;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i190;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i209;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i106;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i108;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i77;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i107;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i170;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i184;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i132;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i133;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i198;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i78;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i24;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i80;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i79;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i157;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i114;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i166;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i121;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i83;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i84;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i181;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i205;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i129;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i26;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i27;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i29;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i28;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i71;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i117;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i75;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i49;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i64;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i173;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i192;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i158;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i168;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i171;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i172;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i149;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i150;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i155;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i203;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i30;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i85;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i128;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i126;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i140;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i45;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i46;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i146;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i145;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i189;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i204;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i48;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i47;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i148;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i88;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i147;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i167;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i169;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i151;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i154;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i179;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i62;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i96;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i153;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i152;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i95;
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
    gh.lazySingleton<_i6.AvatarCacheManager>(
        () => _i6.AvatarCacheManagerImpl());
    gh.singleton<_i7.BlocStateCleanupService>(
        () => _i7.BlocStateCleanupService());
    gh.lazySingleton<_i8.CacheMaintenanceService>(
        () => _i9.CacheMaintenanceServiceImpl());
    gh.factory<_i10.CleanupCacheUseCase>(
        () => _i10.CleanupCacheUseCase(gh<_i8.CacheMaintenanceService>()));
    gh.lazySingleton<_i5.ConflictResolutionServiceImpl<dynamic>>(
        () => _i5.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i11.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i12.DeepLinkService>(() => _i12.DeepLinkService());
    await gh.factoryAsync<_i13.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i14.DynamicLinkService>(() => _i14.DynamicLinkService());
    gh.factory<_i15.ExampleComplexBloc>(() => _i15.ExampleComplexBloc());
    gh.factory<_i15.ExampleConditionalBloc>(
        () => _i15.ExampleConditionalBloc());
    gh.factory<_i15.ExampleNavigationCubit>(
        () => _i15.ExampleNavigationCubit());
    gh.factory<_i15.ExampleSimpleBloc>(() => _i15.ExampleSimpleBloc());
    gh.factory<_i15.ExampleUserProfileBloc>(
        () => _i15.ExampleUserProfileBloc());
    gh.lazySingleton<_i16.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i17.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i18.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i19.GetCacheStorageStatsUseCase>(() =>
        _i19.GetCacheStorageStatsUseCase(gh<_i8.CacheMaintenanceService>()));
    gh.lazySingleton<_i20.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i21.ImageMaintenanceService>(
        () => _i21.ImageMaintenanceService());
    gh.factory<_i22.InitializeAudioPlayerUseCase>(() =>
        _i22.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i23.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i24.InvitationRemoteDataSource>(() =>
        _i24.FirestoreInvitationRemoteDataSource(gh<_i17.FirebaseFirestore>()));
    await gh.factoryAsync<_i25.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i26.MagicLinkLocalDataSource>(
        () => _i26.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i27.MagicLinkRemoteDataSource>(
        () => _i27.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i17.FirebaseFirestore>(),
              deepLinkService: gh<_i12.DeepLinkService>(),
            ));
    gh.factory<_i28.MagicLinkRepository>(() =>
        _i29.MagicLinkRepositoryImp(gh<_i27.MagicLinkRemoteDataSource>()));
    gh.factory<_i30.NavigationCubit>(() => _i30.NavigationCubit());
    gh.lazySingleton<_i31.NetworkStateManager>(() => _i31.NetworkStateManager(
          gh<_i23.InternetConnectionChecker>(),
          gh<_i11.Connectivity>(),
        ));
    gh.lazySingleton<_i32.NotificationLocalDataSource>(
        () => _i32.IsarNotificationLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i33.NotificationRemoteDataSource>(() =>
        _i33.FirestoreNotificationRemoteDataSource(
            gh<_i17.FirebaseFirestore>()));
    gh.lazySingleton<_i34.NotificationRepository>(
        () => _i35.NotificationRepositoryImpl(
              localDataSource: gh<_i32.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i33.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i31.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i36.NotificationService>(
        () => _i36.NotificationService(gh<_i34.NotificationRepository>()));
    gh.lazySingleton<_i37.ObserveNotificationsUseCase>(() =>
        _i37.ObserveNotificationsUseCase(gh<_i34.NotificationRepository>()));
    gh.factory<_i38.OperationExecutorFactory>(
        () => _i38.OperationExecutorFactory());
    gh.factory<_i39.PauseAudioUseCase>(() => _i39.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i40.PendingOperationsLocalDataSource>(
        () => _i40.IsarPendingOperationsLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i41.PendingOperationsRepository>(() =>
        _i41.PendingOperationsRepositoryImpl(
            gh<_i40.PendingOperationsLocalDataSource>()));
    gh.factory<_i42.PerformanceMetricsCollector>(
        () => _i42.PerformanceMetricsCollector());
    gh.lazySingleton<_i43.PlaybackPersistenceRepository>(
        () => _i44.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i45.PlaylistLocalDataSource>(
        () => _i45.PlaylistLocalDataSourceImpl(gh<_i25.Isar>()));
    gh.lazySingleton<_i46.PlaylistRemoteDataSource>(
        () => _i46.PlaylistRemoteDataSourceImpl(gh<_i17.FirebaseFirestore>()));
    gh.lazySingleton<_i5.ProjectConflictResolutionService>(
        () => _i5.ProjectConflictResolutionService());
    gh.lazySingleton<_i47.ProjectRemoteDataSource>(() =>
        _i47.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i17.FirebaseFirestore>()));
    gh.lazySingleton<_i48.ProjectsLocalDataSource>(
        () => _i48.ProjectsLocalDataSourceImpl(gh<_i25.Isar>()));
    gh.lazySingleton<_i49.ResendMagicLinkUseCase>(
        () => _i49.ResendMagicLinkUseCase(gh<_i28.MagicLinkRepository>()));
    gh.factory<_i50.ResumeAudioUseCase>(() => _i50.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i51.SavePlaybackStateUseCase>(
        () => _i51.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i43.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i52.SeekAudioUseCase>(() =>
        _i52.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i53.SetPlaybackSpeedUseCase>(() => _i53.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i54.SetVolumeUseCase>(() =>
        _i54.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i55.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i56.SkipToNextUseCase>(() => _i56.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i57.SkipToPreviousUseCase>(() => _i57.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i58.StopAudioUseCase>(() =>
        _i58.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i59.SyncMetadataManager>(
        () => _i59.SyncMetadataManager());
    gh.factory<_i60.ToggleRepeatModeUseCase>(() => _i60.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i61.ToggleShuffleUseCase>(() => _i61.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i62.UserProfileLocalDataSource>(
        () => _i62.IsarUserProfileLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i63.UserProfileRemoteDataSource>(
        () => _i63.UserProfileRemoteDataSourceImpl(
              gh<_i17.FirebaseFirestore>(),
              gh<_i18.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i64.ValidateMagicLinkUseCase>(
        () => _i64.ValidateMagicLinkUseCase(gh<_i28.MagicLinkRepository>()));
    gh.lazySingleton<_i65.AudioCommentLocalDataSource>(
        () => _i65.IsarAudioCommentLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i66.AudioCommentRemoteDataSource>(() =>
        _i66.FirebaseAudioCommentRemoteDataSource(
            gh<_i17.FirebaseFirestore>()));
    gh.lazySingleton<_i67.AudioTrackLocalDataSource>(
        () => _i67.IsarAudioTrackLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i68.AudioTrackRemoteDataSource>(
        () => _i68.AudioTrackRemoteDataSourceImpl(
              gh<_i17.FirebaseFirestore>(),
              gh<_i18.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i69.CacheStorageLocalDataSource>(
        () => _i69.CacheStorageLocalDataSourceImpl(gh<_i25.Isar>()));
    gh.lazySingleton<_i70.CacheStorageRemoteDataSource>(() =>
        _i70.CacheStorageRemoteDataSourceImpl(gh<_i18.FirebaseStorage>()));
    gh.lazySingleton<_i71.ConsumeMagicLinkUseCase>(
        () => _i71.ConsumeMagicLinkUseCase(gh<_i28.MagicLinkRepository>()));
    gh.factory<_i72.CreateNotificationUseCase>(() =>
        _i72.CreateNotificationUseCase(gh<_i34.NotificationRepository>()));
    gh.factory<_i73.DatabaseHealthMonitor>(
        () => _i73.DatabaseHealthMonitor(gh<_i25.Isar>()));
    gh.factory<_i74.DeleteNotificationUseCase>(() =>
        _i74.DeleteNotificationUseCase(gh<_i34.NotificationRepository>()));
    gh.lazySingleton<_i75.GetMagicLinkStatusUseCase>(
        () => _i75.GetMagicLinkStatusUseCase(gh<_i28.MagicLinkRepository>()));
    gh.lazySingleton<_i76.GetUnreadNotificationsCountUseCase>(() =>
        _i76.GetUnreadNotificationsCountUseCase(
            gh<_i34.NotificationRepository>()));
    gh.lazySingleton<_i77.GoogleAuthService>(() => _i77.GoogleAuthService(
          gh<_i20.GoogleSignIn>(),
          gh<_i16.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i78.InvitationLocalDataSource>(
        () => _i78.IsarInvitationLocalDataSource(gh<_i25.Isar>()));
    gh.lazySingleton<_i79.InvitationRepository>(
        () => _i80.InvitationRepositoryImpl(
              localDataSource: gh<_i78.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i24.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i31.NetworkStateManager>(),
            ));
    gh.factory<_i81.MarkAsUnreadUseCase>(
        () => _i81.MarkAsUnreadUseCase(gh<_i34.NotificationRepository>()));
    gh.lazySingleton<_i82.MarkNotificationAsReadUseCase>(() =>
        _i82.MarkNotificationAsReadUseCase(gh<_i34.NotificationRepository>()));
    gh.lazySingleton<_i83.ObservePendingInvitationsUseCase>(() =>
        _i83.ObservePendingInvitationsUseCase(gh<_i79.InvitationRepository>()));
    gh.lazySingleton<_i84.ObserveSentInvitationsUseCase>(() =>
        _i84.ObserveSentInvitationsUseCase(gh<_i79.InvitationRepository>()));
    gh.lazySingleton<_i85.OnboardingStateLocalDataSource>(() =>
        _i85.OnboardingStateLocalDataSourceImpl(gh<_i55.SharedPreferences>()));
    gh.lazySingleton<_i86.PendingOperationsManager>(
        () => _i86.PendingOperationsManager(
              gh<_i41.PendingOperationsRepository>(),
              gh<_i31.NetworkStateManager>(),
              gh<_i38.OperationExecutorFactory>(),
            ));
    gh.factory<_i87.PlaylistOperationExecutor>(() =>
        _i87.PlaylistOperationExecutor(gh<_i46.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i88.ProjectIncrementalSyncService>(
        () => _i88.ProjectIncrementalSyncService(
              gh<_i47.ProjectRemoteDataSource>(),
              gh<_i48.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i89.ProjectOperationExecutor>(() =>
        _i89.ProjectOperationExecutor(gh<_i47.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i90.SessionStorage>(
        () => _i90.SessionStorageImpl(prefs: gh<_i55.SharedPreferences>()));
    gh.lazySingleton<_i91.SyncAudioCommentsUseCase>(
        () => _i91.SyncAudioCommentsUseCase(
              gh<_i66.AudioCommentRemoteDataSource>(),
              gh<_i65.AudioCommentLocalDataSource>(),
              gh<_i47.ProjectRemoteDataSource>(),
              gh<_i90.SessionStorage>(),
              gh<_i68.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i92.SyncNotificationsUseCase>(
        () => _i92.SyncNotificationsUseCase(
              gh<_i34.NotificationRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i93.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i93.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i88.ProjectIncrementalSyncService>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i94.SyncUserProfileUseCase>(
        () => _i94.SyncUserProfileUseCase(
              gh<_i63.UserProfileRemoteDataSource>(),
              gh<_i62.UserProfileLocalDataSource>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i95.UserProfileCacheRepository>(
        () => _i96.UserProfileCacheRepositoryImpl(
              gh<_i63.UserProfileRemoteDataSource>(),
              gh<_i62.UserProfileLocalDataSource>(),
              gh<_i31.NetworkStateManager>(),
            ));
    gh.factory<_i97.UserProfileOperationExecutor>(() =>
        _i97.UserProfileOperationExecutor(
            gh<_i63.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i98.WatchUserProfilesUseCase>(() =>
        _i98.WatchUserProfilesUseCase(gh<_i95.UserProfileCacheRepository>()));
    gh.factory<_i99.AudioCommentOperationExecutor>(() =>
        _i99.AudioCommentOperationExecutor(
            gh<_i66.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i100.AudioDownloadRepository>(() =>
        _i101.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i70.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i102.AudioStorageRepository>(() =>
        _i103.AudioStorageRepositoryImpl(
            localDataSource: gh<_i69.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i104.AudioTrackIncrementalSyncService>(
        () => _i104.AudioTrackIncrementalSyncService(
              gh<_i68.AudioTrackRemoteDataSource>(),
              gh<_i67.AudioTrackLocalDataSource>(),
              gh<_i47.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i105.AudioTrackOperationExecutor>(() =>
        _i105.AudioTrackOperationExecutor(
            gh<_i68.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i106.AuthRemoteDataSource>(
        () => _i106.AuthRemoteDataSourceImpl(
              gh<_i16.FirebaseAuth>(),
              gh<_i77.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i107.AuthRepository>(() => _i108.AuthRepositoryImpl(
          remote: gh<_i106.AuthRemoteDataSource>(),
          sessionStorage: gh<_i90.SessionStorage>(),
          networkStateManager: gh<_i31.NetworkStateManager>(),
          googleAuthService: gh<_i77.GoogleAuthService>(),
        ));
    gh.lazySingleton<_i109.CacheKeyRepository>(() =>
        _i110.CacheKeyRepositoryImpl(
            localDataSource: gh<_i69.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i111.CacheMaintenanceRepository>(() =>
        _i112.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i69.CacheStorageLocalDataSource>()));
    gh.factory<_i113.CacheTrackUseCase>(() => _i113.CacheTrackUseCase(
          gh<_i100.AudioDownloadRepository>(),
          gh<_i102.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i114.CancelInvitationUseCase>(
        () => _i114.CancelInvitationUseCase(gh<_i79.InvitationRepository>()));
    gh.factory<_i115.CheckAuthenticationStatusUseCase>(() =>
        _i115.CheckAuthenticationStatusUseCase(gh<_i107.AuthRepository>()));
    gh.factory<_i116.CurrentUserService>(
        () => _i116.CurrentUserService(gh<_i90.SessionStorage>()));
    gh.lazySingleton<_i117.GenerateMagicLinkUseCase>(
        () => _i117.GenerateMagicLinkUseCase(
              gh<_i28.MagicLinkRepository>(),
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
            gh<_i79.InvitationRepository>()));
    gh.factory<_i122.GetPlaylistCacheStatusUseCase>(() =>
        _i122.GetPlaylistCacheStatusUseCase(
            gh<_i102.AudioStorageRepository>()));
    gh.factory<_i123.MarkAllNotificationsAsReadUseCase>(
        () => _i123.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i34.NotificationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i124.NotificationActorBloc>(() => _i124.NotificationActorBloc(
          createNotificationUseCase: gh<_i72.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i82.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i81.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i123.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i74.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i125.NotificationWatcherBloc>(
        () => _i125.NotificationWatcherBloc(
              notificationRepository: gh<_i34.NotificationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.lazySingleton<_i126.OnboardingRepository>(() =>
        _i127.OnboardingRepositoryImpl(
            gh<_i85.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i128.OnboardingUseCase>(
        () => _i128.OnboardingUseCase(gh<_i126.OnboardingRepository>()));
    gh.factory<_i129.ProjectInvitationWatcherBloc>(
        () => _i129.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i79.InvitationRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i130.RemovePlaylistCacheUseCase>(() =>
        _i130.RemovePlaylistCacheUseCase(gh<_i102.AudioStorageRepository>()));
    gh.factory<_i131.RemoveTrackCacheUseCase>(() =>
        _i131.RemoveTrackCacheUseCase(gh<_i102.AudioStorageRepository>()));
    gh.lazySingleton<_i132.SignOutUseCase>(
        () => _i132.SignOutUseCase(gh<_i107.AuthRepository>()));
    gh.lazySingleton<_i133.SignUpUseCase>(
        () => _i133.SignUpUseCase(gh<_i107.AuthRepository>()));
    gh.lazySingleton<_i134.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i134.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i104.AudioTrackIncrementalSyncService>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i135.SyncUserProfileCollaboratorsUseCase>(
        () => _i135.SyncUserProfileCollaboratorsUseCase(
              gh<_i48.ProjectsLocalDataSource>(),
              gh<_i95.UserProfileCacheRepository>(),
            ));
    gh.factory<_i136.WatchTrackCacheStatusUseCase>(() =>
        _i136.WatchTrackCacheStatusUseCase(gh<_i102.AudioStorageRepository>()));
    gh.factory<_i137.AudioSourceResolver>(() => _i138.AudioSourceResolverImpl(
          gh<_i102.AudioStorageRepository>(),
          gh<_i100.AudioDownloadRepository>(),
        ));
    gh.factory<_i139.AudioWaveformBloc>(() => _i139.AudioWaveformBloc(
          audioPlaybackService: gh<_i3.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i119.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i140.OnboardingBloc>(() => _i140.OnboardingBloc(
          onboardingUseCase: gh<_i128.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i141.SyncDataManager>(() => _i141.SyncDataManager(
          syncProjects: gh<_i93.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i134.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i91.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i94.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i135.SyncUserProfileCollaboratorsUseCase>(),
          syncNotifications: gh<_i92.SyncNotificationsUseCase>(),
        ));
    gh.factory<_i142.SyncStatusProvider>(() => _i142.SyncStatusProvider(
          syncDataManager: gh<_i141.SyncDataManager>(),
          pendingOperationsManager: gh<_i86.PendingOperationsManager>(),
        ));
    gh.factory<_i143.TrackCacheBloc>(() => _i143.TrackCacheBloc(
          cacheTrackUseCase: gh<_i113.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i136.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i131.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i119.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i144.BackgroundSyncCoordinator>(
        () => _i144.BackgroundSyncCoordinator(
              gh<_i31.NetworkStateManager>(),
              gh<_i141.SyncDataManager>(),
              gh<_i86.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i145.PlaylistRepository>(
        () => _i146.PlaylistRepositoryImpl(
              localDataSource: gh<_i45.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i144.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i86.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i147.ProjectsRepository>(
        () => _i148.ProjectsRepositoryImpl(
              localDataSource: gh<_i48.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i144.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i86.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i149.RemoveCollaboratorUseCase>(
        () => _i149.RemoveCollaboratorUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i150.UpdateCollaboratorRoleUseCase>(
        () => _i150.UpdateCollaboratorRoleUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i151.UpdateProjectUseCase>(
        () => _i151.UpdateProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i152.UserProfileRepository>(
        () => _i153.UserProfileRepositoryImpl(
              localDataSource: gh<_i62.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i63.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i31.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i144.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i86.PendingOperationsManager>(),
              firestore: gh<_i17.FirebaseFirestore>(),
              sessionStorage: gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i154.WatchAllProjectsUseCase>(
        () => _i154.WatchAllProjectsUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i155.WatchCollaboratorsBundleUseCase>(
        () => _i155.WatchCollaboratorsBundleUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i98.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i156.WatchUserProfileUseCase>(
        () => _i156.WatchUserProfileUseCase(
              gh<_i152.UserProfileRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i157.AcceptInvitationUseCase>(
        () => _i157.AcceptInvitationUseCase(
              invitationRepository: gh<_i79.InvitationRepository>(),
              projectRepository: gh<_i147.ProjectsRepository>(),
              userProfileRepository: gh<_i152.UserProfileRepository>(),
              notificationService: gh<_i36.NotificationService>(),
            ));
    gh.lazySingleton<_i158.AddCollaboratorToProjectUseCase>(
        () => _i158.AddCollaboratorToProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.AudioCommentRepository>(
        () => _i160.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i66.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i65.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i31.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i144.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i86.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i161.AudioTrackRepository>(
        () => _i162.AudioTrackRepositoryImpl(
              gh<_i67.AudioTrackLocalDataSource>(),
              gh<_i144.BackgroundSyncCoordinator>(),
              gh<_i86.PendingOperationsManager>(),
            ));
    gh.factory<_i163.CachePlaylistUseCase>(() => _i163.CachePlaylistUseCase(
          gh<_i100.AudioDownloadRepository>(),
          gh<_i161.AudioTrackRepository>(),
        ));
    gh.factory<_i164.CheckProfileCompletenessUseCase>(() =>
        _i164.CheckProfileCompletenessUseCase(
            gh<_i152.UserProfileRepository>()));
    gh.lazySingleton<_i165.CreateProjectUseCase>(
        () => _i165.CreateProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.DeclineInvitationUseCase>(
        () => _i166.DeclineInvitationUseCase(
              invitationRepository: gh<_i79.InvitationRepository>(),
              projectRepository: gh<_i147.ProjectsRepository>(),
              userProfileRepository: gh<_i152.UserProfileRepository>(),
              notificationService: gh<_i36.NotificationService>(),
            ));
    gh.lazySingleton<_i167.DeleteProjectUseCase>(
        () => _i167.DeleteProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i168.FindUserByEmailUseCase>(
        () => _i168.FindUserByEmailUseCase(gh<_i152.UserProfileRepository>()));
    gh.lazySingleton<_i169.GetProjectByIdUseCase>(
        () => _i169.GetProjectByIdUseCase(gh<_i147.ProjectsRepository>()));
    gh.lazySingleton<_i170.GoogleSignInUseCase>(() => _i170.GoogleSignInUseCase(
          gh<_i107.AuthRepository>(),
          gh<_i152.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i171.JoinProjectWithIdUseCase>(
        () => _i171.JoinProjectWithIdUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.LeaveProjectUseCase>(() => _i172.LeaveProjectUseCase(
          gh<_i147.ProjectsRepository>(),
          gh<_i90.SessionStorage>(),
        ));
    gh.factory<_i173.MagicLinkBloc>(() => _i173.MagicLinkBloc(
          generateMagicLink: gh<_i117.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i64.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i71.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i49.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i75.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i171.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i107.AuthRepository>(),
        ));
    gh.factory<_i174.PlayAudioUseCase>(() => _i174.PlayAudioUseCase(
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          audioStorageRepository: gh<_i102.AudioStorageRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i175.PlayPlaylistUseCase>(() => _i175.PlayPlaylistUseCase(
          playlistRepository: gh<_i145.PlaylistRepository>(),
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
          audioStorageRepository: gh<_i102.AudioStorageRepository>(),
        ));
    gh.factory<_i176.PlaylistCacheBloc>(() => _i176.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i163.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i122.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i130.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i177.ProjectCommentService>(
        () => _i177.ProjectCommentService(gh<_i159.AudioCommentRepository>()));
    gh.lazySingleton<_i178.ProjectTrackService>(() => _i178.ProjectTrackService(
          gh<_i161.AudioTrackRepository>(),
          gh<_i102.AudioStorageRepository>(),
        ));
    gh.factory<_i179.ProjectsBloc>(() => _i179.ProjectsBloc(
          createProject: gh<_i165.CreateProjectUseCase>(),
          updateProject: gh<_i151.UpdateProjectUseCase>(),
          deleteProject: gh<_i167.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i154.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i180.RestorePlaybackStateUseCase>(
        () => _i180.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i43.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i161.AudioTrackRepository>(),
              audioStorageRepository: gh<_i102.AudioStorageRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i181.SendInvitationUseCase>(
        () => _i181.SendInvitationUseCase(
              invitationRepository: gh<_i79.InvitationRepository>(),
              notificationService: gh<_i36.NotificationService>(),
              findUserByEmail: gh<_i168.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i28.MagicLinkRepository>(),
              currentUserService: gh<_i116.CurrentUserService>(),
            ));
    gh.factory<_i182.SessionCleanupService>(() => _i182.SessionCleanupService(
          userProfileRepository: gh<_i152.UserProfileRepository>(),
          projectsRepository: gh<_i147.ProjectsRepository>(),
          audioTrackRepository: gh<_i161.AudioTrackRepository>(),
          audioCommentRepository: gh<_i159.AudioCommentRepository>(),
          invitationRepository: gh<_i79.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i43.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i7.BlocStateCleanupService>(),
          sessionStorage: gh<_i90.SessionStorage>(),
        ));
    gh.factory<_i183.SessionService>(() => _i183.SessionService(
          checkAuthUseCase: gh<_i115.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i128.OnboardingUseCase>(),
          profileUseCase: gh<_i164.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i184.SignInUseCase>(() => _i184.SignInUseCase(
          gh<_i107.AuthRepository>(),
          gh<_i152.UserProfileRepository>(),
        ));
    gh.factory<_i185.UpdateUserProfileUseCase>(
        () => _i185.UpdateUserProfileUseCase(
              gh<_i152.UserProfileRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i186.UploadAudioTrackUseCase>(
        () => _i186.UploadAudioTrackUseCase(
              gh<_i178.ProjectTrackService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.factory<_i187.UserProfileBloc>(() => _i187.UserProfileBloc(
          updateUserProfileUseCase: gh<_i185.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i156.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i164.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i120.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i188.WatchAudioCommentsBundleUseCase>(
        () => _i188.WatchAudioCommentsBundleUseCase(
              gh<_i161.AudioTrackRepository>(),
              gh<_i159.AudioCommentRepository>(),
              gh<_i95.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i189.WatchProjectDetailUseCase>(
        () => _i189.WatchProjectDetailUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i161.AudioTrackRepository>(),
              gh<_i95.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i190.WatchTracksByProjectIdUseCase>(() =>
        _i190.WatchTracksByProjectIdUseCase(gh<_i161.AudioTrackRepository>()));
    gh.lazySingleton<_i191.AddAudioCommentUseCase>(
        () => _i191.AddAudioCommentUseCase(
              gh<_i177.ProjectCommentService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i192.AddCollaboratorByEmailUseCase>(
        () => _i192.AddCollaboratorByEmailUseCase(
              gh<_i168.FindUserByEmailUseCase>(),
              gh<_i158.AddCollaboratorToProjectUseCase>(),
              gh<_i36.NotificationService>(),
            ));
    gh.factory<_i193.AppBootstrap>(() => _i193.AppBootstrap(
          sessionService: gh<_i183.SessionService>(),
          performanceCollector: gh<_i42.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i14.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i73.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i194.AppFlowBloc>(() => _i194.AppFlowBloc(
          appBootstrap: gh<_i193.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i144.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i118.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i182.SessionCleanupService>(),
        ));
    gh.lazySingleton<_i195.AudioContextService>(
        () => _i196.AudioContextServiceImpl(
              userProfileRepository: gh<_i152.UserProfileRepository>(),
              audioTrackRepository: gh<_i161.AudioTrackRepository>(),
              projectsRepository: gh<_i147.ProjectsRepository>(),
            ));
    gh.factory<_i197.AudioPlayerService>(() => _i197.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i22.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i174.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i175.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i39.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i50.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i58.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i56.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i57.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i52.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i61.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i60.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i54.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i53.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i51.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i180.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i198.AuthBloc>(() => _i198.AuthBloc(
          signIn: gh<_i184.SignInUseCase>(),
          signUp: gh<_i133.SignUpUseCase>(),
          googleSignIn: gh<_i170.GoogleSignInUseCase>(),
          signOut: gh<_i132.SignOutUseCase>(),
        ));
    gh.lazySingleton<_i199.DeleteAudioCommentUseCase>(
        () => _i199.DeleteAudioCommentUseCase(
              gh<_i177.ProjectCommentService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i90.SessionStorage>(),
            ));
    gh.lazySingleton<_i200.DeleteAudioTrack>(() => _i200.DeleteAudioTrack(
          gh<_i90.SessionStorage>(),
          gh<_i147.ProjectsRepository>(),
          gh<_i178.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i201.EditAudioTrackUseCase>(
        () => _i201.EditAudioTrackUseCase(
              gh<_i178.ProjectTrackService>(),
              gh<_i147.ProjectsRepository>(),
            ));
    gh.factory<_i202.LoadTrackContextUseCase>(
        () => _i202.LoadTrackContextUseCase(gh<_i195.AudioContextService>()));
    gh.factory<_i203.ManageCollaboratorsBloc>(
        () => _i203.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i149.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i150.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i172.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i168.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i192.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i155.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i204.ProjectDetailBloc>(() => _i204.ProjectDetailBloc(
        watchProjectDetail: gh<_i189.WatchProjectDetailUseCase>()));
    gh.factory<_i205.ProjectInvitationActorBloc>(
        () => _i205.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i181.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i157.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i166.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i114.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i168.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i206.AudioCommentBloc>(() => _i206.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i191.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i199.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i188.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i207.AudioContextBloc>(() => _i207.AudioContextBloc(
        loadTrackContextUseCase: gh<_i202.LoadTrackContextUseCase>()));
    gh.factory<_i208.AudioPlayerBloc>(() => _i208.AudioPlayerBloc(
        audioPlayerService: gh<_i197.AudioPlayerService>()));
    gh.factory<_i209.AudioTrackBloc>(() => _i209.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i190.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i200.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i186.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i201.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i210.AppModule {}
