// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i14;

import 'package:cloud_firestore/cloud_firestore.dart' as _i20;
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:firebase_auth/firebase_auth.dart' as _i19;
import 'package:firebase_storage/firebase_storage.dart' as _i21;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i23;
import 'package:http/http.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i28;
import 'package:isar/isar.dart' as _i30;
import 'package:shared_preferences/shared_preferences.dart' as _i62;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i117;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i18;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i247;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i212;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i136;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i139;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i140;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i254;
import 'package:trackflow/core/audio/data/unified_audio_service.dart' as _i127;
import 'package:trackflow/core/audio/domain/audio_file_repository.dart'
    as _i126;
import 'package:trackflow/core/di/app_module.dart' as _i259;
import 'package:trackflow/core/infrastructure/domain/directory_service.dart'
    as _i15;
import 'package:trackflow/core/infrastructure/services/directory_service_impl.dart'
    as _i16;
import 'package:trackflow/core/network/network_state_manager.dart' as _i36;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i37;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i38;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i40;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i25;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i39;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i41;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i91;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i92;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i94;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i142;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i108;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i109;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i42;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i143;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i144;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i17;
import 'package:trackflow/core/session/current_user_service.dart' as _i137;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i45;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i46;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i133;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i230;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i128;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i43;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i114;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i216;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i122;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i125;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i132;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i24;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i113;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i68;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i217;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i218;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i219;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i160;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i248;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i249;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i88;
import 'package:trackflow/features/audio_cache/data/repositories/audio_download_repository_impl.dart'
    as _i176;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart'
    as _i175;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i13;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i183;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i22;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i78;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i76;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i215;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i84;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i85;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i103;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i232;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i104;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_storage_coordinator.dart'
    as _i174;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i231;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i243;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i253;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i257;
