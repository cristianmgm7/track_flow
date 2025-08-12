// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i14;

import 'package:cloud_firestore/cloud_firestore.dart' as _i18;
import 'package:connectivity_plus/connectivity_plus.dart' as _i12;
import 'package:firebase_auth/firebase_auth.dart' as _i17;
import 'package:firebase_storage/firebase_storage.dart' as _i19;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i21;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i24;
import 'package:isar/isar.dart' as _i26;
import 'package:shared_preferences/shared_preferences.dart' as _i56;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i91;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i16;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i203;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i191;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i192;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i117;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i122;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i124;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i204;
import 'package:trackflow/core/di/app_module.dart' as _i221;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i7;
import 'package:trackflow/core/network/network_state_manager.dart' as _i32;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i33;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i34;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i36;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i35;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i37;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i73;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i75;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i77;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i127;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i83;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i38;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i128;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i129;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i74;
import 'package:trackflow/core/services/deep_link_service.dart' as _i13;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i15;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i22;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i43;
import 'package:trackflow/core/session/current_user_service.dart' as _i118;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i41;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i42;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i101;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i107;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i39;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i88;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i90;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i98;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i150;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i6;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i87;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i147;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i60;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i148;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i92;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i138;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i93;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i94;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i139;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i95;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i156;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i194;
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_multiple_cached_audios_usecase.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/management/domain/usecases/get_cached_track_bundles_usecase.dart'
    as _i177;
