// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i12;

import 'package:cloud_firestore/cloud_firestore.dart' as _i18;
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:firebase_auth/firebase_auth.dart' as _i17;
import 'package:firebase_storage/firebase_storage.dart' as _i19;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i20;
import 'package:http/http.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i25;
import 'package:isar/isar.dart' as _i27;
import 'package:shared_preferences/shared_preferences.dart' as _i58;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i115;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i16;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i222;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i223;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i139;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i143;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i146;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i243;
import 'package:trackflow/core/audio/data/unified_audio_service.dart' as _i127;
import 'package:trackflow/core/audio/domain/audio_file_repository.dart'
    as _i126;
import 'package:trackflow/core/di/app_module.dart' as _i266;
import 'package:trackflow/core/infrastructure/domain/directory_service.dart'
    as _i13;
import 'package:trackflow/core/infrastructure/services/directory_service_impl.dart'
    as _i14;
import 'package:trackflow/core/network/network_state_manager.dart' as _i33;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i34;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i35;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i37;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i22;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i36;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i38;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i88;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i90;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i93;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i148;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i106;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i107;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i39;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i149;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i150;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i15;
import 'package:trackflow/core/session/current_user_service.dart' as _i140;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i42;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i43;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i135;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i184;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i130;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i112;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i113;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i227;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i121;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i125;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i134;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i21;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i64;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i228;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i229;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i230;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i167;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i258;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i259;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i85;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i129;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i137;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i160;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i176;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i173;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i226;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i81;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i82;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i97;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i186;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i98;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i185;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i216;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i240;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i248;
import 'package:trackflow/features/audio_comment/domain/usecases/get_cached_audio_comment_usecase.dart'
    as _i144;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i233;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i263;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i211;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i244;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i245;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i187;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i24;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i214;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i215;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i219;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i220;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i65;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i45;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i188;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i264;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i50;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i86;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i51;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i114;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i83;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i84;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i99;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i190;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i100;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i189;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i217;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i249;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i251;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i261;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i238;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i122;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i265;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i163;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i131;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i133;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i80;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i94;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i132;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i183;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i206;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i225;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i161;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i162;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i246;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i136;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i192;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i191;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i194;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i141;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i202;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i234;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i175;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i247;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i103;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i26;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i105;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i104;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i181;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i138;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i197;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i147;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i108;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i109;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i221;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i256;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i156;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i28;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i29;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i31;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i30;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i87;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i142;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i92;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i52;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i70;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i212;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i241;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i182;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i199;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i209;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i210;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i159;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i168;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i174;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i252;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i32;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i23;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i110;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i152;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i153;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i151;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i213;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i47;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i155;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i154;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i236;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i254;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i235;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i255;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i48;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i95;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i96;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i157;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i195;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i250;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i203;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i169;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i172;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i257;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i67;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i164;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i207;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i166;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i208;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i165;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i242;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i198;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i201;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i204;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i218;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i224;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i237;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i177;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i260;
import 'package:trackflow/features/track_version/presentation/cubit/version_selector_cubit.dart'
    as _i71;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i68;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i69;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i101;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i171;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i120;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i102;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i170;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i118;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i193;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i196;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i231;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i178;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i123;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i232;
import 'package:trackflow/features/voice_memos/data/datasources/voice_memo_local_datasource.dart'
    as _i72;
import 'package:trackflow/features/voice_memos/data/repositories/voice_memo_repository_impl.dart'
    as _i74;
import 'package:trackflow/features/voice_memos/domain/repositories/voice_memo_repository.dart'
    as _i73;
import 'package:trackflow/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart'
    as _i89;
import 'package:trackflow/features/voice_memos/domain/usecases/delete_voice_memo_usecase.dart'
    as _i91;
import 'package:trackflow/features/voice_memos/domain/usecases/play_voice_memo_usecase.dart'
    as _i253;
import 'package:trackflow/features/voice_memos/domain/usecases/update_voice_memo_usecase.dart'
    as _i117;
import 'package:trackflow/features/voice_memos/domain/usecases/watch_voice_memos_usecase.dart'
    as _i75;