import 'package:trackflow/features/audio_comment/domain/usecases/get_cached_audio_comment_usecase.dart'
    as _i193;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i252;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i258;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i202;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i233;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i234;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i177;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i27;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i205;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i206;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i209;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i210;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i64;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i70;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i48;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i178;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i255;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i53;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i89;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i65;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i54;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i116;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i86;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i87;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i98;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i180;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i99;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i179;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i207;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i237;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i240;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i251;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i226;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i123;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i256;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i156;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i129;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i131;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i83;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i95;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i130;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i173;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i197;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i214;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i154;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i155;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i235;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i134;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i182;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i181;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i185;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i12;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i192;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i222;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i77;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i236;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i105;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i29;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i107;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i106;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i171;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i135;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i188;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i141;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i110;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i111;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i211;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i245;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i150;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i31;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i32;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i34;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i33;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i90;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i138;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i93;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i56;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i75;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i203;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i228;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i172;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i189;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i200;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i201;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i153;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i161;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i166;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i241;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i35;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i26;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i112;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i146;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i147;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i145;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i204;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i50;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i149;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i148;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i224;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i242;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i223;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i244;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i52;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i51;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i100;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i152;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i101;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i151;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i186;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i238;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i194;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i162;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i165;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i246;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i72;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i157;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i198;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i159;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i199;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i158;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i229;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i239;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i191;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i195;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i208;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i213;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i225;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i167;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i250;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i71;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i96;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i120;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i164;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i121;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i97;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i163;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i119;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i184;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i187;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i220;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i168;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i124;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i221;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i81;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i82;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i170;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i80;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i102;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i169;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i79;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i190;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i196;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i227;

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
    gh.factory<_i12.DeleteCachedAudioUseCase>(
        () => _i12.DeleteCachedAudioUseCase(gh<_i13.AudioStorageRepository>()));
    await gh.factoryAsync<_i14.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.lazySingleton<_i15.DirectoryService>(() => _i16.DirectoryServiceImpl());
    gh.singleton<_i17.DynamicLinkService>(() => _i17.DynamicLinkService());
    gh.factory<_i18.ExampleComplexBloc>(() => _i18.ExampleComplexBloc());
    gh.factory<_i18.ExampleConditionalBloc>(
        () => _i18.ExampleConditionalBloc());
    gh.factory<_i18.ExampleNavigationCubit>(
        () => _i18.ExampleNavigationCubit());
    gh.factory<_i18.ExampleSimpleBloc>(() => _i18.ExampleSimpleBloc());
    gh.factory<_i18.ExampleUserProfileBloc>(
        () => _i18.ExampleUserProfileBloc());
    gh.lazySingleton<_i19.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i20.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i21.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i22.GetCachedTrackPathUseCase>(() =>
        _i22.GetCachedTrackPathUseCase(gh<_i13.AudioStorageRepository>()));
    gh.lazySingleton<_i23.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i24.IncrementalSyncService<_i25.Notification>>(
        () => _i26.NotificationIncrementalSyncService());
    gh.factory<_i27.InitializeAudioPlayerUseCase>(() =>
        _i27.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i28.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i29.InvitationRemoteDataSource>(() =>
        _i29.FirestoreInvitationRemoteDataSource(gh<_i20.FirebaseFirestore>()));
    await gh.factoryAsync<_i30.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i31.MagicLinkLocalDataSource>(
        () => _i31.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i32.MagicLinkRemoteDataSource>(
        () => _i32.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i20.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i33.MagicLinkRepository>(() =>
        _i34.MagicLinkRepositoryImp(gh<_i32.MagicLinkRemoteDataSource>()));
    gh.factory<_i35.NavigationCubit>(() => _i35.NavigationCubit());
    gh.lazySingleton<_i36.NetworkStateManager>(() => _i36.NetworkStateManager(
          gh<_i28.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.lazySingleton<_i37.NotificationLocalDataSource>(
        () => _i37.IsarNotificationLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i38.NotificationRemoteDataSource>(() =>
        _i38.FirestoreNotificationRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i39.NotificationRepository>(
        () => _i40.NotificationRepositoryImpl(
              localDataSource: gh<_i37.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i38.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i41.NotificationService>(
        () => _i41.NotificationService(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i42.ObserveNotificationsUseCase>(() =>
        _i42.ObserveNotificationsUseCase(gh<_i39.NotificationRepository>()));
    gh.factory<_i43.OperationExecutorFactory>(
        () => _i43.OperationExecutorFactory());
    gh.factory<_i44.PauseAudioUseCase>(() => _i44.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i45.PendingOperationsLocalDataSource>(
        () => _i45.IsarPendingOperationsLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i46.PendingOperationsRepository>(() =>
        _i46.PendingOperationsRepositoryImpl(
            gh<_i45.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i47.PlaybackPersistenceRepository>(
        () => _i48.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i49.PlaylistLocalDataSource>(
        () => _i49.PlaylistLocalDataSourceImpl(gh<_i30.Isar>()));
    gh.lazySingleton<_i50.PlaylistRemoteDataSource>(
        () => _i50.PlaylistRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i51.ProjectRemoteDataSource>(() =>
        _i51.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i52.ProjectsLocalDataSource>(
        () => _i52.ProjectsLocalDataSourceImpl(gh<_i30.Isar>()));
    gh.lazySingleton<_i53.RecordingService>(
        () => _i54.PlatformRecordingService());
    gh.factory<_i55.RemoveTrackCacheUseCase>(
        () => _i55.RemoveTrackCacheUseCase(gh<_i13.AudioStorageRepository>()));
    gh.lazySingleton<_i56.ResendMagicLinkUseCase>(
        () => _i56.ResendMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.factory<_i57.ResumeAudioUseCase>(() => _i57.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i58.SavePlaybackStateUseCase>(
        () => _i58.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i47.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i59.SeekAudioUseCase>(() =>
        _i59.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.SetPlaybackSpeedUseCase>(() => _i60.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i61.SetVolumeUseCase>(() =>
        _i61.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i62.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i63.SkipToNextUseCase>(() => _i63.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i64.SkipToPreviousUseCase>(() => _i64.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i65.StartRecordingUseCase>(
        () => _i65.StartRecordingUseCase(gh<_i53.RecordingService>()));
    gh.factory<_i66.StopAudioUseCase>(() =>
        _i66.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i67.StopRecordingUseCase>(
        () => _i67.StopRecordingUseCase(gh<_i53.RecordingService>()));
    gh.lazySingleton<_i68.SyncCoordinator>(
        () => _i68.SyncCoordinator(gh<_i62.SharedPreferences>()));
    gh.factory<_i69.ToggleRepeatModeUseCase>(() => _i69.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i70.ToggleShuffleUseCase>(() => _i70.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i71.TrackDetailCubit>(() => _i71.TrackDetailCubit());
    gh.lazySingleton<_i72.TrackVersionLocalDataSource>(
        () => _i72.IsarTrackVersionLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i73.UserProfileLocalDataSource>(
        () => _i73.IsarUserProfileLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i74.UserProfileRemoteDataSource>(
        () => _i74.UserProfileRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i21.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i75.ValidateMagicLinkUseCase>(
        () => _i75.ValidateMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.factory<_i76.WatchCachedAudiosUseCase>(
        () => _i76.WatchCachedAudiosUseCase(gh<_i13.AudioStorageRepository>()));
    gh.factory<_i77.WatchStorageUsageUseCase>(
        () => _i77.WatchStorageUsageUseCase(gh<_i13.AudioStorageRepository>()));
    gh.factory<_i78.WatchTrackCacheStatusUseCase>(() =>
        _i78.WatchTrackCacheStatusUseCase(gh<_i13.AudioStorageRepository>()));
    gh.factory<_i79.WaveformGeneratorService>(() =>
        _i80.JustWaveformGeneratorService(cacheDir: gh<_i14.Directory>()));
    gh.factory<_i81.WaveformLocalDataSource>(
        () => _i81.WaveformLocalDataSourceImpl(isar: gh<_i30.Isar>()));
    gh.lazySingleton<_i82.WaveformRemoteDataSource>(() =>
        _i82.FirebaseStorageWaveformRemoteDataSource(
            gh<_i21.FirebaseStorage>()));
    gh.lazySingleton<_i83.AppleAuthService>(
        () => _i83.AppleAuthService(gh<_i19.FirebaseAuth>()));
    gh.lazySingleton<_i84.AudioCommentLocalDataSource>(
        () => _i84.IsarAudioCommentLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i85.AudioCommentRemoteDataSource>(() =>
        _i85.FirebaseAudioCommentRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i86.AudioTrackLocalDataSource>(
        () => _i86.IsarAudioTrackLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i87.AudioTrackRemoteDataSource>(() =>
        _i87.AudioTrackRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i88.CacheStorageLocalDataSource>(
        () => _i88.CacheStorageLocalDataSourceImpl(gh<_i30.Isar>()));
    gh.factory<_i89.CancelRecordingUseCase>(
        () => _i89.CancelRecordingUseCase(gh<_i53.RecordingService>()));
    gh.lazySingleton<_i90.ConsumeMagicLinkUseCase>(
        () => _i90.ConsumeMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.factory<_i91.CreateNotificationUseCase>(() =>
        _i91.CreateNotificationUseCase(gh<_i39.NotificationRepository>()));
    gh.factory<_i92.DeleteNotificationUseCase>(() =>
        _i92.DeleteNotificationUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i93.GetMagicLinkStatusUseCase>(
        () => _i93.GetMagicLinkStatusUseCase(gh<_i33.MagicLinkRepository>()));
    gh.lazySingleton<_i94.GetUnreadNotificationsCountUseCase>(() =>
        _i94.GetUnreadNotificationsCountUseCase(
            gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i95.GoogleAuthService>(() => _i95.GoogleAuthService(
          gh<_i23.GoogleSignIn>(),
          gh<_i19.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i96.UserProfileDTO>>(
        () => _i97.UserProfileIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i98.AudioTrackDTO>>(
        () => _i99.AudioTrackIncrementalSyncService(
              gh<_i87.AudioTrackRemoteDataSource>(),
              gh<_i86.AudioTrackLocalDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i100.ProjectDTO>>(
        () => _i101.ProjectIncrementalSyncService(
              gh<_i51.ProjectRemoteDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<dynamic>>(
        () => _i102.WaveformIncrementalSyncService(
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i81.WaveformLocalDataSource>(),
              gh<_i82.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i103.AudioCommentDTO>>(
        () => _i104.AudioCommentIncrementalSyncService(
              gh<_i85.AudioCommentRemoteDataSource>(),
              gh<_i84.AudioCommentLocalDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i105.InvitationLocalDataSource>(
        () => _i105.IsarInvitationLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i106.InvitationRepository>(
        () => _i107.InvitationRepositoryImpl(
              localDataSource: gh<_i105.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i29.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
            ));
    gh.factory<_i108.MarkAsUnreadUseCase>(
        () => _i108.MarkAsUnreadUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i109.MarkNotificationAsReadUseCase>(() =>
        _i109.MarkNotificationAsReadUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i110.ObservePendingInvitationsUseCase>(() =>
        _i110.ObservePendingInvitationsUseCase(
            gh<_i106.InvitationRepository>()));
    gh.lazySingleton<_i111.ObserveSentInvitationsUseCase>(() =>
        _i111.ObserveSentInvitationsUseCase(gh<_i106.InvitationRepository>()));
    gh.lazySingleton<_i112.OnboardingStateLocalDataSource>(() =>
        _i112.OnboardingStateLocalDataSourceImpl(gh<_i62.SharedPreferences>()));
    gh.lazySingleton<_i113.PendingOperationsManager>(
        () => _i113.PendingOperationsManager(
              gh<_i46.PendingOperationsRepository>(),
              gh<_i36.NetworkStateManager>(),
              gh<_i43.OperationExecutorFactory>(),
            ));
    gh.factory<_i114.PlaylistOperationExecutor>(() =>
        _i114.PlaylistOperationExecutor(gh<_i50.PlaylistRemoteDataSource>()));
    gh.factory<_i115.ProjectOperationExecutor>(() =>
        _i115.ProjectOperationExecutor(gh<_i51.ProjectRemoteDataSource>()));
    gh.factory<_i116.RecordingBloc>(() => _i116.RecordingBloc(
          gh<_i65.StartRecordingUseCase>(),
          gh<_i67.StopRecordingUseCase>(),
          gh<_i89.CancelRecordingUseCase>(),
          gh<_i53.RecordingService>(),
        ));
    gh.lazySingleton<_i117.SessionStorage>(
        () => _i117.SessionStorageImpl(prefs: gh<_i62.SharedPreferences>()));
    gh.factory<_i118.SyncStatusProvider>(() => _i118.SyncStatusProvider(
          syncCoordinator: gh<_i68.SyncCoordinator>(),
          pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i119.UserProfileCacheRepository>(
        () => _i120.UserProfileCacheRepositoryImpl(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i36.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i121.UserProfileCollaboratorIncrementalSyncService>(
        () => _i121.UserProfileCollaboratorIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i122.UserProfileOperationExecutor>(() =>
        _i122.UserProfileOperationExecutor(
            gh<_i74.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i123.WatchTrackUploadStatusUseCase>(() =>
        _i123.WatchTrackUploadStatusUseCase(
            gh<_i113.PendingOperationsManager>()));
    gh.lazySingleton<_i124.WatchUserProfilesUseCase>(() =>
        _i124.WatchUserProfilesUseCase(gh<_i119.UserProfileCacheRepository>()));
    gh.factory<_i125.WaveformOperationExecutor>(() =>
        _i125.WaveformOperationExecutor(gh<_i82.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i126.AudioFileRepository>(() => _i127.UnifiedAudioService(
          gh<_i21.FirebaseStorage>(),
          gh<_i15.DirectoryService>(),
          gh<_i88.CacheStorageLocalDataSource>(),
          httpClient: gh<_i9.Client>(),
        ));
    gh.factory<_i128.AudioTrackOperationExecutor>(
        () => _i128.AudioTrackOperationExecutor(
              gh<_i87.AudioTrackRemoteDataSource>(),
              gh<_i86.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i129.AuthRemoteDataSource>(
        () => _i129.AuthRemoteDataSourceImpl(
              gh<_i19.FirebaseAuth>(),
              gh<_i95.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i130.AuthRepository>(() => _i131.AuthRepositoryImpl(
          remote: gh<_i129.AuthRemoteDataSource>(),
          sessionStorage: gh<_i117.SessionStorage>(),
          networkStateManager: gh<_i36.NetworkStateManager>(),
          googleAuthService: gh<_i95.GoogleAuthService>(),
          appleAuthService: gh<_i83.AppleAuthService>(),
        ));
    gh.lazySingleton<_i132.BackgroundSyncCoordinator>(
        () => _i133.BackgroundSyncCoordinatorImpl(
              gh<_i36.NetworkStateManager>(),
              gh<_i68.SyncCoordinator>(),
              gh<_i113.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i134.CacheManagementLocalDataSource>(() =>
        _i134.CacheManagementLocalDataSourceImpl(
            local: gh<_i88.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i135.CancelInvitationUseCase>(
        () => _i135.CancelInvitationUseCase(gh<_i106.InvitationRepository>()));
    gh.factory<_i136.CheckAuthenticationStatusUseCase>(() =>
        _i136.CheckAuthenticationStatusUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i137.CurrentUserService>(
        () => _i137.CurrentUserService(gh<_i117.SessionStorage>()));
    gh.lazySingleton<_i138.GenerateMagicLinkUseCase>(
        () => _i138.GenerateMagicLinkUseCase(
              gh<_i33.MagicLinkRepository>(),
              gh<_i130.AuthRepository>(),
            ));
    gh.lazySingleton<_i139.GetAuthStateUseCase>(
        () => _i139.GetAuthStateUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i140.GetCurrentUserUseCase>(
        () => _i140.GetCurrentUserUseCase(gh<_i130.AuthRepository>()));
    gh.lazySingleton<_i141.GetPendingInvitationsCountUseCase>(() =>
        _i141.GetPendingInvitationsCountUseCase(
            gh<_i106.InvitationRepository>()));
    gh.factory<_i142.MarkAllNotificationsAsReadUseCase>(
        () => _i142.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i39.NotificationRepository>(),
              currentUserService: gh<_i137.CurrentUserService>(),
            ));
    gh.factory<_i143.NotificationActorBloc>(() => _i143.NotificationActorBloc(
          createNotificationUseCase: gh<_i91.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i109.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i108.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i142.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i92.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i144.NotificationWatcherBloc>(
        () => _i144.NotificationWatcherBloc(
              notificationRepository: gh<_i39.NotificationRepository>(),
              currentUserService: gh<_i137.CurrentUserService>(),
            ));
    gh.lazySingleton<_i145.OnboardingRepository>(() =>
        _i146.OnboardingRepositoryImpl(
            gh<_i112.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i147.OnboardingUseCase>(
        () => _i147.OnboardingUseCase(gh<_i145.OnboardingRepository>()));
    gh.lazySingleton<_i148.PlaylistRepository>(
        () => _i149.PlaylistRepositoryImpl(
              localDataSource: gh<_i49.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
            ));
    gh.factory<_i150.ProjectInvitationWatcherBloc>(
        () => _i150.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i106.InvitationRepository>(),
              currentUserService: gh<_i137.CurrentUserService>(),
            ));
    gh.lazySingleton<_i151.ProjectsRepository>(
        () => _i152.ProjectsRepositoryImpl(
              localDataSource: gh<_i52.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i153.RemoveCollaboratorUseCase>(
        () => _i153.RemoveCollaboratorUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i154.SignOutUseCase>(
        () => _i154.SignOutUseCase(gh<_i130.AuthRepository>()));
    gh.lazySingleton<_i155.SignUpUseCase>(
        () => _i155.SignUpUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i156.TrackUploadStatusCubit>(() => _i156.TrackUploadStatusCubit(
        gh<_i123.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i157.TrackVersionRemoteDataSource>(
        () => _i157.TrackVersionRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i126.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i158.TrackVersionRepository>(
        () => _i159.TrackVersionRepositoryImpl(
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i113.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i160.TriggerUpstreamSyncUseCase>(() =>
        _i160.TriggerUpstreamSyncUseCase(
            gh<_i132.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i161.UpdateCollaboratorRoleUseCase>(
        () => _i161.UpdateCollaboratorRoleUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i162.UpdateProjectUseCase>(
        () => _i162.UpdateProjectUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i163.UserProfileRepository>(
        () => _i164.UserProfileRepositoryImpl(
              localDataSource: gh<_i73.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i74.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
              firestore: gh<_i20.FirebaseFirestore>(),
              sessionStorage: gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i165.WatchAllProjectsUseCase>(
        () => _i165.WatchAllProjectsUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i166.WatchCollaboratorsBundleUseCase>(
        () => _i166.WatchCollaboratorsBundleUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i124.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i167.WatchTrackVersionsUseCase>(() =>
        _i167.WatchTrackVersionsUseCase(gh<_i158.TrackVersionRepository>()));
    gh.lazySingleton<_i168.WatchUserProfileUseCase>(
        () => _i168.WatchUserProfileUseCase(
              gh<_i163.UserProfileRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.factory<_i169.WaveformRepository>(() => _i170.WaveformRepositoryImpl(
          localDataSource: gh<_i81.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i82.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i171.AcceptInvitationUseCase>(
        () => _i171.AcceptInvitationUseCase(
              invitationRepository: gh<_i106.InvitationRepository>(),
              projectRepository: gh<_i151.ProjectsRepository>(),
              userProfileRepository: gh<_i163.UserProfileRepository>(),
              notificationService: gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i172.AddCollaboratorToProjectUseCase>(
        () => _i172.AddCollaboratorToProjectUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i173.AppleSignInUseCase>(
        () => _i173.AppleSignInUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i174.AudioCommentStorageCoordinator>(
        () => _i174.AudioCommentStorageCoordinator(
              gh<_i126.AudioFileRepository>(),
              gh<_i13.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i175.AudioDownloadRepository>(() =>
        _i176.AudioDownloadRepositoryImpl(
            audioFileRepository: gh<_i126.AudioFileRepository>()));
    gh.factory<_i177.AudioSourceResolver>(() => _i178.AudioSourceResolverImpl(
          gh<_i13.AudioStorageRepository>(),
          gh<_i175.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i179.AudioTrackRepository>(
        () => _i180.AudioTrackRepositoryImpl(
              gh<_i86.AudioTrackLocalDataSource>(),
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i113.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i181.CacheMaintenanceService>(() =>
        _i182.CacheMaintenanceServiceImpl(
            gh<_i134.CacheManagementLocalDataSource>()));
    gh.factory<_i183.CacheTrackUseCase>(() => _i183.CacheTrackUseCase(
          gh<_i175.AudioDownloadRepository>(),
          gh<_i13.AudioStorageRepository>(),
        ));
    gh.factory<_i184.CheckProfileCompletenessUseCase>(() =>
        _i184.CheckProfileCompletenessUseCase(
            gh<_i163.UserProfileRepository>()));
    gh.factory<_i185.CleanupCacheUseCase>(
        () => _i185.CleanupCacheUseCase(gh<_i181.CacheMaintenanceService>()));
    gh.lazySingleton<_i186.CreateProjectUseCase>(
        () => _i186.CreateProjectUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.factory<_i187.CreateUserProfileUseCase>(
        () => _i187.CreateUserProfileUseCase(
              gh<_i163.UserProfileRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i188.DeclineInvitationUseCase>(
        () => _i188.DeclineInvitationUseCase(
              invitationRepository: gh<_i106.InvitationRepository>(),
              projectRepository: gh<_i151.ProjectsRepository>(),
              userProfileRepository: gh<_i163.UserProfileRepository>(),
              notificationService: gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i189.FindUserByEmailUseCase>(
        () => _i189.FindUserByEmailUseCase(gh<_i163.UserProfileRepository>()));
    gh.factory<_i190.GenerateAndStoreWaveform>(
        () => _i190.GenerateAndStoreWaveform(
              gh<_i169.WaveformRepository>(),
              gh<_i79.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i191.GetActiveVersionUseCase>(() =>
        _i191.GetActiveVersionUseCase(gh<_i158.TrackVersionRepository>()));
    gh.factory<_i192.GetCacheStorageStatsUseCase>(() =>
        _i192.GetCacheStorageStatsUseCase(gh<_i181.CacheMaintenanceService>()));
    gh.factory<_i193.GetCachedAudioCommentUseCase>(() =>
        _i193.GetCachedAudioCommentUseCase(
            gh<_i174.AudioCommentStorageCoordinator>()));
    gh.lazySingleton<_i194.GetProjectByIdUseCase>(
        () => _i194.GetProjectByIdUseCase(gh<_i151.ProjectsRepository>()));
    gh.lazySingleton<_i195.GetVersionByIdUseCase>(
        () => _i195.GetVersionByIdUseCase(gh<_i158.TrackVersionRepository>()));
    gh.factory<_i196.GetWaveformByVersion>(
        () => _i196.GetWaveformByVersion(gh<_i169.WaveformRepository>()));
    gh.lazySingleton<_i197.GoogleSignInUseCase>(() => _i197.GoogleSignInUseCase(
          gh<_i130.AuthRepository>(),
          gh<_i163.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i198.TrackVersionDTO>>(
        () => _i199.TrackVersionIncrementalSyncService(
              gh<_i157.TrackVersionRemoteDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i86.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i200.JoinProjectWithIdUseCase>(
        () => _i200.JoinProjectWithIdUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.lazySingleton<_i201.LeaveProjectUseCase>(() => _i201.LeaveProjectUseCase(
          gh<_i151.ProjectsRepository>(),
          gh<_i117.SessionStorage>(),
        ));
    gh.factory<_i202.LoadTrackContextUseCase>(
        () => _i202.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i179.AudioTrackRepository>(),
              trackVersionRepository: gh<_i158.TrackVersionRepository>(),
              userProfileRepository: gh<_i163.UserProfileRepository>(),
              projectsRepository: gh<_i151.ProjectsRepository>(),
            ));
    gh.factory<_i203.MagicLinkBloc>(() => _i203.MagicLinkBloc(
          generateMagicLink: gh<_i138.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i75.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i90.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i56.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i93.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i200.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i130.AuthRepository>(),
        ));
    gh.factory<_i204.OnboardingBloc>(() => _i204.OnboardingBloc(
          onboardingUseCase: gh<_i147.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i140.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i205.PlayPlaylistUseCase>(() => _i205.PlayPlaylistUseCase(
          playlistRepository: gh<_i148.PlaylistRepository>(),
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          trackVersionRepository: gh<_i158.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i13.AudioStorageRepository>(),
        ));
    gh.factory<_i206.PlayVersionUseCase>(() => _i206.PlayVersionUseCase(
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          audioStorageRepository: gh<_i13.AudioStorageRepository>(),
          trackVersionRepository: gh<_i158.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i207.ProjectTrackService>(
        () => _i207.ProjectTrackService(gh<_i179.AudioTrackRepository>()));
    gh.lazySingleton<_i208.RenameTrackVersionUseCase>(() =>
        _i208.RenameTrackVersionUseCase(gh<_i158.TrackVersionRepository>()));
    gh.factory<_i209.ResolveTrackVersionUseCase>(
        () => _i209.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i179.AudioTrackRepository>(),
              trackVersionRepository: gh<_i158.TrackVersionRepository>(),
            ));
    gh.factory<_i210.RestorePlaybackStateUseCase>(
        () => _i210.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i47.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i179.AudioTrackRepository>(),
              audioStorageRepository: gh<_i13.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i211.SendInvitationUseCase>(
        () => _i211.SendInvitationUseCase(
              invitationRepository: gh<_i106.InvitationRepository>(),
              notificationService: gh<_i41.NotificationService>(),
              findUserByEmail: gh<_i189.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i33.MagicLinkRepository>(),
              currentUserService: gh<_i137.CurrentUserService>(),
            ));
    gh.factory<_i212.SessionService>(() => _i212.SessionService(
          checkAuthUseCase: gh<_i136.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i140.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i147.OnboardingUseCase>(),
          profileUseCase: gh<_i184.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i213.SetActiveTrackVersionUseCase>(() =>
        _i213.SetActiveTrackVersionUseCase(gh<_i179.AudioTrackRepository>()));
    gh.lazySingleton<_i214.SignInUseCase>(() => _i214.SignInUseCase(
          gh<_i130.AuthRepository>(),
          gh<_i163.UserProfileRepository>(),
        ));
    gh.factory<_i215.TrackCacheBloc>(() => _i215.TrackCacheBloc(
          cacheTrackUseCase: gh<_i183.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase: gh<_i78.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i55.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i22.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i216.TrackVersionOperationExecutor>(
        () => _i216.TrackVersionOperationExecutor(
              gh<_i157.TrackVersionRemoteDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i217.TriggerDownstreamSyncUseCase>(
        () => _i217.TriggerDownstreamSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i212.SessionService>(),
            ));
    gh.lazySingleton<_i218.TriggerForegroundSyncUseCase>(
        () => _i218.TriggerForegroundSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i212.SessionService>(),
            ));
    gh.lazySingleton<_i219.TriggerStartupSyncUseCase>(
        () => _i219.TriggerStartupSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i212.SessionService>(),
            ));
    gh.factory<_i220.UpdateUserProfileUseCase>(
        () => _i220.UpdateUserProfileUseCase(
              gh<_i163.UserProfileRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.factory<_i221.UserProfileBloc>(() => _i221.UserProfileBloc(
          updateUserProfileUseCase: gh<_i220.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i187.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i168.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i184.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i140.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i222.WatchCachedTrackBundlesUseCase>(
        () => _i222.WatchCachedTrackBundlesUseCase(
              gh<_i181.CacheMaintenanceService>(),
              gh<_i179.AudioTrackRepository>(),
              gh<_i163.UserProfileRepository>(),
              gh<_i151.ProjectsRepository>(),
              gh<_i158.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i223.WatchProjectDetailUseCase>(
        () => _i223.WatchProjectDetailUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i179.AudioTrackRepository>(),
              gh<_i119.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i224.WatchProjectPlaylistUseCase>(
        () => _i224.WatchProjectPlaylistUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i158.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i225.WatchTrackVersionsBundleUseCase>(
        () => _i225.WatchTrackVersionsBundleUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i158.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i226.WatchTracksByProjectIdUseCase>(() =>
        _i226.WatchTracksByProjectIdUseCase(gh<_i179.AudioTrackRepository>()));
    gh.factory<_i227.WaveformBloc>(() => _i227.WaveformBloc(
          waveformRepository: gh<_i169.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i228.AddCollaboratorByEmailUseCase>(
        () => _i228.AddCollaboratorByEmailUseCase(
              gh<_i189.FindUserByEmailUseCase>(),
              gh<_i172.AddCollaboratorToProjectUseCase>(),
              gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i229.AddTrackVersionUseCase>(
        () => _i229.AddTrackVersionUseCase(
              gh<_i117.SessionStorage>(),
              gh<_i158.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i13.AudioStorageRepository>(),
              gh<_i190.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i230.AudioCommentOperationExecutor>(
        () => _i230.AudioCommentOperationExecutor(
              gh<_i85.AudioCommentRemoteDataSource>(),
              gh<_i174.AudioCommentStorageCoordinator>(),
            ));
    gh.lazySingleton<_i231.AudioCommentRepository>(
        () => _i232.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i85.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i84.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i113.PendingOperationsManager>(),
              trackVersionRepository: gh<_i158.TrackVersionRepository>(),
              storageCoordinator: gh<_i174.AudioCommentStorageCoordinator>(),
            ));
    gh.factory<_i233.AudioContextBloc>(() => _i233.AudioContextBloc(
        loadTrackContextUseCase: gh<_i202.LoadTrackContextUseCase>()));
    gh.factory<_i234.AudioPlayerService>(() => _i234.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i27.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i206.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i205.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i209.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i44.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i57.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i66.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i63.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i64.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i59.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i70.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i69.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i61.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i60.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i58.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i210.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i235.AuthBloc>(() => _i235.AuthBloc(
          signIn: gh<_i214.SignInUseCase>(),
          signUp: gh<_i155.SignUpUseCase>(),
          googleSignIn: gh<_i197.GoogleSignInUseCase>(),
          appleSignIn: gh<_i173.AppleSignInUseCase>(),
          signOut: gh<_i154.SignOutUseCase>(),
        ));
    gh.factory<_i236.CacheManagementBloc>(() => _i236.CacheManagementBloc(
          deleteOne: gh<_i12.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i77.WatchStorageUsageUseCase>(),
          getStats: gh<_i192.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i185.CleanupCacheUseCase>(),
          watchBundles: gh<_i222.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i237.DeleteAudioTrack>(() => _i237.DeleteAudioTrack(
          gh<_i117.SessionStorage>(),
          gh<_i151.ProjectsRepository>(),
          gh<_i207.ProjectTrackService>(),
          gh<_i158.TrackVersionRepository>(),
          gh<_i169.WaveformRepository>(),
          gh<_i13.AudioStorageRepository>(),
          gh<_i231.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i238.DeleteProjectUseCase>(
        () => _i238.DeleteProjectUseCase(
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
              gh<_i207.ProjectTrackService>(),
              gh<_i237.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i239.DeleteTrackVersionUseCase>(
        () => _i239.DeleteTrackVersionUseCase(
              gh<_i158.TrackVersionRepository>(),
              gh<_i169.WaveformRepository>(),
              gh<_i231.AudioCommentRepository>(),
              gh<_i13.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i240.EditAudioTrackUseCase>(
        () => _i240.EditAudioTrackUseCase(
              gh<_i207.ProjectTrackService>(),
              gh<_i151.ProjectsRepository>(),
            ));
    gh.factory<_i241.ManageCollaboratorsBloc>(
        () => _i241.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i153.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i161.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i201.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i228.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i166.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i242.PlaylistBloc>(
        () => _i242.PlaylistBloc(gh<_i224.WatchProjectPlaylistUseCase>()));
    gh.lazySingleton<_i243.ProjectCommentService>(
        () => _i243.ProjectCommentService(gh<_i231.AudioCommentRepository>()));
    gh.factory<_i244.ProjectDetailBloc>(() => _i244.ProjectDetailBloc(
        watchProjectDetail: gh<_i223.WatchProjectDetailUseCase>()));
    gh.factory<_i245.ProjectInvitationActorBloc>(
        () => _i245.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i211.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i171.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i188.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i135.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i246.ProjectsBloc>(() => _i246.ProjectsBloc(
          createProject: gh<_i186.CreateProjectUseCase>(),
          updateProject: gh<_i162.UpdateProjectUseCase>(),
          deleteProject: gh<_i238.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i165.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i247.SessionCleanupService>(() => _i247.SessionCleanupService(
          userProfileRepository: gh<_i163.UserProfileRepository>(),
          projectsRepository: gh<_i151.ProjectsRepository>(),
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          audioCommentRepository: gh<_i231.AudioCommentRepository>(),
          invitationRepository: gh<_i106.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i47.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i117.SessionStorage>(),
          pendingOperationsRepository: gh<_i46.PendingOperationsRepository>(),
          waveformRepository: gh<_i169.WaveformRepository>(),
          trackVersionRepository: gh<_i158.TrackVersionRepository>(),
          syncCoordinator: gh<_i68.SyncCoordinator>(),
        ));
    gh.factory<_i248.SyncBloc>(() => _i248.SyncBloc(
          gh<_i219.TriggerStartupSyncUseCase>(),
          gh<_i160.TriggerUpstreamSyncUseCase>(),
          gh<_i218.TriggerForegroundSyncUseCase>(),
          gh<_i217.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i249.SyncStatusCubit>(() => _i249.SyncStatusCubit(
          gh<_i118.SyncStatusProvider>(),
          gh<_i113.PendingOperationsManager>(),
          gh<_i160.TriggerUpstreamSyncUseCase>(),
          gh<_i218.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i250.TrackVersionsBloc>(() => _i250.TrackVersionsBloc(
          gh<_i225.WatchTrackVersionsBundleUseCase>(),
          gh<_i213.SetActiveTrackVersionUseCase>(),
          gh<_i229.AddTrackVersionUseCase>(),
          gh<_i208.RenameTrackVersionUseCase>(),
          gh<_i239.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i251.UploadAudioTrackUseCase>(
        () => _i251.UploadAudioTrackUseCase(
              gh<_i207.ProjectTrackService>(),
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
              gh<_i229.AddTrackVersionUseCase>(),
              gh<_i179.AudioTrackRepository>(),
            ));
    gh.lazySingleton<_i252.WatchAudioCommentsBundleUseCase>(
        () => _i252.WatchAudioCommentsBundleUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i231.AudioCommentRepository>(),
              gh<_i119.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i253.AddAudioCommentUseCase>(
        () => _i253.AddAudioCommentUseCase(
              gh<_i243.ProjectCommentService>(),
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.factory<_i254.AppFlowBloc>(() => _i254.AppFlowBloc(
          sessionService: gh<_i212.SessionService>(),
          getAuthStateUseCase: gh<_i139.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i247.SessionCleanupService>(),
        ));
    gh.factory<_i255.AudioPlayerBloc>(() => _i255.AudioPlayerBloc(
        audioPlayerService: gh<_i234.AudioPlayerService>()));
    gh.factory<_i256.AudioTrackBloc>(() => _i256.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i226.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i237.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i251.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i240.EditAudioTrackUseCase>(),
        ));
    gh.lazySingleton<_i257.DeleteAudioCommentUseCase>(
        () => _i257.DeleteAudioCommentUseCase(
              gh<_i243.ProjectCommentService>(),
              gh<_i151.ProjectsRepository>(),
              gh<_i117.SessionStorage>(),
            ));
    gh.factory<_i258.AudioCommentBloc>(() => _i258.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i253.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i257.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i252.WatchAudioCommentsBundleUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i259.AppModule {}