import 'package:trackflow/features/audio_cache/management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i141;
import 'package:trackflow/features/audio_cache/management/presentation/bloc/cache_management_bloc.dart'
    as _i209;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i170;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i126;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i134;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i185;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i71;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i103;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i105;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i114;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i10;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i104;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i9;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i11;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i20;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i115;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i123;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i142;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i149;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i66;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i67;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i167;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i166;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i186;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i201;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i210;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i198;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i217;
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart'
    as _i145;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i205;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i213;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i206;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i218;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i4;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i207;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i143;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i23;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i183;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i184;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i189;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i45;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i5;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i144;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i219;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i68;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i69;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i169;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i106;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i168;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i187;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i211;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i212;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i196;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i200;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i99;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i220;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i140;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i108;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i110;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i78;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i109;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i179;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i193;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i136;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i137;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i208;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i79;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i25;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i81;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i80;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i164;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i116;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i174;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i125;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i84;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i85;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i190;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i216;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i133;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i27;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i28;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i30;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i29;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i72;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i121;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i76;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i50;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i65;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i182;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i202;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i165;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i176;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i180;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i181;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i155;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i157;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i162;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i214;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i31;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i86;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i131;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i132;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i130;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i146;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i47;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i152;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i151;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i199;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i215;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i48;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i154;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i153;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i172;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i175;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i178;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i158;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i161;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i188;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i63;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i97;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i160;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i159;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i96;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i171;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i173;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i195;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i163;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i100;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i197;

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
    gh.lazySingleton<_i3.AudioBackgroundInitializer>(
        () => const _i3.AudioBackgroundInitializer());
    gh.lazySingleton<_i4.AudioPlaybackService>(
        () => _i5.AudioPlaybackServiceImpl());
    gh.lazySingleton<_i6.AudioTrackConflictResolutionService>(
        () => _i6.AudioTrackConflictResolutionService());
    gh.lazySingleton<_i7.AvatarCacheManager>(
        () => _i7.AvatarCacheManagerImpl());
    gh.singleton<_i8.BlocStateCleanupService>(
        () => _i8.BlocStateCleanupService());
    gh.lazySingleton<_i9.CacheMaintenanceService>(
        () => _i10.CacheMaintenanceServiceImpl());
    gh.factory<_i11.CleanupCacheUseCase>(
        () => _i11.CleanupCacheUseCase(gh<_i9.CacheMaintenanceService>()));
    gh.lazySingleton<_i6.ConflictResolutionServiceImpl<dynamic>>(
        () => _i6.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i12.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i13.DeepLinkService>(() => _i13.DeepLinkService());
    await gh.factoryAsync<_i14.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i15.DynamicLinkService>(() => _i15.DynamicLinkService());
    gh.factory<_i16.ExampleComplexBloc>(() => _i16.ExampleComplexBloc());
    gh.factory<_i16.ExampleConditionalBloc>(
        () => _i16.ExampleConditionalBloc());
    gh.factory<_i16.ExampleNavigationCubit>(
        () => _i16.ExampleNavigationCubit());
    gh.factory<_i16.ExampleSimpleBloc>(() => _i16.ExampleSimpleBloc());
    gh.factory<_i16.ExampleUserProfileBloc>(
        () => _i16.ExampleUserProfileBloc());
    gh.lazySingleton<_i17.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i18.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i19.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i20.GetCacheStorageStatsUseCase>(() =>
        _i20.GetCacheStorageStatsUseCase(gh<_i9.CacheMaintenanceService>()));
    gh.lazySingleton<_i21.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i22.ImageMaintenanceService>(
        () => _i22.ImageMaintenanceService());
    gh.factory<_i23.InitializeAudioPlayerUseCase>(() =>
        _i23.InitializeAudioPlayerUseCase(
            playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i24.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i25.InvitationRemoteDataSource>(() =>
        _i25.FirestoreInvitationRemoteDataSource(gh<_i18.FirebaseFirestore>()));
    await gh.factoryAsync<_i26.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i27.MagicLinkLocalDataSource>(
        () => _i27.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i28.MagicLinkRemoteDataSource>(
        () => _i28.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i18.FirebaseFirestore>(),
              deepLinkService: gh<_i13.DeepLinkService>(),
            ));
    gh.factory<_i29.MagicLinkRepository>(() =>
        _i30.MagicLinkRepositoryImp(gh<_i28.MagicLinkRemoteDataSource>()));
    gh.factory<_i31.NavigationCubit>(() => _i31.NavigationCubit());
    gh.lazySingleton<_i32.NetworkStateManager>(() => _i32.NetworkStateManager(
          gh<_i24.InternetConnectionChecker>(),
          gh<_i12.Connectivity>(),
        ));
    gh.lazySingleton<_i33.NotificationLocalDataSource>(
        () => _i33.IsarNotificationLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i34.NotificationRemoteDataSource>(() =>
        _i34.FirestoreNotificationRemoteDataSource(
            gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i35.NotificationRepository>(
        () => _i36.NotificationRepositoryImpl(
              localDataSource: gh<_i33.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i34.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i37.NotificationService>(
        () => _i37.NotificationService(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i38.ObserveNotificationsUseCase>(() =>
        _i38.ObserveNotificationsUseCase(gh<_i35.NotificationRepository>()));
    gh.factory<_i39.OperationExecutorFactory>(
        () => _i39.OperationExecutorFactory());
    gh.factory<_i40.PauseAudioUseCase>(() => _i40.PauseAudioUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i41.PendingOperationsLocalDataSource>(
        () => _i41.IsarPendingOperationsLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i42.PendingOperationsRepository>(() =>
        _i42.PendingOperationsRepositoryImpl(
            gh<_i41.PendingOperationsLocalDataSource>()));
    gh.factory<_i43.PerformanceMetricsCollector>(
        () => _i43.PerformanceMetricsCollector());
    gh.lazySingleton<_i44.PlaybackPersistenceRepository>(
        () => _i45.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i46.PlaylistLocalDataSource>(
        () => _i46.PlaylistLocalDataSourceImpl(gh<_i26.Isar>()));
    gh.lazySingleton<_i47.PlaylistRemoteDataSource>(
        () => _i47.PlaylistRemoteDataSourceImpl(gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i6.ProjectConflictResolutionService>(
        () => _i6.ProjectConflictResolutionService());
    gh.lazySingleton<_i48.ProjectRemoteDataSource>(() =>
        _i48.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i49.ProjectsLocalDataSource>(
        () => _i49.ProjectsLocalDataSourceImpl(gh<_i26.Isar>()));
    gh.lazySingleton<_i50.ResendMagicLinkUseCase>(
        () => _i50.ResendMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.factory<_i51.ResumeAudioUseCase>(() => _i51.ResumeAudioUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i52.SavePlaybackStateUseCase>(
        () => _i52.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              playbackService: gh<_i4.AudioPlaybackService>(),
            ));
    gh.factory<_i53.SeekAudioUseCase>(() =>
        _i53.SeekAudioUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i54.SetPlaybackSpeedUseCase>(() => _i54.SetPlaybackSpeedUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i55.SetVolumeUseCase>(() =>
        _i55.SetVolumeUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    await gh.factoryAsync<_i56.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i57.SkipToNextUseCase>(() => _i57.SkipToNextUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i58.SkipToPreviousUseCase>(() => _i58.SkipToPreviousUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i59.StopAudioUseCase>(() =>
        _i59.StopAudioUseCase(playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i60.SyncMetadataManager>(
        () => _i60.SyncMetadataManager());
    gh.factory<_i61.ToggleRepeatModeUseCase>(() => _i61.ToggleRepeatModeUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.factory<_i62.ToggleShuffleUseCase>(() => _i62.ToggleShuffleUseCase(
        playbackService: gh<_i4.AudioPlaybackService>()));
    gh.lazySingleton<_i63.UserProfileLocalDataSource>(
        () => _i63.IsarUserProfileLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i64.UserProfileRemoteDataSource>(
        () => _i64.UserProfileRemoteDataSourceImpl(
              gh<_i18.FirebaseFirestore>(),
              gh<_i19.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i65.ValidateMagicLinkUseCase>(
        () => _i65.ValidateMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.lazySingleton<_i66.AudioCommentLocalDataSource>(
        () => _i66.IsarAudioCommentLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i67.AudioCommentRemoteDataSource>(() =>
        _i67.FirebaseAudioCommentRemoteDataSource(
            gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i68.AudioTrackLocalDataSource>(
        () => _i68.IsarAudioTrackLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i69.AudioTrackRemoteDataSource>(
        () => _i69.AudioTrackRemoteDataSourceImpl(
              gh<_i18.FirebaseFirestore>(),
              gh<_i19.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i70.CacheStorageLocalDataSource>(
        () => _i70.CacheStorageLocalDataSourceImpl(gh<_i26.Isar>()));
    gh.lazySingleton<_i71.CacheStorageRemoteDataSource>(() =>
        _i71.CacheStorageRemoteDataSourceImpl(gh<_i19.FirebaseStorage>()));
    gh.lazySingleton<_i72.ConsumeMagicLinkUseCase>(
        () => _i72.ConsumeMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.factory<_i73.CreateNotificationUseCase>(() =>
        _i73.CreateNotificationUseCase(gh<_i35.NotificationRepository>()));
    gh.factory<_i74.DatabaseHealthMonitor>(
        () => _i74.DatabaseHealthMonitor(gh<_i26.Isar>()));
    gh.factory<_i75.DeleteNotificationUseCase>(() =>
        _i75.DeleteNotificationUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i76.GetMagicLinkStatusUseCase>(
        () => _i76.GetMagicLinkStatusUseCase(gh<_i29.MagicLinkRepository>()));
    gh.lazySingleton<_i77.GetUnreadNotificationsCountUseCase>(() =>
        _i77.GetUnreadNotificationsCountUseCase(
            gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i78.GoogleAuthService>(() => _i78.GoogleAuthService(
          gh<_i21.GoogleSignIn>(),
          gh<_i17.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i79.InvitationLocalDataSource>(
        () => _i79.IsarInvitationLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i80.InvitationRepository>(
        () => _i81.InvitationRepositoryImpl(
              localDataSource: gh<_i79.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i25.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
            ));
    gh.factory<_i82.MarkAsUnreadUseCase>(
        () => _i82.MarkAsUnreadUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i83.MarkNotificationAsReadUseCase>(() =>
        _i83.MarkNotificationAsReadUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i84.ObservePendingInvitationsUseCase>(() =>
        _i84.ObservePendingInvitationsUseCase(gh<_i80.InvitationRepository>()));
    gh.lazySingleton<_i85.ObserveSentInvitationsUseCase>(() =>
        _i85.ObserveSentInvitationsUseCase(gh<_i80.InvitationRepository>()));
    gh.lazySingleton<_i86.OnboardingStateLocalDataSource>(() =>
        _i86.OnboardingStateLocalDataSourceImpl(gh<_i56.SharedPreferences>()));
    gh.lazySingleton<_i87.PendingOperationsManager>(
        () => _i87.PendingOperationsManager(
              gh<_i42.PendingOperationsRepository>(),
              gh<_i32.NetworkStateManager>(),
              gh<_i39.OperationExecutorFactory>(),
            ));
    gh.factory<_i88.PlaylistOperationExecutor>(() =>
        _i88.PlaylistOperationExecutor(gh<_i47.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i89.ProjectIncrementalSyncService>(
        () => _i89.ProjectIncrementalSyncService(
              gh<_i48.ProjectRemoteDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i90.ProjectOperationExecutor>(() =>
        _i90.ProjectOperationExecutor(gh<_i48.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i91.SessionStorage>(
        () => _i91.SessionStorageImpl(prefs: gh<_i56.SharedPreferences>()));
    gh.lazySingleton<_i92.SyncAudioCommentsUseCase>(
        () => _i92.SyncAudioCommentsUseCase(
              gh<_i67.AudioCommentRemoteDataSource>(),
              gh<_i66.AudioCommentLocalDataSource>(),
              gh<_i48.ProjectRemoteDataSource>(),
              gh<_i91.SessionStorage>(),
              gh<_i69.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i93.SyncNotificationsUseCase>(
        () => _i93.SyncNotificationsUseCase(
              gh<_i35.NotificationRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i94.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i94.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i89.ProjectIncrementalSyncService>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i95.SyncUserProfileUseCase>(
        () => _i95.SyncUserProfileUseCase(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i96.UserProfileCacheRepository>(
        () => _i97.UserProfileCacheRepositoryImpl(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i32.NetworkStateManager>(),
            ));
    gh.factory<_i98.UserProfileOperationExecutor>(() =>
        _i98.UserProfileOperationExecutor(
            gh<_i64.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i99.WatchTrackUploadStatusUseCase>(() =>
        _i99.WatchTrackUploadStatusUseCase(
            gh<_i87.PendingOperationsManager>()));
    gh.lazySingleton<_i100.WatchUserProfilesUseCase>(() =>
        _i100.WatchUserProfilesUseCase(gh<_i96.UserProfileCacheRepository>()));
    gh.factory<_i101.AudioCommentOperationExecutor>(() =>
        _i101.AudioCommentOperationExecutor(
            gh<_i67.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i102.AudioDownloadRepository>(() =>
        _i103.AudioDownloadRepositoryImpl(
            remoteDataSource: gh<_i71.CacheStorageRemoteDataSource>()));
    gh.lazySingleton<_i104.AudioStorageRepository>(() =>
        _i105.AudioStorageRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i106.AudioTrackIncrementalSyncService>(
        () => _i106.AudioTrackIncrementalSyncService(
              gh<_i69.AudioTrackRemoteDataSource>(),
              gh<_i68.AudioTrackLocalDataSource>(),
              gh<_i48.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i107.AudioTrackOperationExecutor>(() =>
        _i107.AudioTrackOperationExecutor(
            gh<_i69.AudioTrackRemoteDataSource>()));
    gh.lazySingleton<_i108.AuthRemoteDataSource>(
        () => _i108.AuthRemoteDataSourceImpl(
              gh<_i17.FirebaseAuth>(),
              gh<_i78.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i109.AuthRepository>(() => _i110.AuthRepositoryImpl(
          remote: gh<_i108.AuthRemoteDataSource>(),
          sessionStorage: gh<_i91.SessionStorage>(),
          networkStateManager: gh<_i32.NetworkStateManager>(),
          googleAuthService: gh<_i78.GoogleAuthService>(),
        ));
    gh.lazySingleton<_i111.CacheKeyRepository>(() =>
        _i112.CacheKeyRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i113.CacheMaintenanceRepository>(() =>
        _i114.CacheMaintenanceRepositoryImpl(
            localDataSource: gh<_i70.CacheStorageLocalDataSource>()));
    gh.factory<_i115.CacheTrackUseCase>(() => _i115.CacheTrackUseCase(
          gh<_i102.AudioDownloadRepository>(),
          gh<_i104.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i116.CancelInvitationUseCase>(
        () => _i116.CancelInvitationUseCase(gh<_i80.InvitationRepository>()));
    gh.factory<_i117.CheckAuthenticationStatusUseCase>(() =>
        _i117.CheckAuthenticationStatusUseCase(gh<_i109.AuthRepository>()));
    gh.factory<_i118.CurrentUserService>(
        () => _i118.CurrentUserService(gh<_i91.SessionStorage>()));
    gh.factory<_i119.DeleteCachedAudioUseCase>(() =>
        _i119.DeleteCachedAudioUseCase(gh<_i104.AudioStorageRepository>()));
    gh.factory<_i120.DeleteMultipleCachedAudiosUseCase>(() =>
        _i120.DeleteMultipleCachedAudiosUseCase(
            gh<_i104.AudioStorageRepository>()));
    gh.lazySingleton<_i121.GenerateMagicLinkUseCase>(
        () => _i121.GenerateMagicLinkUseCase(
              gh<_i29.MagicLinkRepository>(),
              gh<_i109.AuthRepository>(),
            ));
    gh.lazySingleton<_i122.GetAuthStateUseCase>(
        () => _i122.GetAuthStateUseCase(gh<_i109.AuthRepository>()));
    gh.factory<_i123.GetCachedTrackPathUseCase>(() =>
        _i123.GetCachedTrackPathUseCase(gh<_i104.AudioStorageRepository>()));
    gh.factory<_i124.GetCurrentUserUseCase>(
        () => _i124.GetCurrentUserUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i125.GetPendingInvitationsCountUseCase>(() =>
        _i125.GetPendingInvitationsCountUseCase(
            gh<_i80.InvitationRepository>()));
    gh.factory<_i126.GetPlaylistCacheStatusUseCase>(() =>
        _i126.GetPlaylistCacheStatusUseCase(
            gh<_i104.AudioStorageRepository>()));
    gh.factory<_i127.MarkAllNotificationsAsReadUseCase>(
        () => _i127.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i35.NotificationRepository>(),
              currentUserService: gh<_i118.CurrentUserService>(),
            ));
    gh.factory<_i128.NotificationActorBloc>(() => _i128.NotificationActorBloc(
          createNotificationUseCase: gh<_i73.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i83.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i82.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i127.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i75.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i129.NotificationWatcherBloc>(
        () => _i129.NotificationWatcherBloc(
              notificationRepository: gh<_i35.NotificationRepository>(),
              currentUserService: gh<_i118.CurrentUserService>(),
            ));
    gh.lazySingleton<_i130.OnboardingRepository>(() =>
        _i131.OnboardingRepositoryImpl(
            gh<_i86.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i132.OnboardingUseCase>(
        () => _i132.OnboardingUseCase(gh<_i130.OnboardingRepository>()));
    gh.factory<_i133.ProjectInvitationWatcherBloc>(
        () => _i133.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i80.InvitationRepository>(),
              currentUserService: gh<_i118.CurrentUserService>(),
            ));
    gh.factory<_i134.RemovePlaylistCacheUseCase>(() =>
        _i134.RemovePlaylistCacheUseCase(gh<_i104.AudioStorageRepository>()));
    gh.factory<_i135.RemoveTrackCacheUseCase>(() =>
        _i135.RemoveTrackCacheUseCase(gh<_i104.AudioStorageRepository>()));
    gh.lazySingleton<_i136.SignOutUseCase>(
        () => _i136.SignOutUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i137.SignUpUseCase>(
        () => _i137.SignUpUseCase(gh<_i109.AuthRepository>()));
    gh.lazySingleton<_i138.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i138.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i106.AudioTrackIncrementalSyncService>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i139.SyncUserProfileCollaboratorsUseCase>(
        () => _i139.SyncUserProfileCollaboratorsUseCase(
              gh<_i49.ProjectsLocalDataSource>(),
              gh<_i96.UserProfileCacheRepository>(),
            ));
    gh.factory<_i140.TrackUploadStatusCubit>(() =>
        _i140.TrackUploadStatusCubit(gh<_i99.WatchTrackUploadStatusUseCase>()));
    gh.factory<_i141.WatchStorageUsageUseCase>(() =>
        _i141.WatchStorageUsageUseCase(gh<_i104.AudioStorageRepository>()));
    gh.factory<_i142.WatchTrackCacheStatusUseCase>(() =>
        _i142.WatchTrackCacheStatusUseCase(gh<_i104.AudioStorageRepository>()));
    gh.factory<_i143.AudioSourceResolver>(() => _i144.AudioSourceResolverImpl(
          gh<_i104.AudioStorageRepository>(),
          gh<_i102.AudioDownloadRepository>(),
        ));
    gh.factory<_i145.AudioWaveformBloc>(() => _i145.AudioWaveformBloc(
          audioPlaybackService: gh<_i4.AudioPlaybackService>(),
          getCachedTrackPathUseCase: gh<_i123.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i146.OnboardingBloc>(() => _i146.OnboardingBloc(
          onboardingUseCase: gh<_i132.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i124.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i147.SyncDataManager>(() => _i147.SyncDataManager(
          syncProjects: gh<_i94.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i138.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i92.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i95.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i139.SyncUserProfileCollaboratorsUseCase>(),
          syncNotifications: gh<_i93.SyncNotificationsUseCase>(),
        ));
    gh.factory<_i148.SyncStatusProvider>(() => _i148.SyncStatusProvider(
          syncDataManager: gh<_i147.SyncDataManager>(),
          pendingOperationsManager: gh<_i87.PendingOperationsManager>(),
        ));
    gh.factory<_i149.TrackCacheBloc>(() => _i149.TrackCacheBloc(
          cacheTrackUseCase: gh<_i115.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i142.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i135.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i123.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i150.BackgroundSyncCoordinator>(
        () => _i150.BackgroundSyncCoordinator(
              gh<_i32.NetworkStateManager>(),
              gh<_i147.SyncDataManager>(),
              gh<_i87.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i151.PlaylistRepository>(
        () => _i152.PlaylistRepositoryImpl(
              localDataSource: gh<_i46.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i150.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i87.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i153.ProjectsRepository>(
        () => _i154.ProjectsRepositoryImpl(
              localDataSource: gh<_i49.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i150.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i87.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i155.RemoveCollaboratorUseCase>(
        () => _i155.RemoveCollaboratorUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i156.TriggerUpstreamSyncUseCase>(() =>
        _i156.TriggerUpstreamSyncUseCase(
            gh<_i150.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i157.UpdateCollaboratorRoleUseCase>(
        () => _i157.UpdateCollaboratorRoleUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i158.UpdateProjectUseCase>(
        () => _i158.UpdateProjectUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.UserProfileRepository>(
        () => _i160.UserProfileRepositoryImpl(
              localDataSource: gh<_i63.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i64.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i150.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i87.PendingOperationsManager>(),
              firestore: gh<_i18.FirebaseFirestore>(),
              sessionStorage: gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i161.WatchAllProjectsUseCase>(
        () => _i161.WatchAllProjectsUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i162.WatchCollaboratorsBundleUseCase>(
        () => _i162.WatchCollaboratorsBundleUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i100.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i163.WatchUserProfileUseCase>(
        () => _i163.WatchUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i164.AcceptInvitationUseCase>(
        () => _i164.AcceptInvitationUseCase(
              invitationRepository: gh<_i80.InvitationRepository>(),
              projectRepository: gh<_i153.ProjectsRepository>(),
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              notificationService: gh<_i37.NotificationService>(),
            ));
    gh.lazySingleton<_i165.AddCollaboratorToProjectUseCase>(
        () => _i165.AddCollaboratorToProjectUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.AudioCommentRepository>(
        () => _i167.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i67.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i66.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i150.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i87.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i168.AudioTrackRepository>(
        () => _i169.AudioTrackRepositoryImpl(
              gh<_i68.AudioTrackLocalDataSource>(),
              gh<_i150.BackgroundSyncCoordinator>(),
              gh<_i87.PendingOperationsManager>(),
            ));
    gh.factory<_i170.CachePlaylistUseCase>(() => _i170.CachePlaylistUseCase(
          gh<_i102.AudioDownloadRepository>(),
          gh<_i168.AudioTrackRepository>(),
        ));
    gh.factory<_i171.CheckProfileCompletenessUseCase>(() =>
        _i171.CheckProfileCompletenessUseCase(
            gh<_i159.UserProfileRepository>()));
    gh.lazySingleton<_i172.CreateProjectUseCase>(
        () => _i172.CreateProjectUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.factory<_i173.CreateUserProfileUseCase>(
        () => _i173.CreateUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i174.DeclineInvitationUseCase>(
        () => _i174.DeclineInvitationUseCase(
              invitationRepository: gh<_i80.InvitationRepository>(),
              projectRepository: gh<_i153.ProjectsRepository>(),
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              notificationService: gh<_i37.NotificationService>(),
            ));
    gh.lazySingleton<_i175.DeleteProjectUseCase>(
        () => _i175.DeleteProjectUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i176.FindUserByEmailUseCase>(
        () => _i176.FindUserByEmailUseCase(gh<_i159.UserProfileRepository>()));
    gh.factory<_i177.GetCachedTrackBundlesUseCase>(
        () => _i177.GetCachedTrackBundlesUseCase(
              gh<_i9.CacheMaintenanceService>(),
              gh<_i168.AudioTrackRepository>(),
              gh<_i159.UserProfileRepository>(),
              gh<_i153.ProjectsRepository>(),
              gh<_i102.AudioDownloadRepository>(),
            ));
    gh.lazySingleton<_i178.GetProjectByIdUseCase>(
        () => _i178.GetProjectByIdUseCase(gh<_i153.ProjectsRepository>()));
    gh.lazySingleton<_i179.GoogleSignInUseCase>(() => _i179.GoogleSignInUseCase(
          gh<_i109.AuthRepository>(),
          gh<_i159.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i180.JoinProjectWithIdUseCase>(
        () => _i180.JoinProjectWithIdUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i181.LeaveProjectUseCase>(() => _i181.LeaveProjectUseCase(
          gh<_i153.ProjectsRepository>(),
          gh<_i91.SessionStorage>(),
        ));
    gh.factory<_i182.MagicLinkBloc>(() => _i182.MagicLinkBloc(
          generateMagicLink: gh<_i121.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i65.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i72.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i50.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i76.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i180.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i109.AuthRepository>(),
        ));
    gh.factory<_i183.PlayAudioUseCase>(() => _i183.PlayAudioUseCase(
          audioTrackRepository: gh<_i168.AudioTrackRepository>(),
          audioStorageRepository: gh<_i104.AudioStorageRepository>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
        ));
    gh.factory<_i184.PlayPlaylistUseCase>(() => _i184.PlayPlaylistUseCase(
          playlistRepository: gh<_i151.PlaylistRepository>(),
          audioTrackRepository: gh<_i168.AudioTrackRepository>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
          audioStorageRepository: gh<_i104.AudioStorageRepository>(),
        ));
    gh.factory<_i185.PlaylistCacheBloc>(() => _i185.PlaylistCacheBloc(
          cachePlaylistUseCase: gh<_i170.CachePlaylistUseCase>(),
          getPlaylistCacheStatusUseCase:
              gh<_i126.GetPlaylistCacheStatusUseCase>(),
          removePlaylistCacheUseCase: gh<_i134.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i186.ProjectCommentService>(
        () => _i186.ProjectCommentService(gh<_i166.AudioCommentRepository>()));
    gh.lazySingleton<_i187.ProjectTrackService>(() => _i187.ProjectTrackService(
          gh<_i168.AudioTrackRepository>(),
          gh<_i104.AudioStorageRepository>(),
        ));
    gh.factory<_i188.ProjectsBloc>(() => _i188.ProjectsBloc(
          createProject: gh<_i172.CreateProjectUseCase>(),
          updateProject: gh<_i158.UpdateProjectUseCase>(),
          deleteProject: gh<_i175.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i161.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i189.RestorePlaybackStateUseCase>(
        () => _i189.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i168.AudioTrackRepository>(),
              audioStorageRepository: gh<_i104.AudioStorageRepository>(),
              playbackService: gh<_i4.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i190.SendInvitationUseCase>(
        () => _i190.SendInvitationUseCase(
              invitationRepository: gh<_i80.InvitationRepository>(),
              notificationService: gh<_i37.NotificationService>(),
              findUserByEmail: gh<_i176.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i29.MagicLinkRepository>(),
              currentUserService: gh<_i118.CurrentUserService>(),
            ));
    gh.factory<_i191.SessionCleanupService>(() => _i191.SessionCleanupService(
          userProfileRepository: gh<_i159.UserProfileRepository>(),
          projectsRepository: gh<_i153.ProjectsRepository>(),
          audioTrackRepository: gh<_i168.AudioTrackRepository>(),
          audioCommentRepository: gh<_i166.AudioCommentRepository>(),
          invitationRepository: gh<_i80.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i44.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i91.SessionStorage>(),
        ));
    gh.factory<_i192.SessionService>(() => _i192.SessionService(
          checkAuthUseCase: gh<_i117.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i124.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i132.OnboardingUseCase>(),
          profileUseCase: gh<_i171.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i193.SignInUseCase>(() => _i193.SignInUseCase(
          gh<_i109.AuthRepository>(),
          gh<_i159.UserProfileRepository>(),
        ));
    gh.factory<_i194.SyncStatusCubit>(() => _i194.SyncStatusCubit(
          gh<_i148.SyncStatusProvider>(),
          gh<_i87.PendingOperationsManager>(),
          gh<_i156.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i195.UpdateUserProfileUseCase>(
        () => _i195.UpdateUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i196.UploadAudioTrackUseCase>(
        () => _i196.UploadAudioTrackUseCase(
              gh<_i187.ProjectTrackService>(),
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.factory<_i197.UserProfileBloc>(() => _i197.UserProfileBloc(
          updateUserProfileUseCase: gh<_i195.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i173.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i163.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i171.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i124.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i198.WatchAudioCommentsBundleUseCase>(
        () => _i198.WatchAudioCommentsBundleUseCase(
              gh<_i168.AudioTrackRepository>(),
              gh<_i166.AudioCommentRepository>(),
              gh<_i96.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i199.WatchProjectDetailUseCase>(
        () => _i199.WatchProjectDetailUseCase(
              gh<_i153.ProjectsRepository>(),
              gh<_i168.AudioTrackRepository>(),
              gh<_i96.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i200.WatchTracksByProjectIdUseCase>(() =>
        _i200.WatchTracksByProjectIdUseCase(gh<_i168.AudioTrackRepository>()));
    gh.lazySingleton<_i201.AddAudioCommentUseCase>(
        () => _i201.AddAudioCommentUseCase(
              gh<_i186.ProjectCommentService>(),
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i202.AddCollaboratorByEmailUseCase>(
        () => _i202.AddCollaboratorByEmailUseCase(
              gh<_i176.FindUserByEmailUseCase>(),
              gh<_i165.AddCollaboratorToProjectUseCase>(),
              gh<_i37.NotificationService>(),
            ));
    gh.factory<_i203.AppBootstrap>(() => _i203.AppBootstrap(
          sessionService: gh<_i192.SessionService>(),
          performanceCollector: gh<_i43.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i15.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i74.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i204.AppFlowBloc>(() => _i204.AppFlowBloc(
          appBootstrap: gh<_i203.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i150.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i122.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i191.SessionCleanupService>(),
        ));
    gh.lazySingleton<_i205.AudioContextService>(
        () => _i206.AudioContextServiceImpl(
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              audioTrackRepository: gh<_i168.AudioTrackRepository>(),
              projectsRepository: gh<_i153.ProjectsRepository>(),
            ));
    gh.factory<_i207.AudioPlayerService>(() => _i207.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i23.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i183.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i184.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i40.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i51.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i59.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i57.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i58.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i53.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i62.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i61.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i55.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i54.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i52.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i189.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i4.AudioPlaybackService>(),
        ));
    gh.factory<_i208.AuthBloc>(() => _i208.AuthBloc(
          signIn: gh<_i193.SignInUseCase>(),
          signUp: gh<_i137.SignUpUseCase>(),
          googleSignIn: gh<_i179.GoogleSignInUseCase>(),
          signOut: gh<_i136.SignOutUseCase>(),
        ));
    gh.factory<_i209.CacheManagementBloc>(() => _i209.CacheManagementBloc(
          getBundles: gh<_i177.GetCachedTrackBundlesUseCase>(),
          deleteOne: gh<_i119.DeleteCachedAudioUseCase>(),
          deleteMany: gh<_i120.DeleteMultipleCachedAudiosUseCase>(),
          watchUsage: gh<_i141.WatchStorageUsageUseCase>(),
          getStats: gh<_i20.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i11.CleanupCacheUseCase>(),
        ));
    gh.lazySingleton<_i210.DeleteAudioCommentUseCase>(
        () => _i210.DeleteAudioCommentUseCase(
              gh<_i186.ProjectCommentService>(),
              gh<_i153.ProjectsRepository>(),
              gh<_i91.SessionStorage>(),
            ));
    gh.lazySingleton<_i211.DeleteAudioTrack>(() => _i211.DeleteAudioTrack(
          gh<_i91.SessionStorage>(),
          gh<_i153.ProjectsRepository>(),
          gh<_i187.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i212.EditAudioTrackUseCase>(
        () => _i212.EditAudioTrackUseCase(
              gh<_i187.ProjectTrackService>(),
              gh<_i153.ProjectsRepository>(),
            ));
    gh.factory<_i213.LoadTrackContextUseCase>(
        () => _i213.LoadTrackContextUseCase(gh<_i205.AudioContextService>()));
    gh.factory<_i214.ManageCollaboratorsBloc>(
        () => _i214.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i155.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i157.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i181.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i176.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i202.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i162.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i215.ProjectDetailBloc>(() => _i215.ProjectDetailBloc(
        watchProjectDetail: gh<_i199.WatchProjectDetailUseCase>()));
    gh.factory<_i216.ProjectInvitationActorBloc>(
        () => _i216.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i190.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i164.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i174.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i116.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i176.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i217.AudioCommentBloc>(() => _i217.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i201.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i210.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i198.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i218.AudioContextBloc>(() => _i218.AudioContextBloc(
        loadTrackContextUseCase: gh<_i213.LoadTrackContextUseCase>()));
    gh.factory<_i219.AudioPlayerBloc>(() => _i219.AudioPlayerBloc(
        audioPlayerService: gh<_i207.AudioPlayerService>()));
    gh.factory<_i220.AudioTrackBloc>(() => _i220.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i200.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i211.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i196.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i212.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i221.AppModule {}