import 'package:trackflow/features/voice_memos/presentation/bloc/voice_memo_bloc.dart'
    as _i262;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i78;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i79;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i180;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i77;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i124;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i179;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i76;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i200;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i205;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i239;

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
    gh.singleton<_i8.BlocStateCleanupService>(
        () => _i8.BlocStateCleanupService());
    gh.lazySingleton<_i9.Client>(() => appModule.httpClient);
    gh.lazySingleton<_i7.ConflictResolutionServiceImpl<dynamic>>(
        () => _i7.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i10.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i11.DeepLinkService>(() => _i11.DeepLinkService());
    await gh.factoryAsync<_i12.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.lazySingleton<_i13.DirectoryService>(() => _i14.DirectoryServiceImpl());
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
    gh.lazySingleton<_i20.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i21.IncrementalSyncService<_i22.Notification>>(
        () => _i23.NotificationIncrementalSyncService());
    gh.factory<_i24.InitializeAudioPlayerUseCase>(() =>
        _i24.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i25.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i26.InvitationRemoteDataSource>(() =>
        _i26.FirestoreInvitationRemoteDataSource(gh<_i18.FirebaseFirestore>()));
    await gh.factoryAsync<_i27.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i28.MagicLinkLocalDataSource>(
        () => _i28.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i29.MagicLinkRemoteDataSource>(
        () => _i29.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i18.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i30.MagicLinkRepository>(() =>
        _i31.MagicLinkRepositoryImp(gh<_i29.MagicLinkRemoteDataSource>()));
    gh.factory<_i32.NavigationCubit>(() => _i32.NavigationCubit());
    gh.lazySingleton<_i33.NetworkStateManager>(() => _i33.NetworkStateManager(
          gh<_i25.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.lazySingleton<_i34.NotificationLocalDataSource>(
        () => _i34.IsarNotificationLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i35.NotificationRemoteDataSource>(() =>
        _i35.FirestoreNotificationRemoteDataSource(
            gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i36.NotificationRepository>(
        () => _i37.NotificationRepositoryImpl(
              localDataSource: gh<_i34.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i35.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i33.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i38.NotificationService>(
        () => _i38.NotificationService(gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i39.ObserveNotificationsUseCase>(() =>
        _i39.ObserveNotificationsUseCase(gh<_i36.NotificationRepository>()));
    gh.factory<_i40.OperationExecutorFactory>(
        () => _i40.OperationExecutorFactory());
    gh.factory<_i41.PauseAudioUseCase>(() => _i41.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i42.PendingOperationsLocalDataSource>(
        () => _i42.IsarPendingOperationsLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i43.PendingOperationsRepository>(() =>
        _i43.PendingOperationsRepositoryImpl(
            gh<_i42.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i44.PlaybackPersistenceRepository>(
        () => _i45.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i46.PlaylistLocalDataSource>(
        () => _i46.PlaylistLocalDataSourceImpl(gh<_i27.Isar>()));
    gh.lazySingleton<_i47.PlaylistRemoteDataSource>(
        () => _i47.PlaylistRemoteDataSourceImpl(gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i48.ProjectRemoteDataSource>(() =>
        _i48.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i49.ProjectsLocalDataSource>(
        () => _i49.ProjectsLocalDataSourceImpl(gh<_i27.Isar>()));
    gh.lazySingleton<_i50.RecordingService>(
        () => _i51.PlatformRecordingService());
    gh.lazySingleton<_i52.ResendMagicLinkUseCase>(
        () => _i52.ResendMagicLinkUseCase(gh<_i30.MagicLinkRepository>()));
    gh.factory<_i53.ResumeAudioUseCase>(() => _i53.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i54.SavePlaybackStateUseCase>(
        () => _i54.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i55.SeekAudioUseCase>(() =>
        _i55.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i56.SetPlaybackSpeedUseCase>(() => _i56.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i57.SetVolumeUseCase>(() =>
        _i57.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i58.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i59.SkipToNextUseCase>(() => _i59.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.SkipToPreviousUseCase>(() => _i60.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i61.StartRecordingUseCase>(
        () => _i61.StartRecordingUseCase(gh<_i50.RecordingService>()));
    gh.factory<_i62.StopAudioUseCase>(() =>
        _i62.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i63.StopRecordingUseCase>(
        () => _i63.StopRecordingUseCase(gh<_i50.RecordingService>()));
    gh.lazySingleton<_i64.SyncCoordinator>(
        () => _i64.SyncCoordinator(gh<_i58.SharedPreferences>()));
    gh.factory<_i65.ToggleRepeatModeUseCase>(() => _i65.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i66.ToggleShuffleUseCase>(() => _i66.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i67.TrackVersionLocalDataSource>(
        () => _i67.IsarTrackVersionLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i68.UserProfileLocalDataSource>(
        () => _i68.IsarUserProfileLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i69.UserProfileRemoteDataSource>(
        () => _i69.UserProfileRemoteDataSourceImpl(
              gh<_i18.FirebaseFirestore>(),
              gh<_i19.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i70.ValidateMagicLinkUseCase>(
        () => _i70.ValidateMagicLinkUseCase(gh<_i30.MagicLinkRepository>()));
    gh.factory<_i71.VersionSelectorCubit>(() => _i71.VersionSelectorCubit());
    gh.lazySingleton<_i72.VoiceMemoLocalDataSource>(
        () => _i72.IsarVoiceMemoLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i73.VoiceMemoRepository>(() =>
        _i74.VoiceMemoRepositoryImpl(gh<_i72.VoiceMemoLocalDataSource>()));
    gh.lazySingleton<_i75.WatchVoiceMemosUseCase>(
        () => _i75.WatchVoiceMemosUseCase(gh<_i73.VoiceMemoRepository>()));
    gh.factory<_i76.WaveformGeneratorService>(() =>
        _i77.JustWaveformGeneratorService(cacheDir: gh<_i12.Directory>()));
    gh.factory<_i78.WaveformLocalDataSource>(
        () => _i78.WaveformLocalDataSourceImpl(isar: gh<_i27.Isar>()));
    gh.lazySingleton<_i79.WaveformRemoteDataSource>(() =>
        _i79.FirebaseStorageWaveformRemoteDataSource(
            gh<_i19.FirebaseStorage>()));
    gh.lazySingleton<_i80.AppleAuthService>(
        () => _i80.AppleAuthService(gh<_i17.FirebaseAuth>()));
    gh.lazySingleton<_i81.AudioCommentLocalDataSource>(
        () => _i81.IsarAudioCommentLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i82.AudioCommentRemoteDataSource>(() =>
        _i82.FirebaseAudioCommentRemoteDataSource(
            gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i83.AudioTrackLocalDataSource>(
        () => _i83.IsarAudioTrackLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i84.AudioTrackRemoteDataSource>(() =>
        _i84.AudioTrackRemoteDataSourceImpl(gh<_i18.FirebaseFirestore>()));
    gh.lazySingleton<_i85.CacheStorageLocalDataSource>(
        () => _i85.CacheStorageLocalDataSourceImpl(gh<_i27.Isar>()));
    gh.factory<_i86.CancelRecordingUseCase>(
        () => _i86.CancelRecordingUseCase(gh<_i50.RecordingService>()));
    gh.lazySingleton<_i87.ConsumeMagicLinkUseCase>(
        () => _i87.ConsumeMagicLinkUseCase(gh<_i30.MagicLinkRepository>()));
    gh.factory<_i88.CreateNotificationUseCase>(() =>
        _i88.CreateNotificationUseCase(gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i89.CreateVoiceMemoUseCase>(
        () => _i89.CreateVoiceMemoUseCase(gh<_i73.VoiceMemoRepository>()));
    gh.factory<_i90.DeleteNotificationUseCase>(() =>
        _i90.DeleteNotificationUseCase(gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i91.DeleteVoiceMemoUseCase>(
        () => _i91.DeleteVoiceMemoUseCase(gh<_i73.VoiceMemoRepository>()));
    gh.lazySingleton<_i92.GetMagicLinkStatusUseCase>(
        () => _i92.GetMagicLinkStatusUseCase(gh<_i30.MagicLinkRepository>()));
    gh.lazySingleton<_i93.GetUnreadNotificationsCountUseCase>(() =>
        _i93.GetUnreadNotificationsCountUseCase(
            gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i94.GoogleAuthService>(() => _i94.GoogleAuthService(
          gh<_i20.GoogleSignIn>(),
          gh<_i17.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i21.IncrementalSyncService<_i95.ProjectDTO>>(
        () => _i96.ProjectIncrementalSyncService(
              gh<_i48.ProjectRemoteDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i21.IncrementalSyncService<_i97.AudioCommentDTO>>(
        () => _i98.AudioCommentIncrementalSyncService(
              gh<_i82.AudioCommentRemoteDataSource>(),
              gh<_i81.AudioCommentLocalDataSource>(),
              gh<_i67.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i21.IncrementalSyncService<_i99.AudioTrackDTO>>(
        () => _i100.AudioTrackIncrementalSyncService(
              gh<_i84.AudioTrackRemoteDataSource>(),
              gh<_i83.AudioTrackLocalDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i21.IncrementalSyncService<_i101.UserProfileDTO>>(
        () => _i102.UserProfileIncrementalSyncService(
              gh<_i69.UserProfileRemoteDataSource>(),
              gh<_i68.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i103.InvitationLocalDataSource>(
        () => _i103.IsarInvitationLocalDataSource(gh<_i27.Isar>()));
    gh.lazySingleton<_i104.InvitationRepository>(
        () => _i105.InvitationRepositoryImpl(
              localDataSource: gh<_i103.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i26.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i33.NetworkStateManager>(),
            ));
    gh.factory<_i106.MarkAsUnreadUseCase>(
        () => _i106.MarkAsUnreadUseCase(gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i107.MarkNotificationAsReadUseCase>(() =>
        _i107.MarkNotificationAsReadUseCase(gh<_i36.NotificationRepository>()));
    gh.lazySingleton<_i108.ObservePendingInvitationsUseCase>(() =>
        _i108.ObservePendingInvitationsUseCase(
            gh<_i104.InvitationRepository>()));
    gh.lazySingleton<_i109.ObserveSentInvitationsUseCase>(() =>
        _i109.ObserveSentInvitationsUseCase(gh<_i104.InvitationRepository>()));
    gh.lazySingleton<_i110.OnboardingStateLocalDataSource>(() =>
        _i110.OnboardingStateLocalDataSourceImpl(gh<_i58.SharedPreferences>()));
    gh.lazySingleton<_i111.PendingOperationsManager>(
        () => _i111.PendingOperationsManager(
              gh<_i43.PendingOperationsRepository>(),
              gh<_i33.NetworkStateManager>(),
              gh<_i40.OperationExecutorFactory>(),
            ));
    gh.factory<_i112.PlaylistOperationExecutor>(() =>
        _i112.PlaylistOperationExecutor(gh<_i47.PlaylistRemoteDataSource>()));
    gh.factory<_i113.ProjectOperationExecutor>(() =>
        _i113.ProjectOperationExecutor(gh<_i48.ProjectRemoteDataSource>()));
    gh.factory<_i114.RecordingBloc>(() => _i114.RecordingBloc(
          gh<_i61.StartRecordingUseCase>(),
          gh<_i63.StopRecordingUseCase>(),
          gh<_i86.CancelRecordingUseCase>(),
          gh<_i50.RecordingService>(),
        ));
    gh.lazySingleton<_i115.SessionStorage>(
        () => _i115.SessionStorageImpl(prefs: gh<_i58.SharedPreferences>()));
    gh.factory<_i116.SyncStatusProvider>(() => _i116.SyncStatusProvider(
          syncCoordinator: gh<_i64.SyncCoordinator>(),
          pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i117.UpdateVoiceMemoUseCase>(
        () => _i117.UpdateVoiceMemoUseCase(gh<_i73.VoiceMemoRepository>()));
    gh.lazySingleton<_i118.UserProfileCacheRepository>(
        () => _i119.UserProfileCacheRepositoryImpl(
              gh<_i69.UserProfileRemoteDataSource>(),
              gh<_i68.UserProfileLocalDataSource>(),
              gh<_i33.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i120.UserProfileCollaboratorIncrementalSyncService>(
        () => _i120.UserProfileCollaboratorIncrementalSyncService(
              gh<_i69.UserProfileRemoteDataSource>(),
              gh<_i68.UserProfileLocalDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i121.UserProfileOperationExecutor>(() =>
        _i121.UserProfileOperationExecutor(
            gh<_i69.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i122.WatchTrackUploadStatusUseCase>(() =>
        _i122.WatchTrackUploadStatusUseCase(
            gh<_i111.PendingOperationsManager>()));
    gh.lazySingleton<_i123.WatchUserProfilesUseCase>(() =>
        _i123.WatchUserProfilesUseCase(gh<_i118.UserProfileCacheRepository>()));
    gh.lazySingleton<_i124.WaveformIncrementalSyncService>(
        () => _i124.WaveformIncrementalSyncService(
              gh<_i67.TrackVersionLocalDataSource>(),
              gh<_i78.WaveformLocalDataSource>(),
              gh<_i79.WaveformRemoteDataSource>(),
            ));
    gh.factory<_i125.WaveformOperationExecutor>(() =>
        _i125.WaveformOperationExecutor(gh<_i79.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i126.AudioFileRepository>(
        () => _i127.AudioFileRepositoryImpl(
              gh<_i19.FirebaseStorage>(),
              gh<_i13.DirectoryService>(),
              gh<_i85.CacheStorageLocalDataSource>(),
              httpClient: gh<_i9.Client>(),
            ));
    gh.lazySingleton<_i128.AudioStorageRepository>(
        () => _i129.AudioStorageRepositoryImpl(
              localDataSource: gh<_i85.CacheStorageLocalDataSource>(),
              directoryService: gh<_i13.DirectoryService>(),
            ));
    gh.factory<_i130.AudioTrackOperationExecutor>(
        () => _i130.AudioTrackOperationExecutor(
              gh<_i84.AudioTrackRemoteDataSource>(),
              gh<_i83.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i131.AuthRemoteDataSource>(
        () => _i131.AuthRemoteDataSourceImpl(
              gh<_i17.FirebaseAuth>(),
              gh<_i94.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i132.AuthRepository>(() => _i133.AuthRepositoryImpl(
          remote: gh<_i131.AuthRemoteDataSource>(),
          sessionStorage: gh<_i115.SessionStorage>(),
          networkStateManager: gh<_i33.NetworkStateManager>(),
          googleAuthService: gh<_i94.GoogleAuthService>(),
          appleAuthService: gh<_i80.AppleAuthService>(),
        ));
    gh.lazySingleton<_i134.BackgroundSyncCoordinator>(
        () => _i135.BackgroundSyncCoordinatorImpl(
              gh<_i33.NetworkStateManager>(),
              gh<_i64.SyncCoordinator>(),
              gh<_i111.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i136.CacheManagementLocalDataSource>(
        () => _i136.CacheManagementLocalDataSourceImpl(
              local: gh<_i85.CacheStorageLocalDataSource>(),
              directoryService: gh<_i13.DirectoryService>(),
            ));
    gh.factory<_i137.CacheTrackUseCase>(() => _i137.CacheTrackUseCase(
          gh<_i126.AudioFileRepository>(),
          gh<_i128.AudioStorageRepository>(),
          gh<_i13.DirectoryService>(),
        ));
    gh.lazySingleton<_i138.CancelInvitationUseCase>(
        () => _i138.CancelInvitationUseCase(gh<_i104.InvitationRepository>()));
    gh.factory<_i139.CheckAuthenticationStatusUseCase>(() =>
        _i139.CheckAuthenticationStatusUseCase(gh<_i132.AuthRepository>()));
    gh.factory<_i140.CurrentUserService>(
        () => _i140.CurrentUserService(gh<_i115.SessionStorage>()));
    gh.factory<_i141.DeleteCachedAudioUseCase>(() =>
        _i141.DeleteCachedAudioUseCase(gh<_i128.AudioStorageRepository>()));
    gh.lazySingleton<_i142.GenerateMagicLinkUseCase>(
        () => _i142.GenerateMagicLinkUseCase(
              gh<_i30.MagicLinkRepository>(),
              gh<_i132.AuthRepository>(),
            ));
    gh.lazySingleton<_i143.GetAuthStateUseCase>(
        () => _i143.GetAuthStateUseCase(gh<_i132.AuthRepository>()));
    gh.factory<_i144.GetCachedAudioCommentUseCase>(
        () => _i144.GetCachedAudioCommentUseCase(
              gh<_i128.AudioStorageRepository>(),
              gh<_i126.AudioFileRepository>(),
            ));
    gh.factory<_i145.GetCachedTrackPathUseCase>(() =>
        _i145.GetCachedTrackPathUseCase(gh<_i128.AudioStorageRepository>()));
    gh.factory<_i146.GetCurrentUserUseCase>(
        () => _i146.GetCurrentUserUseCase(gh<_i132.AuthRepository>()));
    gh.lazySingleton<_i147.GetPendingInvitationsCountUseCase>(() =>
        _i147.GetPendingInvitationsCountUseCase(
            gh<_i104.InvitationRepository>()));
    gh.factory<_i148.MarkAllNotificationsAsReadUseCase>(
        () => _i148.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i36.NotificationRepository>(),
              currentUserService: gh<_i140.CurrentUserService>(),
            ));
    gh.factory<_i149.NotificationActorBloc>(() => _i149.NotificationActorBloc(
          createNotificationUseCase: gh<_i88.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i107.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i106.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i148.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i90.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i150.NotificationWatcherBloc>(
        () => _i150.NotificationWatcherBloc(
              notificationRepository: gh<_i36.NotificationRepository>(),
              currentUserService: gh<_i140.CurrentUserService>(),
            ));
    gh.lazySingleton<_i151.OnboardingRepository>(() =>
        _i152.OnboardingRepositoryImpl(
            gh<_i110.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i153.OnboardingUseCase>(
        () => _i153.OnboardingUseCase(gh<_i151.OnboardingRepository>()));
    gh.lazySingleton<_i154.PlaylistRepository>(
        () => _i155.PlaylistRepositoryImpl(
              localDataSource: gh<_i46.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i134.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
            ));
    gh.factory<_i156.ProjectInvitationWatcherBloc>(
        () => _i156.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i104.InvitationRepository>(),
              currentUserService: gh<_i140.CurrentUserService>(),
            ));
    gh.lazySingleton<_i157.ProjectsRepository>(
        () => _i158.ProjectsRepositoryImpl(
              localDataSource: gh<_i49.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i134.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i159.RemoveCollaboratorUseCase>(
        () => _i159.RemoveCollaboratorUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.factory<_i160.RemoveTrackCacheUseCase>(() =>
        _i160.RemoveTrackCacheUseCase(gh<_i128.AudioStorageRepository>()));
    gh.lazySingleton<_i161.SignOutUseCase>(
        () => _i161.SignOutUseCase(gh<_i132.AuthRepository>()));
    gh.lazySingleton<_i162.SignUpUseCase>(
        () => _i162.SignUpUseCase(gh<_i132.AuthRepository>()));
    gh.factory<_i163.TrackUploadStatusCubit>(() => _i163.TrackUploadStatusCubit(
        gh<_i122.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i164.TrackVersionRemoteDataSource>(
        () => _i164.TrackVersionRemoteDataSourceImpl(
              gh<_i18.FirebaseFirestore>(),
              gh<_i126.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i165.TrackVersionRepository>(
        () => _i166.TrackVersionRepositoryImpl(
              gh<_i67.TrackVersionLocalDataSource>(),
              gh<_i134.BackgroundSyncCoordinator>(),
              gh<_i111.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i167.TriggerUpstreamSyncUseCase>(() =>
        _i167.TriggerUpstreamSyncUseCase(
            gh<_i134.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i168.UpdateCollaboratorRoleUseCase>(
        () => _i168.UpdateCollaboratorRoleUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i169.UpdateProjectUseCase>(
        () => _i169.UpdateProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i170.UserProfileRepository>(
        () => _i171.UserProfileRepositoryImpl(
              localDataSource: gh<_i68.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i69.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i33.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i134.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
              firestore: gh<_i18.FirebaseFirestore>(),
              sessionStorage: gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.WatchAllProjectsUseCase>(
        () => _i172.WatchAllProjectsUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.factory<_i173.WatchCachedAudiosUseCase>(() =>
        _i173.WatchCachedAudiosUseCase(gh<_i128.AudioStorageRepository>()));
    gh.lazySingleton<_i174.WatchCollaboratorsBundleUseCase>(
        () => _i174.WatchCollaboratorsBundleUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i123.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i175.WatchStorageUsageUseCase>(() =>
        _i175.WatchStorageUsageUseCase(gh<_i128.AudioStorageRepository>()));
    gh.factory<_i176.WatchTrackCacheStatusUseCase>(() =>
        _i176.WatchTrackCacheStatusUseCase(gh<_i128.AudioStorageRepository>()));
    gh.lazySingleton<_i177.WatchTrackVersionsUseCase>(() =>
        _i177.WatchTrackVersionsUseCase(gh<_i165.TrackVersionRepository>()));
    gh.lazySingleton<_i178.WatchUserProfileUseCase>(
        () => _i178.WatchUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.factory<_i179.WaveformRepository>(() => _i180.WaveformRepositoryImpl(
          localDataSource: gh<_i78.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i79.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i134.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i181.AcceptInvitationUseCase>(
        () => _i181.AcceptInvitationUseCase(
              invitationRepository: gh<_i104.InvitationRepository>(),
              projectRepository: gh<_i157.ProjectsRepository>(),
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              notificationService: gh<_i38.NotificationService>(),
            ));
    gh.lazySingleton<_i182.AddCollaboratorToProjectUseCase>(
        () => _i182.AddCollaboratorToProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i183.AppleSignInUseCase>(
        () => _i183.AppleSignInUseCase(gh<_i132.AuthRepository>()));
    gh.factory<_i184.AudioCommentOperationExecutor>(
        () => _i184.AudioCommentOperationExecutor(
              gh<_i82.AudioCommentRemoteDataSource>(),
              gh<_i126.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i185.AudioCommentRepository>(
        () => _i186.AudioCommentRepositoryImpl(
              localDataSource: gh<_i81.AudioCommentLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i134.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i111.PendingOperationsManager>(),
              trackVersionRepository: gh<_i165.TrackVersionRepository>(),
              audioStorageRepository: gh<_i128.AudioStorageRepository>(),
            ));
    gh.factory<_i187.AudioSourceResolver>(() => _i188.AudioSourceResolverImpl(
          gh<_i128.AudioStorageRepository>(),
          gh<_i126.AudioFileRepository>(),
          gh<_i13.DirectoryService>(),
        ));
    gh.lazySingleton<_i189.AudioTrackRepository>(
        () => _i190.AudioTrackRepositoryImpl(
              gh<_i83.AudioTrackLocalDataSource>(),
              gh<_i134.BackgroundSyncCoordinator>(),
              gh<_i111.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i191.CacheMaintenanceService>(() =>
        _i192.CacheMaintenanceServiceImpl(
            gh<_i136.CacheManagementLocalDataSource>()));
    gh.factory<_i193.CheckProfileCompletenessUseCase>(() =>
        _i193.CheckProfileCompletenessUseCase(
            gh<_i170.UserProfileRepository>()));
    gh.factory<_i194.CleanupCacheUseCase>(
        () => _i194.CleanupCacheUseCase(gh<_i191.CacheMaintenanceService>()));
    gh.lazySingleton<_i195.CreateProjectUseCase>(
        () => _i195.CreateProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.factory<_i196.CreateUserProfileUseCase>(
        () => _i196.CreateUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i197.DeclineInvitationUseCase>(
        () => _i197.DeclineInvitationUseCase(
              invitationRepository: gh<_i104.InvitationRepository>(),
              projectRepository: gh<_i157.ProjectsRepository>(),
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              notificationService: gh<_i38.NotificationService>(),
            ));
    gh.lazySingleton<_i198.DeleteTrackVersionUseCase>(
        () => _i198.DeleteTrackVersionUseCase(
              gh<_i165.TrackVersionRepository>(),
              gh<_i179.WaveformRepository>(),
              gh<_i185.AudioCommentRepository>(),
              gh<_i128.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i199.FindUserByEmailUseCase>(
        () => _i199.FindUserByEmailUseCase(gh<_i170.UserProfileRepository>()));
    gh.factory<_i200.GenerateAndStoreWaveform>(
        () => _i200.GenerateAndStoreWaveform(
              gh<_i179.WaveformRepository>(),
              gh<_i76.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i201.GetActiveVersionUseCase>(() =>
        _i201.GetActiveVersionUseCase(gh<_i165.TrackVersionRepository>()));
    gh.factory<_i202.GetCacheStorageStatsUseCase>(() =>
        _i202.GetCacheStorageStatsUseCase(gh<_i191.CacheMaintenanceService>()));
    gh.lazySingleton<_i203.GetProjectByIdUseCase>(
        () => _i203.GetProjectByIdUseCase(gh<_i157.ProjectsRepository>()));
    gh.lazySingleton<_i204.GetVersionByIdUseCase>(
        () => _i204.GetVersionByIdUseCase(gh<_i165.TrackVersionRepository>()));
    gh.factory<_i205.GetWaveformByVersion>(
        () => _i205.GetWaveformByVersion(gh<_i179.WaveformRepository>()));
    gh.lazySingleton<_i206.GoogleSignInUseCase>(() => _i206.GoogleSignInUseCase(
          gh<_i132.AuthRepository>(),
          gh<_i170.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i21.IncrementalSyncService<_i207.TrackVersionDTO>>(
        () => _i208.TrackVersionIncrementalSyncService(
              gh<_i164.TrackVersionRemoteDataSource>(),
              gh<_i67.TrackVersionLocalDataSource>(),
              gh<_i83.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i209.JoinProjectWithIdUseCase>(
        () => _i209.JoinProjectWithIdUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i210.LeaveProjectUseCase>(() => _i210.LeaveProjectUseCase(
          gh<_i157.ProjectsRepository>(),
          gh<_i115.SessionStorage>(),
        ));
    gh.factory<_i211.LoadTrackContextUseCase>(
        () => _i211.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i189.AudioTrackRepository>(),
              trackVersionRepository: gh<_i165.TrackVersionRepository>(),
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              projectsRepository: gh<_i157.ProjectsRepository>(),
            ));
    gh.factory<_i212.MagicLinkBloc>(() => _i212.MagicLinkBloc(
          generateMagicLink: gh<_i142.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i70.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i87.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i52.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i92.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i209.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i132.AuthRepository>(),
        ));
    gh.factory<_i213.OnboardingBloc>(() => _i213.OnboardingBloc(
          onboardingUseCase: gh<_i153.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i146.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i214.PlayPlaylistUseCase>(() => _i214.PlayPlaylistUseCase(
          playlistRepository: gh<_i154.PlaylistRepository>(),
          audioTrackRepository: gh<_i189.AudioTrackRepository>(),
          trackVersionRepository: gh<_i165.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i128.AudioStorageRepository>(),
        ));
    gh.factory<_i215.PlayVersionUseCase>(() => _i215.PlayVersionUseCase(
          audioTrackRepository: gh<_i189.AudioTrackRepository>(),
          audioStorageRepository: gh<_i128.AudioStorageRepository>(),
          trackVersionRepository: gh<_i165.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i216.ProjectCommentService>(
        () => _i216.ProjectCommentService(gh<_i185.AudioCommentRepository>()));
    gh.lazySingleton<_i217.ProjectTrackService>(
        () => _i217.ProjectTrackService(gh<_i189.AudioTrackRepository>()));
    gh.lazySingleton<_i218.RenameTrackVersionUseCase>(() =>
        _i218.RenameTrackVersionUseCase(gh<_i165.TrackVersionRepository>()));
    gh.factory<_i219.ResolveTrackVersionUseCase>(
        () => _i219.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i189.AudioTrackRepository>(),
              trackVersionRepository: gh<_i165.TrackVersionRepository>(),
            ));
    gh.factory<_i220.RestorePlaybackStateUseCase>(
        () => _i220.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i189.AudioTrackRepository>(),
              audioStorageRepository: gh<_i128.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i221.SendInvitationUseCase>(
        () => _i221.SendInvitationUseCase(
              invitationRepository: gh<_i104.InvitationRepository>(),
              notificationService: gh<_i38.NotificationService>(),
              findUserByEmail: gh<_i199.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i30.MagicLinkRepository>(),
              currentUserService: gh<_i140.CurrentUserService>(),
            ));
    gh.factory<_i222.SessionCleanupService>(() => _i222.SessionCleanupService(
          userProfileRepository: gh<_i170.UserProfileRepository>(),
          projectsRepository: gh<_i157.ProjectsRepository>(),
          audioTrackRepository: gh<_i189.AudioTrackRepository>(),
          audioCommentRepository: gh<_i185.AudioCommentRepository>(),
          invitationRepository: gh<_i104.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i44.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i115.SessionStorage>(),
          pendingOperationsRepository: gh<_i43.PendingOperationsRepository>(),
          waveformRepository: gh<_i179.WaveformRepository>(),
          trackVersionRepository: gh<_i165.TrackVersionRepository>(),
          syncCoordinator: gh<_i64.SyncCoordinator>(),
        ));
    gh.factory<_i223.SessionService>(() => _i223.SessionService(
          checkAuthUseCase: gh<_i139.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i146.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i153.OnboardingUseCase>(),
          profileUseCase: gh<_i193.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i224.SetActiveTrackVersionUseCase>(() =>
        _i224.SetActiveTrackVersionUseCase(gh<_i189.AudioTrackRepository>()));
    gh.lazySingleton<_i225.SignInUseCase>(() => _i225.SignInUseCase(
          gh<_i132.AuthRepository>(),
          gh<_i170.UserProfileRepository>(),
        ));
    gh.factory<_i226.TrackCacheBloc>(() => _i226.TrackCacheBloc(
          cacheTrackUseCase: gh<_i137.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i176.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i160.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i145.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i227.TrackVersionOperationExecutor>(
        () => _i227.TrackVersionOperationExecutor(
              gh<_i164.TrackVersionRemoteDataSource>(),
              gh<_i67.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i228.TriggerDownstreamSyncUseCase>(
        () => _i228.TriggerDownstreamSyncUseCase(
              gh<_i134.BackgroundSyncCoordinator>(),
              gh<_i223.SessionService>(),
            ));
    gh.lazySingleton<_i229.TriggerForegroundSyncUseCase>(
        () => _i229.TriggerForegroundSyncUseCase(
              gh<_i134.BackgroundSyncCoordinator>(),
              gh<_i223.SessionService>(),
            ));
    gh.lazySingleton<_i230.TriggerStartupSyncUseCase>(
        () => _i230.TriggerStartupSyncUseCase(
              gh<_i134.BackgroundSyncCoordinator>(),
              gh<_i223.SessionService>(),
            ));
    gh.factory<_i231.UpdateUserProfileUseCase>(
        () => _i231.UpdateUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.factory<_i232.UserProfileBloc>(() => _i232.UserProfileBloc(
          updateUserProfileUseCase: gh<_i231.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i196.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i178.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i193.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i146.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i233.WatchAudioCommentsBundleUseCase>(
        () => _i233.WatchAudioCommentsBundleUseCase(
              gh<_i189.AudioTrackRepository>(),
              gh<_i185.AudioCommentRepository>(),
              gh<_i118.UserProfileCacheRepository>(),
            ));
    gh.factory<_i234.WatchCachedTrackBundlesUseCase>(
        () => _i234.WatchCachedTrackBundlesUseCase(
              gh<_i191.CacheMaintenanceService>(),
              gh<_i189.AudioTrackRepository>(),
              gh<_i170.UserProfileRepository>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i235.WatchProjectDetailUseCase>(
        () => _i235.WatchProjectDetailUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i189.AudioTrackRepository>(),
              gh<_i118.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i236.WatchProjectPlaylistUseCase>(
        () => _i236.WatchProjectPlaylistUseCase(
              gh<_i189.AudioTrackRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i237.WatchTrackVersionsBundleUseCase>(
        () => _i237.WatchTrackVersionsBundleUseCase(
              gh<_i189.AudioTrackRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i238.WatchTracksByProjectIdUseCase>(() =>
        _i238.WatchTracksByProjectIdUseCase(gh<_i189.AudioTrackRepository>()));
    gh.factory<_i239.WaveformBloc>(() => _i239.WaveformBloc(
          waveformRepository: gh<_i179.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i240.AddAudioCommentUseCase>(
        () => _i240.AddAudioCommentUseCase(
              gh<_i216.ProjectCommentService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i241.AddCollaboratorByEmailUseCase>(
        () => _i241.AddCollaboratorByEmailUseCase(
              gh<_i199.FindUserByEmailUseCase>(),
              gh<_i182.AddCollaboratorToProjectUseCase>(),
              gh<_i38.NotificationService>(),
            ));
    gh.lazySingleton<_i242.AddTrackVersionUseCase>(
        () => _i242.AddTrackVersionUseCase(
              gh<_i115.SessionStorage>(),
              gh<_i165.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i128.AudioStorageRepository>(),
              gh<_i200.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i243.AppFlowBloc>(() => _i243.AppFlowBloc(
          sessionService: gh<_i223.SessionService>(),
          getAuthStateUseCase: gh<_i143.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i222.SessionCleanupService>(),
        ));
    gh.factory<_i244.AudioContextBloc>(() => _i244.AudioContextBloc(
        loadTrackContextUseCase: gh<_i211.LoadTrackContextUseCase>()));
    gh.factory<_i245.AudioPlayerService>(() => _i245.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i24.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i215.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i214.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i219.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i41.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i53.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i62.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i59.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i60.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i55.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i66.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i65.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i57.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i56.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i54.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i220.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i246.AuthBloc>(() => _i246.AuthBloc(
          signIn: gh<_i225.SignInUseCase>(),
          signUp: gh<_i162.SignUpUseCase>(),
          googleSignIn: gh<_i206.GoogleSignInUseCase>(),
          appleSignIn: gh<_i183.AppleSignInUseCase>(),
          signOut: gh<_i161.SignOutUseCase>(),
        ));
    gh.factory<_i247.CacheManagementBloc>(() => _i247.CacheManagementBloc(
          deleteOne: gh<_i141.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i175.WatchStorageUsageUseCase>(),
          getStats: gh<_i202.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i194.CleanupCacheUseCase>(),
          watchBundles: gh<_i234.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i248.DeleteAudioCommentUseCase>(
        () => _i248.DeleteAudioCommentUseCase(
              gh<_i216.ProjectCommentService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
            ));
    gh.lazySingleton<_i249.DeleteAudioTrack>(() => _i249.DeleteAudioTrack(
          gh<_i115.SessionStorage>(),
          gh<_i157.ProjectsRepository>(),
          gh<_i217.ProjectTrackService>(),
          gh<_i165.TrackVersionRepository>(),
          gh<_i179.WaveformRepository>(),
          gh<_i128.AudioStorageRepository>(),
          gh<_i185.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i250.DeleteProjectUseCase>(
        () => _i250.DeleteProjectUseCase(
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
              gh<_i217.ProjectTrackService>(),
              gh<_i249.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i251.EditAudioTrackUseCase>(
        () => _i251.EditAudioTrackUseCase(
              gh<_i217.ProjectTrackService>(),
              gh<_i157.ProjectsRepository>(),
            ));
    gh.factory<_i252.ManageCollaboratorsBloc>(
        () => _i252.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i159.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i168.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i210.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i199.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i241.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i174.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.lazySingleton<_i253.PlayVoiceMemoUseCase>(
        () => _i253.PlayVoiceMemoUseCase(gh<_i245.AudioPlayerService>()));
    gh.factory<_i254.PlaylistBloc>(
        () => _i254.PlaylistBloc(gh<_i236.WatchProjectPlaylistUseCase>()));
    gh.factory<_i255.ProjectDetailBloc>(() => _i255.ProjectDetailBloc(
        watchProjectDetail: gh<_i235.WatchProjectDetailUseCase>()));
    gh.factory<_i256.ProjectInvitationActorBloc>(
        () => _i256.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i221.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i181.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i197.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i138.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i199.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i257.ProjectsBloc>(() => _i257.ProjectsBloc(
          createProject: gh<_i195.CreateProjectUseCase>(),
          updateProject: gh<_i169.UpdateProjectUseCase>(),
          deleteProject: gh<_i250.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i172.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i258.SyncBloc>(() => _i258.SyncBloc(
          gh<_i230.TriggerStartupSyncUseCase>(),
          gh<_i167.TriggerUpstreamSyncUseCase>(),
          gh<_i229.TriggerForegroundSyncUseCase>(),
          gh<_i228.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i259.SyncStatusCubit>(() => _i259.SyncStatusCubit(
          gh<_i116.SyncStatusProvider>(),
          gh<_i111.PendingOperationsManager>(),
          gh<_i167.TriggerUpstreamSyncUseCase>(),
          gh<_i229.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i260.TrackVersionsBloc>(() => _i260.TrackVersionsBloc(
          gh<_i237.WatchTrackVersionsBundleUseCase>(),
          gh<_i224.SetActiveTrackVersionUseCase>(),
          gh<_i242.AddTrackVersionUseCase>(),
          gh<_i218.RenameTrackVersionUseCase>(),
          gh<_i198.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i261.UploadAudioTrackUseCase>(
        () => _i261.UploadAudioTrackUseCase(
              gh<_i217.ProjectTrackService>(),
              gh<_i157.ProjectsRepository>(),
              gh<_i115.SessionStorage>(),
              gh<_i242.AddTrackVersionUseCase>(),
              gh<_i189.AudioTrackRepository>(),
            ));
    gh.factory<_i262.VoiceMemoBloc>(() => _i262.VoiceMemoBloc(
          gh<_i75.WatchVoiceMemosUseCase>(),
          gh<_i89.CreateVoiceMemoUseCase>(),
          gh<_i117.UpdateVoiceMemoUseCase>(),
          gh<_i91.DeleteVoiceMemoUseCase>(),
          gh<_i253.PlayVoiceMemoUseCase>(),
        ));
    gh.factory<_i263.AudioCommentBloc>(() => _i263.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i240.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i248.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i233.WatchAudioCommentsBundleUseCase>(),
          getCachedAudioCommentUseCase:
              gh<_i144.GetCachedAudioCommentUseCase>(),
        ));
    gh.factory<_i264.AudioPlayerBloc>(() => _i264.AudioPlayerBloc(
        audioPlayerService: gh<_i245.AudioPlayerService>()));
    gh.factory<_i265.AudioTrackBloc>(() => _i265.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i238.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i249.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i261.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i251.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i266.AppModule {}
