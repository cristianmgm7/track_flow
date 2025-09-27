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
import 'package:google_sign_in/google_sign_in.dart' as _i18;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i21;
import 'package:isar/isar.dart' as _i23;
import 'package:shared_preferences/shared_preferences.dart' as _i54;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i100;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i14;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i220;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i9;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i203;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i204;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i123;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i127;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i129;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i221;
import 'package:trackflow/core/di/app_module.dart' as _i240;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i8;
import 'package:trackflow/core/network/network_state_manager.dart' as _i29;
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
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i84;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i86;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i131;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i91;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i92;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i36;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i132;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i133;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i83;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i13;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i19;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i41;
import 'package:trackflow/core/session/current_user_service.dart' as _i124;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i97;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i99;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i102;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i108;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i149;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i96;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i101;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i163;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i207;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i79;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart'
    as _i80;
import 'package:trackflow/features/audio_cache/data/repositories/audio_download_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i114;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i138;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i145;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i143;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i160;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i76;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i177;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i109;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i176;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i198;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i217;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i226;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i210;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i237;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i194;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i222;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i223;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i147;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i20;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i196;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i197;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i201;
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
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i43;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i148;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i238;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i77;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i78;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i179;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i115;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i178;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i199;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i227;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i229;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i236;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i215;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i106;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i239;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i142;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i117;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i74;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i118;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i146;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i191;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i206;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i139;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i140;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i224;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i120;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i151;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i150;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i152;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i125;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i153;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i211;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i144;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i225;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i88;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i22;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i90;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i89;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i174;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i122;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i183;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i130;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i93;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i94;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i202;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i233;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i137;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i24;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i26;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i81;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i126;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i85;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i48;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i195;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i218;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i175;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i185;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i192;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i193;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i159;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i164;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i230;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i28;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i30;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i95;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i135;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i136;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i134;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i154;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i156;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i155;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i213;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i231;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i212;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i232;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i47;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i98;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i157;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i181;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i228;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i188;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i168;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i234;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i62;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i162;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i61;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i161;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i219;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i184;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i187;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i189;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i200;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i205;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i214;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i170;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i235;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i60;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i66;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i67;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i104;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i167;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i65;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i166;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i103;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i180;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i182;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i208;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i171;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i107;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i209;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i72;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i73;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i173;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i70;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i71;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i172;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i69;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i186;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i190;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i216;

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
    gh.lazySingleton<_i4.AudioMetadataService>(
        () => const _i4.AudioMetadataService());
    gh.lazySingleton<_i5.AudioPlaybackService>(
        () => _i6.AudioPlaybackServiceImpl());
    gh.lazySingleton<_i7.AudioTrackConflictResolutionService>(
        () => _i7.AudioTrackConflictResolutionService());
    gh.lazySingleton<_i8.AvatarCacheManager>(
        () => _i8.AvatarCacheManagerImpl());
    gh.singleton<_i9.BlocStateCleanupService>(
        () => _i9.BlocStateCleanupService());
    gh.lazySingleton<_i7.ConflictResolutionServiceImpl<dynamic>>(
        () => _i7.ConflictResolutionServiceImpl<dynamic>());
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
    gh.lazySingleton<_i18.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i19.ImageMaintenanceService>(
        () => _i19.ImageMaintenanceService());
    gh.factory<_i20.InitializeAudioPlayerUseCase>(() =>
        _i20.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i21.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i22.InvitationRemoteDataSource>(() =>
        _i22.FirestoreInvitationRemoteDataSource(gh<_i16.FirebaseFirestore>()));
    await gh.factoryAsync<_i23.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i24.MagicLinkLocalDataSource>(
        () => _i24.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i25.MagicLinkRemoteDataSource>(
        () => _i25.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i16.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i26.MagicLinkRepository>(() =>
        _i27.MagicLinkRepositoryImp(gh<_i25.MagicLinkRemoteDataSource>()));
    gh.factory<_i28.NavigationCubit>(() => _i28.NavigationCubit());
    gh.lazySingleton<_i29.NetworkStateManager>(() => _i29.NetworkStateManager(
          gh<_i21.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.lazySingleton<_i30.NotificationIncrementalSyncService>(
        () => _i30.NotificationIncrementalSyncService());
    gh.lazySingleton<_i31.NotificationLocalDataSource>(
        () => _i31.IsarNotificationLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i32.NotificationRemoteDataSource>(() =>
        _i32.FirestoreNotificationRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i33.NotificationRepository>(
        () => _i34.NotificationRepositoryImpl(
              localDataSource: gh<_i31.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i32.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i35.NotificationService>(
        () => _i35.NotificationService(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i36.ObserveNotificationsUseCase>(() =>
        _i36.ObserveNotificationsUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i37.OperationExecutorFactory>(
        () => _i37.OperationExecutorFactory());
    gh.factory<_i38.PauseAudioUseCase>(() => _i38.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i39.PendingOperationsLocalDataSource>(
        () => _i39.IsarPendingOperationsLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i40.PendingOperationsRepository>(() =>
        _i40.PendingOperationsRepositoryImpl(
            gh<_i39.PendingOperationsLocalDataSource>()));
    gh.factory<_i41.PerformanceMetricsCollector>(
        () => _i41.PerformanceMetricsCollector());
    gh.lazySingleton<_i42.PlaybackPersistenceRepository>(
        () => _i43.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i44.PlaylistLocalDataSource>(
        () => _i44.PlaylistLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i45.PlaylistRemoteDataSource>(
        () => _i45.PlaylistRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i46.ProjectRemoteDataSource>(() =>
        _i46.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i47.ProjectsLocalDataSource>(
        () => _i47.ProjectsLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i48.ResendMagicLinkUseCase>(
        () => _i48.ResendMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i49.ResumeAudioUseCase>(() => _i49.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i50.SavePlaybackStateUseCase>(
        () => _i50.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i42.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i51.SeekAudioUseCase>(() =>
        _i51.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i52.SetPlaybackSpeedUseCase>(() => _i52.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i53.SetVolumeUseCase>(() =>
        _i53.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i54.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i55.SkipToNextUseCase>(() => _i55.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i56.SkipToPreviousUseCase>(() => _i56.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i57.StopAudioUseCase>(() =>
        _i57.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i58.ToggleRepeatModeUseCase>(() => _i58.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.ToggleShuffleUseCase>(() => _i59.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.TrackDetailCubit>(() => _i60.TrackDetailCubit());
    gh.lazySingleton<_i61.TrackVersionIncrementalSyncService>(
        () => _i61.TrackVersionIncrementalSyncService());
    gh.lazySingleton<_i62.TrackVersionLocalDataSource>(
        () => _i62.IsarTrackVersionLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i63.TrackVersionRemoteDataSource>(
        () => _i63.TrackVersionRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i64.UserProfileCollaboratorIncrementalSyncService>(
        () => _i64.UserProfileCollaboratorIncrementalSyncService());
    gh.lazySingleton<_i65.UserProfileIncrementalSyncService>(
        () => _i65.UserProfileIncrementalSyncService());
    gh.lazySingleton<_i66.UserProfileLocalDataSource>(
        () => _i66.IsarUserProfileLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i67.UserProfileRemoteDataSource>(
        () => _i67.UserProfileRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i68.ValidateMagicLinkUseCase>(
        () => _i68.ValidateMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i69.WaveformGeneratorService>(() =>
        _i70.JustWaveformGeneratorService(cacheDir: gh<_i12.Directory>()));
    gh.lazySingleton<_i71.WaveformIncrementalSyncService>(
        () => _i71.WaveformIncrementalSyncService());
    gh.factory<_i72.WaveformLocalDataSource>(
        () => _i72.WaveformLocalDataSourceImpl(isar: gh<_i23.Isar>()));
    gh.lazySingleton<_i73.WaveformRemoteDataSource>(() =>
        _i73.FirebaseStorageWaveformRemoteDataSource(
            gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i74.AppleAuthService>(
        () => _i74.AppleAuthService(gh<_i15.FirebaseAuth>()));
    gh.lazySingleton<_i75.AudioCommentLocalDataSource>(
        () => _i75.IsarAudioCommentLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i76.AudioCommentRemoteDataSource>(() =>
        _i76.FirebaseAudioCommentRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i77.AudioTrackLocalDataSource>(
        () => _i77.IsarAudioTrackLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i78.AudioTrackRemoteDataSource>(() =>
        _i78.AudioTrackRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i79.CacheStorageLocalDataSource>(
        () => _i79.CacheStorageLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i80.CacheStorageRemoteDataSource>(() =>
        _i80.CacheStorageRemoteDataSourceImpl(gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i81.ConsumeMagicLinkUseCase>(
        () => _i81.ConsumeMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i82.CreateNotificationUseCase>(() =>
        _i82.CreateNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i83.DatabaseHealthMonitor>(
        () => _i83.DatabaseHealthMonitor(gh<_i23.Isar>()));
    gh.factory<_i84.DeleteNotificationUseCase>(() =>
        _i84.DeleteNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i85.GetMagicLinkStatusUseCase>(
        () => _i85.GetMagicLinkStatusUseCase(gh<_i26.MagicLinkRepository>()));
    gh.lazySingleton<_i86.GetUnreadNotificationsCountUseCase>(() =>
        _i86.GetUnreadNotificationsCountUseCase(
            gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i87.GoogleAuthService>(() => _i87.GoogleAuthService(
          gh<_i18.GoogleSignIn>(),
          gh<_i15.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i88.InvitationLocalDataSource>(
        () => _i88.IsarInvitationLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i89.InvitationRepository>(
        () => _i90.InvitationRepositoryImpl(
              localDataSource: gh<_i88.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i22.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
            ));
    gh.factory<_i91.MarkAsUnreadUseCase>(
        () => _i91.MarkAsUnreadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i92.MarkNotificationAsReadUseCase>(() =>
        _i92.MarkNotificationAsReadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i93.ObservePendingInvitationsUseCase>(() =>
        _i93.ObservePendingInvitationsUseCase(gh<_i89.InvitationRepository>()));
    gh.lazySingleton<_i94.ObserveSentInvitationsUseCase>(() =>
        _i94.ObserveSentInvitationsUseCase(gh<_i89.InvitationRepository>()));
    gh.lazySingleton<_i95.OnboardingStateLocalDataSource>(() =>
        _i95.OnboardingStateLocalDataSourceImpl(gh<_i54.SharedPreferences>()));
    gh.lazySingleton<_i96.PendingOperationsManager>(
        () => _i96.PendingOperationsManager(
              gh<_i40.PendingOperationsRepository>(),
              gh<_i29.NetworkStateManager>(),
              gh<_i37.OperationExecutorFactory>(),
            ));
    gh.factory<_i97.PlaylistOperationExecutor>(() =>
        _i97.PlaylistOperationExecutor(gh<_i45.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i98.ProjectIncrementalSyncService>(
        () => _i98.ProjectIncrementalSyncService(
              gh<_i46.ProjectRemoteDataSource>(),
              gh<_i47.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i99.ProjectOperationExecutor>(() =>
        _i99.ProjectOperationExecutor(gh<_i46.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i100.SessionStorage>(
        () => _i100.SessionStorageImpl(prefs: gh<_i54.SharedPreferences>()));
    gh.factory<_i101.SyncStatusProvider>(() => _i101.SyncStatusProvider(
          syncDataManager: gh<InvalidType>(),
          pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
        ));
    gh.factory<_i102.TrackVersionOperationExecutor>(
        () => _i102.TrackVersionOperationExecutor(
              gh<_i63.TrackVersionRemoteDataSource>(),
              gh<_i62.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i103.UserProfileCacheRepository>(
        () => _i104.UserProfileCacheRepositoryImpl(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
              gh<_i29.NetworkStateManager>(),
            ));
    gh.factory<_i105.UserProfileOperationExecutor>(() =>
        _i105.UserProfileOperationExecutor(
            gh<_i67.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i106.WatchTrackUploadStatusUseCase>(() =>
        _i106.WatchTrackUploadStatusUseCase(
            gh<_i96.PendingOperationsManager>()));
    gh.lazySingleton<_i107.WatchUserProfilesUseCase>(() =>
        _i107.WatchUserProfilesUseCase(gh<_i103.UserProfileCacheRepository>()));
    gh.factory<_i108.WaveformOperationExecutor>(() =>
        _i108.WaveformOperationExecutor(gh<_i73.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i109.AudioCommentIncrementalSyncService>(
        () => _i109.AudioCommentIncrementalSyncService(
              gh<_i76.AudioCommentRemoteDataSource>(),
              gh<_i75.AudioCommentLocalDataSource>(),
            ));
    gh.factory<_i110.AudioCommentOperationExecutor>(() =>
        _i110.AudioCommentOperationExecutor(
            gh<_i76.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i111.AudioDownloadRepository>(
        () => _i112.AudioDownloadRepositoryImpl(
              remoteDataSource: gh<_i80.CacheStorageRemoteDataSource>(),
              localDataSource: gh<_i79.CacheStorageLocalDataSource>(),
            ));
    gh.lazySingleton<_i113.AudioStorageRepository>(() =>
        _i114.AudioStorageRepositoryImpl(
            localDataSource: gh<_i79.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i115.AudioTrackIncrementalSyncService>(
        () => _i115.AudioTrackIncrementalSyncService(
              gh<_i78.AudioTrackRemoteDataSource>(),
              gh<_i77.AudioTrackLocalDataSource>(),
            ));
    gh.factory<_i116.AudioTrackOperationExecutor>(
        () => _i116.AudioTrackOperationExecutor(
              gh<_i78.AudioTrackRemoteDataSource>(),
              gh<_i77.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i117.AuthRemoteDataSource>(
        () => _i117.AuthRemoteDataSourceImpl(
              gh<_i15.FirebaseAuth>(),
              gh<_i87.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i118.AuthRepository>(() => _i119.AuthRepositoryImpl(
          remote: gh<_i117.AuthRemoteDataSource>(),
          sessionStorage: gh<_i100.SessionStorage>(),
          networkStateManager: gh<_i29.NetworkStateManager>(),
          googleAuthService: gh<_i87.GoogleAuthService>(),
          appleAuthService: gh<_i74.AppleAuthService>(),
        ));
    gh.lazySingleton<_i120.CacheManagementLocalDataSource>(() =>
        _i120.CacheManagementLocalDataSourceImpl(
            local: gh<_i79.CacheStorageLocalDataSource>()));
    gh.factory<_i121.CacheTrackUseCase>(() => _i121.CacheTrackUseCase(
          gh<_i111.AudioDownloadRepository>(),
          gh<_i113.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i122.CancelInvitationUseCase>(
        () => _i122.CancelInvitationUseCase(gh<_i89.InvitationRepository>()));
    gh.factory<_i123.CheckAuthenticationStatusUseCase>(() =>
        _i123.CheckAuthenticationStatusUseCase(gh<_i118.AuthRepository>()));
    gh.factory<_i124.CurrentUserService>(
        () => _i124.CurrentUserService(gh<_i100.SessionStorage>()));
    gh.factory<_i125.DeleteCachedAudioUseCase>(() =>
        _i125.DeleteCachedAudioUseCase(gh<_i113.AudioStorageRepository>()));
    gh.lazySingleton<_i126.GenerateMagicLinkUseCase>(
        () => _i126.GenerateMagicLinkUseCase(
              gh<_i26.MagicLinkRepository>(),
              gh<_i118.AuthRepository>(),
            ));
    gh.lazySingleton<_i127.GetAuthStateUseCase>(
        () => _i127.GetAuthStateUseCase(gh<_i118.AuthRepository>()));
    gh.factory<_i128.GetCachedTrackPathUseCase>(() =>
        _i128.GetCachedTrackPathUseCase(gh<_i113.AudioStorageRepository>()));
    gh.factory<_i129.GetCurrentUserUseCase>(
        () => _i129.GetCurrentUserUseCase(gh<_i118.AuthRepository>()));
    gh.lazySingleton<_i130.GetPendingInvitationsCountUseCase>(() =>
        _i130.GetPendingInvitationsCountUseCase(
            gh<_i89.InvitationRepository>()));
    gh.factory<_i131.MarkAllNotificationsAsReadUseCase>(
        () => _i131.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i132.NotificationActorBloc>(() => _i132.NotificationActorBloc(
          createNotificationUseCase: gh<_i82.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i92.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i91.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i131.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i84.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i133.NotificationWatcherBloc>(
        () => _i133.NotificationWatcherBloc(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.lazySingleton<_i134.OnboardingRepository>(() =>
        _i135.OnboardingRepositoryImpl(
            gh<_i95.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i136.OnboardingUseCase>(
        () => _i136.OnboardingUseCase(gh<_i134.OnboardingRepository>()));
    gh.factory<_i137.ProjectInvitationWatcherBloc>(
        () => _i137.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i89.InvitationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i138.RemoveTrackCacheUseCase>(() =>
        _i138.RemoveTrackCacheUseCase(gh<_i113.AudioStorageRepository>()));
    gh.lazySingleton<_i139.SignOutUseCase>(
        () => _i139.SignOutUseCase(gh<_i118.AuthRepository>()));
    gh.lazySingleton<_i140.SignUpUseCase>(
        () => _i140.SignUpUseCase(gh<_i118.AuthRepository>()));
    gh.lazySingleton<_i141.SyncCoordinator>(() => _i141.SyncCoordinator(
          gh<_i54.SharedPreferences>(),
          gh<_i98.ProjectIncrementalSyncService>(),
          gh<_i115.AudioTrackIncrementalSyncService>(),
          gh<_i109.AudioCommentIncrementalSyncService>(),
          gh<_i65.UserProfileIncrementalSyncService>(),
          gh<_i64.UserProfileCollaboratorIncrementalSyncService>(),
          gh<_i30.NotificationIncrementalSyncService>(),
          gh<_i61.TrackVersionIncrementalSyncService>(),
          gh<_i71.WaveformIncrementalSyncService>(),
        ));
    gh.factory<_i142.TrackUploadStatusCubit>(() => _i142.TrackUploadStatusCubit(
        gh<_i106.WatchTrackUploadStatusUseCase>()));
    gh.factory<_i143.WatchCachedAudiosUseCase>(() =>
        _i143.WatchCachedAudiosUseCase(gh<_i113.AudioStorageRepository>()));
    gh.factory<_i144.WatchStorageUsageUseCase>(() =>
        _i144.WatchStorageUsageUseCase(gh<_i113.AudioStorageRepository>()));
    gh.factory<_i145.WatchTrackCacheStatusUseCase>(() =>
        _i145.WatchTrackCacheStatusUseCase(gh<_i113.AudioStorageRepository>()));
    gh.lazySingleton<_i146.AppleSignInUseCase>(
        () => _i146.AppleSignInUseCase(gh<_i118.AuthRepository>()));
    gh.factory<_i147.AudioSourceResolver>(() => _i148.AudioSourceResolverImpl(
          gh<_i113.AudioStorageRepository>(),
          gh<_i111.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i149.BackgroundSyncCoordinator>(
        () => _i149.BackgroundSyncCoordinator(
              gh<_i29.NetworkStateManager>(),
              gh<_i141.SyncCoordinator>(),
              gh<_i96.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i150.CacheMaintenanceService>(() =>
        _i151.CacheMaintenanceServiceImpl(
            gh<_i120.CacheManagementLocalDataSource>()));
    gh.factory<_i152.CleanupCacheUseCase>(
        () => _i152.CleanupCacheUseCase(gh<_i150.CacheMaintenanceService>()));
    gh.factory<_i153.GetCacheStorageStatsUseCase>(() =>
        _i153.GetCacheStorageStatsUseCase(gh<_i150.CacheMaintenanceService>()));
    gh.factory<_i154.OnboardingBloc>(() => _i154.OnboardingBloc(
          onboardingUseCase: gh<_i136.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i155.PlaylistRepository>(
        () => _i156.PlaylistRepositoryImpl(
              localDataSource: gh<_i44.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i157.ProjectsRepository>(
        () => _i158.ProjectsRepositoryImpl(
              localDataSource: gh<_i47.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i159.RemoveCollaboratorUseCase>(
        () => _i159.RemoveCollaboratorUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.factory<_i160.TrackCacheBloc>(() => _i160.TrackCacheBloc(
          cacheTrackUseCase: gh<_i121.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i145.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i138.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i128.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i161.TrackVersionRepository>(
        () => _i162.TrackVersionRepositoryImpl(
              gh<_i62.TrackVersionLocalDataSource>(),
              gh<_i149.BackgroundSyncCoordinator>(),
              gh<_i96.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i163.TriggerUpstreamSyncUseCase>(() =>
        _i163.TriggerUpstreamSyncUseCase(
            gh<_i149.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i164.UpdateCollaboratorRoleUseCase>(
        () => _i164.UpdateCollaboratorRoleUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i165.UpdateProjectUseCase>(
        () => _i165.UpdateProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.UserProfileRepository>(
        () => _i167.UserProfileRepositoryImpl(
              localDataSource: gh<_i66.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i67.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
              firestore: gh<_i16.FirebaseFirestore>(),
              sessionStorage: gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i168.WatchAllProjectsUseCase>(
        () => _i168.WatchAllProjectsUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i169.WatchCollaboratorsBundleUseCase>(
        () => _i169.WatchCollaboratorsBundleUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i107.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i170.WatchTrackVersionsUseCase>(() =>
        _i170.WatchTrackVersionsUseCase(gh<_i161.TrackVersionRepository>()));
    gh.lazySingleton<_i171.WatchUserProfileUseCase>(
        () => _i171.WatchUserProfileUseCase(
              gh<_i166.UserProfileRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.factory<_i172.WaveformRepository>(() => _i173.WaveformRepositoryImpl(
          localDataSource: gh<_i72.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i73.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i174.AcceptInvitationUseCase>(
        () => _i174.AcceptInvitationUseCase(
              invitationRepository: gh<_i89.InvitationRepository>(),
              projectRepository: gh<_i157.ProjectsRepository>(),
              userProfileRepository: gh<_i166.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i175.AddCollaboratorToProjectUseCase>(
        () => _i175.AddCollaboratorToProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i176.AudioCommentRepository>(
        () => _i177.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i76.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i75.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i96.PendingOperationsManager>(),
              trackVersionRepository: gh<_i161.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i178.AudioTrackRepository>(
        () => _i179.AudioTrackRepositoryImpl(
              gh<_i77.AudioTrackLocalDataSource>(),
              gh<_i149.BackgroundSyncCoordinator>(),
              gh<_i96.PendingOperationsManager>(),
            ));
    gh.factory<_i180.CheckProfileCompletenessUseCase>(() =>
        _i180.CheckProfileCompletenessUseCase(
            gh<_i166.UserProfileRepository>()));
    gh.lazySingleton<_i181.CreateProjectUseCase>(
        () => _i181.CreateProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.factory<_i182.CreateUserProfileUseCase>(
        () => _i182.CreateUserProfileUseCase(
              gh<_i166.UserProfileRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i183.DeclineInvitationUseCase>(
        () => _i183.DeclineInvitationUseCase(
              invitationRepository: gh<_i89.InvitationRepository>(),
              projectRepository: gh<_i157.ProjectsRepository>(),
              userProfileRepository: gh<_i166.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i184.DeleteTrackVersionUseCase>(
        () => _i184.DeleteTrackVersionUseCase(
              gh<_i161.TrackVersionRepository>(),
              gh<_i172.WaveformRepository>(),
              gh<_i176.AudioCommentRepository>(),
              gh<_i113.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i185.FindUserByEmailUseCase>(
        () => _i185.FindUserByEmailUseCase(gh<_i166.UserProfileRepository>()));
    gh.factory<_i186.GenerateAndStoreWaveform>(
        () => _i186.GenerateAndStoreWaveform(
              gh<_i172.WaveformRepository>(),
              gh<_i69.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i187.GetActiveVersionUseCase>(() =>
        _i187.GetActiveVersionUseCase(gh<_i161.TrackVersionRepository>()));
    gh.lazySingleton<_i188.GetProjectByIdUseCase>(
        () => _i188.GetProjectByIdUseCase(gh<_i157.ProjectsRepository>()));
    gh.lazySingleton<_i189.GetVersionByIdUseCase>(
        () => _i189.GetVersionByIdUseCase(gh<_i161.TrackVersionRepository>()));
    gh.factory<_i190.GetWaveformByVersion>(
        () => _i190.GetWaveformByVersion(gh<_i172.WaveformRepository>()));
    gh.lazySingleton<_i191.GoogleSignInUseCase>(() => _i191.GoogleSignInUseCase(
          gh<_i118.AuthRepository>(),
          gh<_i166.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i192.JoinProjectWithIdUseCase>(
        () => _i192.JoinProjectWithIdUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i193.LeaveProjectUseCase>(() => _i193.LeaveProjectUseCase(
          gh<_i157.ProjectsRepository>(),
          gh<_i100.SessionStorage>(),
        ));
    gh.factory<_i194.LoadTrackContextUseCase>(
        () => _i194.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i178.AudioTrackRepository>(),
              trackVersionRepository: gh<_i161.TrackVersionRepository>(),
              userProfileRepository: gh<_i166.UserProfileRepository>(),
              projectsRepository: gh<_i157.ProjectsRepository>(),
            ));
    gh.factory<_i195.MagicLinkBloc>(() => _i195.MagicLinkBloc(
          generateMagicLink: gh<_i126.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i68.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i81.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i48.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i85.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i192.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i118.AuthRepository>(),
        ));
    gh.factory<_i196.PlayPlaylistUseCase>(() => _i196.PlayPlaylistUseCase(
          playlistRepository: gh<_i155.PlaylistRepository>(),
          audioTrackRepository: gh<_i178.AudioTrackRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i113.AudioStorageRepository>(),
        ));
    gh.factory<_i197.PlayVersionUseCase>(() => _i197.PlayVersionUseCase(
          audioTrackRepository: gh<_i178.AudioTrackRepository>(),
          audioStorageRepository: gh<_i113.AudioStorageRepository>(),
          trackVersionRepository: gh<_i161.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i198.ProjectCommentService>(
        () => _i198.ProjectCommentService(gh<_i176.AudioCommentRepository>()));
    gh.lazySingleton<_i199.ProjectTrackService>(
        () => _i199.ProjectTrackService(gh<_i178.AudioTrackRepository>()));
    gh.lazySingleton<_i200.RenameTrackVersionUseCase>(() =>
        _i200.RenameTrackVersionUseCase(gh<_i161.TrackVersionRepository>()));
    gh.factory<_i201.RestorePlaybackStateUseCase>(
        () => _i201.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i42.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i178.AudioTrackRepository>(),
              audioStorageRepository: gh<_i113.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i202.SendInvitationUseCase>(
        () => _i202.SendInvitationUseCase(
              invitationRepository: gh<_i89.InvitationRepository>(),
              notificationService: gh<_i35.NotificationService>(),
              findUserByEmail: gh<_i185.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i26.MagicLinkRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i203.SessionCleanupService>(() => _i203.SessionCleanupService(
          userProfileRepository: gh<_i166.UserProfileRepository>(),
          projectsRepository: gh<_i157.ProjectsRepository>(),
          audioTrackRepository: gh<_i178.AudioTrackRepository>(),
          audioCommentRepository: gh<_i176.AudioCommentRepository>(),
          invitationRepository: gh<_i89.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i42.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i9.BlocStateCleanupService>(),
          sessionStorage: gh<_i100.SessionStorage>(),
          pendingOperationsRepository: gh<_i40.PendingOperationsRepository>(),
          waveformRepository: gh<_i172.WaveformRepository>(),
          trackVersionRepository: gh<_i161.TrackVersionRepository>(),
        ));
    gh.factory<_i204.SessionService>(() => _i204.SessionService(
          checkAuthUseCase: gh<_i123.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i136.OnboardingUseCase>(),
          profileUseCase: gh<_i180.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i205.SetActiveTrackVersionUseCase>(() =>
        _i205.SetActiveTrackVersionUseCase(gh<_i178.AudioTrackRepository>()));
    gh.lazySingleton<_i206.SignInUseCase>(() => _i206.SignInUseCase(
          gh<_i118.AuthRepository>(),
          gh<_i166.UserProfileRepository>(),
        ));
    gh.factory<_i207.SyncStatusCubit>(() => _i207.SyncStatusCubit(
          gh<_i101.SyncStatusProvider>(),
          gh<_i96.PendingOperationsManager>(),
          gh<_i163.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i208.UpdateUserProfileUseCase>(
        () => _i208.UpdateUserProfileUseCase(
              gh<_i166.UserProfileRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.factory<_i209.UserProfileBloc>(() => _i209.UserProfileBloc(
          updateUserProfileUseCase: gh<_i208.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i182.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i171.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i180.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i210.WatchAudioCommentsBundleUseCase>(
        () => _i210.WatchAudioCommentsBundleUseCase(
              gh<_i178.AudioTrackRepository>(),
              gh<_i176.AudioCommentRepository>(),
              gh<_i103.UserProfileCacheRepository>(),
            ));
    gh.factory<_i211.WatchCachedTrackBundlesUseCase>(
        () => _i211.WatchCachedTrackBundlesUseCase(
              gh<_i150.CacheMaintenanceService>(),
              gh<_i178.AudioTrackRepository>(),
              gh<_i166.UserProfileRepository>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i161.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i212.WatchProjectDetailUseCase>(
        () => _i212.WatchProjectDetailUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i178.AudioTrackRepository>(),
              gh<_i103.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i213.WatchProjectPlaylistUseCase>(
        () => _i213.WatchProjectPlaylistUseCase(
              gh<_i178.AudioTrackRepository>(),
              gh<_i161.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i214.WatchTrackVersionsBundleUseCase>(
        () => _i214.WatchTrackVersionsBundleUseCase(
              gh<_i178.AudioTrackRepository>(),
              gh<_i161.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i215.WatchTracksByProjectIdUseCase>(() =>
        _i215.WatchTracksByProjectIdUseCase(gh<_i178.AudioTrackRepository>()));
    gh.factory<_i216.WaveformBloc>(() => _i216.WaveformBloc(
          waveformRepository: gh<_i172.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i217.AddAudioCommentUseCase>(
        () => _i217.AddAudioCommentUseCase(
              gh<_i198.ProjectCommentService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i218.AddCollaboratorByEmailUseCase>(
        () => _i218.AddCollaboratorByEmailUseCase(
              gh<_i185.FindUserByEmailUseCase>(),
              gh<_i175.AddCollaboratorToProjectUseCase>(),
              gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i219.AddTrackVersionUseCase>(
        () => _i219.AddTrackVersionUseCase(
              gh<_i100.SessionStorage>(),
              gh<_i161.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i113.AudioStorageRepository>(),
              gh<_i186.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i220.AppBootstrap>(() => _i220.AppBootstrap(
          sessionService: gh<_i204.SessionService>(),
          performanceCollector: gh<_i41.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i13.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i83.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i221.AppFlowBloc>(() => _i221.AppFlowBloc(
          appBootstrap: gh<_i220.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i149.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i127.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i203.SessionCleanupService>(),
        ));
    gh.factory<_i222.AudioContextBloc>(() => _i222.AudioContextBloc(
        loadTrackContextUseCase: gh<_i194.LoadTrackContextUseCase>()));
    gh.factory<_i223.AudioPlayerService>(() => _i223.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i20.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i197.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i196.PlayPlaylistUseCase>(),
          audioTrackRepository: gh<_i178.AudioTrackRepository>(),
          pauseAudioUseCase: gh<_i38.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i49.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i57.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i55.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i56.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i51.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i59.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i58.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i53.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i52.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i50.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i201.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i224.AuthBloc>(() => _i224.AuthBloc(
          signIn: gh<_i206.SignInUseCase>(),
          signUp: gh<_i140.SignUpUseCase>(),
          googleSignIn: gh<_i191.GoogleSignInUseCase>(),
          appleSignIn: gh<_i146.AppleSignInUseCase>(),
          signOut: gh<_i139.SignOutUseCase>(),
        ));
    gh.factory<_i225.CacheManagementBloc>(() => _i225.CacheManagementBloc(
          deleteOne: gh<_i125.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i144.WatchStorageUsageUseCase>(),
          getStats: gh<_i153.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i152.CleanupCacheUseCase>(),
          watchBundles: gh<_i211.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i226.DeleteAudioCommentUseCase>(
        () => _i226.DeleteAudioCommentUseCase(
              gh<_i198.ProjectCommentService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
            ));
    gh.lazySingleton<_i227.DeleteAudioTrack>(() => _i227.DeleteAudioTrack(
          gh<_i100.SessionStorage>(),
          gh<_i157.ProjectsRepository>(),
          gh<_i199.ProjectTrackService>(),
          gh<_i161.TrackVersionRepository>(),
          gh<_i172.WaveformRepository>(),
          gh<_i113.AudioStorageRepository>(),
          gh<_i176.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i228.DeleteProjectUseCase>(
        () => _i228.DeleteProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
              gh<_i199.ProjectTrackService>(),
              gh<_i227.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i229.EditAudioTrackUseCase>(
        () => _i229.EditAudioTrackUseCase(
              gh<_i199.ProjectTrackService>(),
              gh<_i157.ProjectsRepository>(),
            ));
    gh.factory<_i230.ManageCollaboratorsBloc>(
        () => _i230.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i159.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i164.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i193.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i185.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i218.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i169.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i231.PlaylistBloc>(
        () => _i231.PlaylistBloc(gh<_i213.WatchProjectPlaylistUseCase>()));
    gh.factory<_i232.ProjectDetailBloc>(() => _i232.ProjectDetailBloc(
        watchProjectDetail: gh<_i212.WatchProjectDetailUseCase>()));
    gh.factory<_i233.ProjectInvitationActorBloc>(
        () => _i233.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i202.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i174.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i183.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i122.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i185.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i234.ProjectsBloc>(() => _i234.ProjectsBloc(
          createProject: gh<_i181.CreateProjectUseCase>(),
          updateProject: gh<_i165.UpdateProjectUseCase>(),
          deleteProject: gh<_i228.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i168.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i235.TrackVersionsBloc>(() => _i235.TrackVersionsBloc(
          gh<_i214.WatchTrackVersionsBundleUseCase>(),
          gh<_i205.SetActiveTrackVersionUseCase>(),
          gh<_i219.AddTrackVersionUseCase>(),
          gh<_i200.RenameTrackVersionUseCase>(),
          gh<_i184.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i236.UploadAudioTrackUseCase>(
        () => _i236.UploadAudioTrackUseCase(
              gh<_i199.ProjectTrackService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i100.SessionStorage>(),
              gh<_i219.AddTrackVersionUseCase>(),
              gh<_i178.AudioTrackRepository>(),
            ));
    gh.factory<_i237.AudioCommentBloc>(() => _i237.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i217.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i226.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i210.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i238.AudioPlayerBloc>(() => _i238.AudioPlayerBloc(
        audioPlayerService: gh<_i223.AudioPlayerService>()));
    gh.factory<_i239.AudioTrackBloc>(() => _i239.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i215.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i227.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i236.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i229.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i240.AppModule {}
