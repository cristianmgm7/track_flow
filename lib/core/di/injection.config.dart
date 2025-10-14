// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i14;

import 'package:cloud_firestore/cloud_firestore.dart' as _i20;
import 'package:connectivity_plus/connectivity_plus.dart' as _i12;
import 'package:firebase_auth/firebase_auth.dart' as _i19;
import 'package:firebase_storage/firebase_storage.dart' as _i21;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i22;
import 'package:http/http.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i27;
import 'package:isar/isar.dart' as _i29;
import 'package:shared_preferences/shared_preferences.dart' as _i60;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i118;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i18;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i225;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i226;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i142;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i146;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i149;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i246;
import 'package:trackflow/core/audio/data/unified_audio_service.dart' as _i130;
import 'package:trackflow/core/audio/domain/audio_file_repository.dart'
    as _i129;
import 'package:trackflow/core/di/app_module.dart' as _i269;
import 'package:trackflow/core/infrastructure/domain/directory_service.dart'
    as _i15;
import 'package:trackflow/core/infrastructure/services/directory_service_impl.dart'
    as _i16;
import 'package:trackflow/core/network/network_state_manager.dart' as _i35;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i36;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i37;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i39;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i24;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i38;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i40;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i91;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i93;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i96;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i151;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i109;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i110;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i41;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i152;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i153;
import 'package:trackflow/core/services/deep_link_service.dart' as _i13;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i17;
import 'package:trackflow/core/session/current_user_service.dart' as _i143;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i44;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i45;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i138;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i187;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i133;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i42;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i230;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i124;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i128;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i137;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i23;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i114;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i66;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i119;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i231;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i232;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i233;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i170;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i261;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i262;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i87;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i132;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i131;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i140;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i148;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i163;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i179;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i176;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i229;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i83;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i84;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i104;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i189;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i105;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i188;
import 'package:trackflow/features/audio_comment/domain/services/comment_audio_playback_service.dart'
    as _i10;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i219;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i243;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i251;
import 'package:trackflow/features/audio_comment/domain/usecases/get_cached_audio_comment_usecase.dart'
    as _i147;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i236;
import 'package:trackflow/features/audio_comment/infrastructure/services/comment_audio_playback_service_impl.dart'
    as _i11;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i266;
import 'package:trackflow/features/audio_comment/presentation/cubit/comment_audio_cubit.dart'
    as _i89;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i214;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i247;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i248;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i190;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i26;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i43;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i217;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i218;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i222;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i223;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i64;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i68;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i47;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i191;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i267;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i52;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i88;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i65;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i53;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i117;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i85;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i86;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i98;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i193;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i99;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i192;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i220;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i252;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i254;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i264;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i241;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i125;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i268;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i166;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i134;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i136;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i82;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i97;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i135;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i186;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i209;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i228;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i164;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i165;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i249;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i139;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i195;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i194;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i197;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i144;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i205;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i237;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i178;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i250;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i106;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i28;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i108;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i107;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i184;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i141;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i200;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i150;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i111;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i112;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i224;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i259;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i159;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i30;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i31;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i33;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i32;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i90;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i145;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i95;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i54;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i72;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i215;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i244;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i185;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i202;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i212;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i213;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i162;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i171;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i177;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i255;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i34;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i25;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i113;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i155;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i156;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i154;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i216;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i48;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i49;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i157;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i239;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i257;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i238;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i258;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i51;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i50;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i100;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i161;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i101;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i160;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i198;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i253;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i206;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i172;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i175;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i260;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i69;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i167;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i210;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i169;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i211;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i168;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i245;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i201;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i204;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i207;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i221;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i227;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i240;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i180;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i263;
import 'package:trackflow/features/track_version/presentation/cubit/version_selector_cubit.dart'
    as _i73;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i70;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i71;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i102;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i122;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i174;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i123;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i103;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i173;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i121;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i196;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i199;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i234;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i181;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i126;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i235;
import 'package:trackflow/features/voice_memos/data/datasources/voice_memo_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/voice_memos/data/repositories/voice_memo_repository_impl.dart'
    as _i76;
import 'package:trackflow/features/voice_memos/domain/repositories/voice_memo_repository.dart'
    as _i75;
import 'package:trackflow/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart'
    as _i92;
import 'package:trackflow/features/voice_memos/domain/usecases/delete_voice_memo_usecase.dart'
    as _i94;
import 'package:trackflow/features/voice_memos/domain/usecases/play_voice_memo_usecase.dart'
    as _i256;
import 'package:trackflow/features/voice_memos/domain/usecases/update_voice_memo_usecase.dart'
    as _i120;
import 'package:trackflow/features/voice_memos/domain/usecases/watch_voice_memos_usecase.dart'
    as _i77;
import 'package:trackflow/features/voice_memos/presentation/bloc/voice_memo_bloc.dart'
    as _i265;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i80;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i81;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i183;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i79;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i127;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i182;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i78;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i203;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i208;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i242;

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
    gh.lazySingleton<_i10.CommentAudioPlaybackService>(
        () => _i11.CommentAudioPlaybackServiceImpl());
    gh.lazySingleton<_i7.ConflictResolutionServiceImpl<dynamic>>(
        () => _i7.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i12.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i13.DeepLinkService>(() => _i13.DeepLinkService());
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
    gh.lazySingleton<_i22.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i23.IncrementalSyncService<_i24.Notification>>(
        () => _i25.NotificationIncrementalSyncService());
    gh.factory<_i26.InitializeAudioPlayerUseCase>(() =>
        _i26.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i27.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i28.InvitationRemoteDataSource>(() =>
        _i28.FirestoreInvitationRemoteDataSource(gh<_i20.FirebaseFirestore>()));
    await gh.factoryAsync<_i29.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i30.MagicLinkLocalDataSource>(
        () => _i30.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i31.MagicLinkRemoteDataSource>(
        () => _i31.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i20.FirebaseFirestore>(),
              deepLinkService: gh<_i13.DeepLinkService>(),
            ));
    gh.factory<_i32.MagicLinkRepository>(() =>
        _i33.MagicLinkRepositoryImp(gh<_i31.MagicLinkRemoteDataSource>()));
    gh.factory<_i34.NavigationCubit>(() => _i34.NavigationCubit());
    gh.lazySingleton<_i35.NetworkStateManager>(() => _i35.NetworkStateManager(
          gh<_i27.InternetConnectionChecker>(),
          gh<_i12.Connectivity>(),
        ));
    gh.lazySingleton<_i36.NotificationLocalDataSource>(
        () => _i36.IsarNotificationLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i37.NotificationRemoteDataSource>(() =>
        _i37.FirestoreNotificationRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i38.NotificationRepository>(
        () => _i39.NotificationRepositoryImpl(
              localDataSource: gh<_i36.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i37.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i35.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i40.NotificationService>(
        () => _i40.NotificationService(gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i41.ObserveNotificationsUseCase>(() =>
        _i41.ObserveNotificationsUseCase(gh<_i38.NotificationRepository>()));
    gh.factory<_i42.OperationExecutorFactory>(
        () => _i42.OperationExecutorFactory());
    gh.factory<_i43.PauseAudioUseCase>(() => _i43.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i44.PendingOperationsLocalDataSource>(
        () => _i44.IsarPendingOperationsLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i45.PendingOperationsRepository>(() =>
        _i45.PendingOperationsRepositoryImpl(
            gh<_i44.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i46.PlaybackPersistenceRepository>(
        () => _i47.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i48.PlaylistLocalDataSource>(
        () => _i48.PlaylistLocalDataSourceImpl(gh<_i29.Isar>()));
    gh.lazySingleton<_i49.PlaylistRemoteDataSource>(
        () => _i49.PlaylistRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i50.ProjectRemoteDataSource>(() =>
        _i50.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i51.ProjectsLocalDataSource>(
        () => _i51.ProjectsLocalDataSourceImpl(gh<_i29.Isar>()));
    gh.lazySingleton<_i52.RecordingService>(
        () => _i53.PlatformRecordingService());
    gh.lazySingleton<_i54.ResendMagicLinkUseCase>(
        () => _i54.ResendMagicLinkUseCase(gh<_i32.MagicLinkRepository>()));
    gh.factory<_i55.ResumeAudioUseCase>(() => _i55.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i56.SavePlaybackStateUseCase>(
        () => _i56.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i46.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i57.SeekAudioUseCase>(() =>
        _i57.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i58.SetPlaybackSpeedUseCase>(() => _i58.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.SetVolumeUseCase>(() =>
        _i59.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i60.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i61.SkipToNextUseCase>(() => _i61.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i62.SkipToPreviousUseCase>(() => _i62.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i63.StartRecordingUseCase>(
        () => _i63.StartRecordingUseCase(gh<_i52.RecordingService>()));
    gh.factory<_i64.StopAudioUseCase>(() =>
        _i64.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i65.StopRecordingUseCase>(
        () => _i65.StopRecordingUseCase(gh<_i52.RecordingService>()));
    gh.lazySingleton<_i66.SyncCoordinator>(
        () => _i66.SyncCoordinator(gh<_i60.SharedPreferences>()));
    gh.factory<_i67.ToggleRepeatModeUseCase>(() => _i67.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i68.ToggleShuffleUseCase>(() => _i68.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i69.TrackVersionLocalDataSource>(
        () => _i69.IsarTrackVersionLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i70.UserProfileLocalDataSource>(
        () => _i70.IsarUserProfileLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i71.UserProfileRemoteDataSource>(
        () => _i71.UserProfileRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i21.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i72.ValidateMagicLinkUseCase>(
        () => _i72.ValidateMagicLinkUseCase(gh<_i32.MagicLinkRepository>()));
    gh.factory<_i73.VersionSelectorCubit>(() => _i73.VersionSelectorCubit());
    gh.lazySingleton<_i74.VoiceMemoLocalDataSource>(
        () => _i74.IsarVoiceMemoLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i75.VoiceMemoRepository>(() =>
        _i76.VoiceMemoRepositoryImpl(gh<_i74.VoiceMemoLocalDataSource>()));
    gh.lazySingleton<_i77.WatchVoiceMemosUseCase>(
        () => _i77.WatchVoiceMemosUseCase(gh<_i75.VoiceMemoRepository>()));
    gh.factory<_i78.WaveformGeneratorService>(() =>
        _i79.JustWaveformGeneratorService(cacheDir: gh<_i14.Directory>()));
    gh.factory<_i80.WaveformLocalDataSource>(
        () => _i80.WaveformLocalDataSourceImpl(isar: gh<_i29.Isar>()));
    gh.lazySingleton<_i81.WaveformRemoteDataSource>(() =>
        _i81.FirebaseStorageWaveformRemoteDataSource(
            gh<_i21.FirebaseStorage>()));
    gh.lazySingleton<_i82.AppleAuthService>(
        () => _i82.AppleAuthService(gh<_i19.FirebaseAuth>()));
    gh.lazySingleton<_i83.AudioCommentLocalDataSource>(
        () => _i83.IsarAudioCommentLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i84.AudioCommentRemoteDataSource>(() =>
        _i84.FirebaseAudioCommentRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i85.AudioTrackLocalDataSource>(
        () => _i85.IsarAudioTrackLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i86.AudioTrackRemoteDataSource>(() =>
        _i86.AudioTrackRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i87.CacheStorageLocalDataSource>(
        () => _i87.CacheStorageLocalDataSourceImpl(gh<_i29.Isar>()));
    gh.factory<_i88.CancelRecordingUseCase>(
        () => _i88.CancelRecordingUseCase(gh<_i52.RecordingService>()));
    gh.factory<_i89.CommentAudioCubit>(
        () => _i89.CommentAudioCubit(gh<_i10.CommentAudioPlaybackService>()));
    gh.lazySingleton<_i90.ConsumeMagicLinkUseCase>(
        () => _i90.ConsumeMagicLinkUseCase(gh<_i32.MagicLinkRepository>()));
    gh.factory<_i91.CreateNotificationUseCase>(() =>
        _i91.CreateNotificationUseCase(gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i92.CreateVoiceMemoUseCase>(
        () => _i92.CreateVoiceMemoUseCase(gh<_i75.VoiceMemoRepository>()));
    gh.factory<_i93.DeleteNotificationUseCase>(() =>
        _i93.DeleteNotificationUseCase(gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i94.DeleteVoiceMemoUseCase>(
        () => _i94.DeleteVoiceMemoUseCase(gh<_i75.VoiceMemoRepository>()));
    gh.lazySingleton<_i95.GetMagicLinkStatusUseCase>(
        () => _i95.GetMagicLinkStatusUseCase(gh<_i32.MagicLinkRepository>()));
    gh.lazySingleton<_i96.GetUnreadNotificationsCountUseCase>(() =>
        _i96.GetUnreadNotificationsCountUseCase(
            gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i97.GoogleAuthService>(() => _i97.GoogleAuthService(
          gh<_i22.GoogleSignIn>(),
          gh<_i19.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i23.IncrementalSyncService<_i98.AudioTrackDTO>>(
        () => _i99.AudioTrackIncrementalSyncService(
              gh<_i86.AudioTrackRemoteDataSource>(),
              gh<_i85.AudioTrackLocalDataSource>(),
              gh<_i51.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i23.IncrementalSyncService<_i100.ProjectDTO>>(
        () => _i101.ProjectIncrementalSyncService(
              gh<_i50.ProjectRemoteDataSource>(),
              gh<_i51.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i23.IncrementalSyncService<_i102.UserProfileDTO>>(
        () => _i103.UserProfileIncrementalSyncService(
              gh<_i71.UserProfileRemoteDataSource>(),
              gh<_i70.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i23.IncrementalSyncService<_i104.AudioCommentDTO>>(
        () => _i105.AudioCommentIncrementalSyncService(
              gh<_i84.AudioCommentRemoteDataSource>(),
              gh<_i83.AudioCommentLocalDataSource>(),
              gh<_i69.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i106.InvitationLocalDataSource>(
        () => _i106.IsarInvitationLocalDataSource(gh<_i29.Isar>()));
    gh.lazySingleton<_i107.InvitationRepository>(
        () => _i108.InvitationRepositoryImpl(
              localDataSource: gh<_i106.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i28.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i35.NetworkStateManager>(),
            ));
    gh.factory<_i109.MarkAsUnreadUseCase>(
        () => _i109.MarkAsUnreadUseCase(gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i110.MarkNotificationAsReadUseCase>(() =>
        _i110.MarkNotificationAsReadUseCase(gh<_i38.NotificationRepository>()));
    gh.lazySingleton<_i111.ObservePendingInvitationsUseCase>(() =>
        _i111.ObservePendingInvitationsUseCase(
            gh<_i107.InvitationRepository>()));
    gh.lazySingleton<_i112.ObserveSentInvitationsUseCase>(() =>
        _i112.ObserveSentInvitationsUseCase(gh<_i107.InvitationRepository>()));
    gh.lazySingleton<_i113.OnboardingStateLocalDataSource>(() =>
        _i113.OnboardingStateLocalDataSourceImpl(gh<_i60.SharedPreferences>()));
    gh.lazySingleton<_i114.PendingOperationsManager>(
        () => _i114.PendingOperationsManager(
              gh<_i45.PendingOperationsRepository>(),
              gh<_i35.NetworkStateManager>(),
              gh<_i42.OperationExecutorFactory>(),
            ));
    gh.factory<_i115.PlaylistOperationExecutor>(() =>
        _i115.PlaylistOperationExecutor(gh<_i49.PlaylistRemoteDataSource>()));
    gh.factory<_i116.ProjectOperationExecutor>(() =>
        _i116.ProjectOperationExecutor(gh<_i50.ProjectRemoteDataSource>()));
    gh.factory<_i117.RecordingBloc>(() => _i117.RecordingBloc(
          gh<_i63.StartRecordingUseCase>(),
          gh<_i65.StopRecordingUseCase>(),
          gh<_i88.CancelRecordingUseCase>(),
          gh<_i52.RecordingService>(),
        ));
    gh.lazySingleton<_i118.SessionStorage>(
        () => _i118.SessionStorageImpl(prefs: gh<_i60.SharedPreferences>()));
    gh.factory<_i119.SyncStatusProvider>(() => _i119.SyncStatusProvider(
          syncCoordinator: gh<_i66.SyncCoordinator>(),
          pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i120.UpdateVoiceMemoUseCase>(
        () => _i120.UpdateVoiceMemoUseCase(gh<_i75.VoiceMemoRepository>()));
    gh.lazySingleton<_i121.UserProfileCacheRepository>(
        () => _i122.UserProfileCacheRepositoryImpl(
              gh<_i71.UserProfileRemoteDataSource>(),
              gh<_i70.UserProfileLocalDataSource>(),
              gh<_i35.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i123.UserProfileCollaboratorIncrementalSyncService>(
        () => _i123.UserProfileCollaboratorIncrementalSyncService(
              gh<_i71.UserProfileRemoteDataSource>(),
              gh<_i70.UserProfileLocalDataSource>(),
              gh<_i51.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i124.UserProfileOperationExecutor>(() =>
        _i124.UserProfileOperationExecutor(
            gh<_i71.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i125.WatchTrackUploadStatusUseCase>(() =>
        _i125.WatchTrackUploadStatusUseCase(
            gh<_i114.PendingOperationsManager>()));
    gh.lazySingleton<_i126.WatchUserProfilesUseCase>(() =>
        _i126.WatchUserProfilesUseCase(gh<_i121.UserProfileCacheRepository>()));
    gh.lazySingleton<_i127.WaveformIncrementalSyncService>(
        () => _i127.WaveformIncrementalSyncService(
              gh<_i69.TrackVersionLocalDataSource>(),
              gh<_i80.WaveformLocalDataSource>(),
              gh<_i81.WaveformRemoteDataSource>(),
            ));
    gh.factory<_i128.WaveformOperationExecutor>(() =>
        _i128.WaveformOperationExecutor(gh<_i81.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i129.AudioFileRepository>(
        () => _i130.AudioFileRepositoryImpl(
              gh<_i21.FirebaseStorage>(),
              gh<_i15.DirectoryService>(),
              gh<_i87.CacheStorageLocalDataSource>(),
              httpClient: gh<_i9.Client>(),
            ));
    gh.lazySingleton<_i131.AudioStorageRepository>(
        () => _i132.AudioStorageRepositoryImpl(
              localDataSource: gh<_i87.CacheStorageLocalDataSource>(),
              directoryService: gh<_i15.DirectoryService>(),
            ));
    gh.factory<_i133.AudioTrackOperationExecutor>(
        () => _i133.AudioTrackOperationExecutor(
              gh<_i86.AudioTrackRemoteDataSource>(),
              gh<_i85.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i134.AuthRemoteDataSource>(
        () => _i134.AuthRemoteDataSourceImpl(
              gh<_i19.FirebaseAuth>(),
              gh<_i97.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i135.AuthRepository>(() => _i136.AuthRepositoryImpl(
          remote: gh<_i134.AuthRemoteDataSource>(),
          sessionStorage: gh<_i118.SessionStorage>(),
          networkStateManager: gh<_i35.NetworkStateManager>(),
          googleAuthService: gh<_i97.GoogleAuthService>(),
          appleAuthService: gh<_i82.AppleAuthService>(),
        ));
    gh.lazySingleton<_i137.BackgroundSyncCoordinator>(
        () => _i138.BackgroundSyncCoordinatorImpl(
              gh<_i35.NetworkStateManager>(),
              gh<_i66.SyncCoordinator>(),
              gh<_i114.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i139.CacheManagementLocalDataSource>(
        () => _i139.CacheManagementLocalDataSourceImpl(
              local: gh<_i87.CacheStorageLocalDataSource>(),
              directoryService: gh<_i15.DirectoryService>(),
            ));
    gh.factory<_i140.CacheTrackUseCase>(() => _i140.CacheTrackUseCase(
          gh<_i129.AudioFileRepository>(),
          gh<_i131.AudioStorageRepository>(),
          gh<_i15.DirectoryService>(),
        ));
    gh.lazySingleton<_i141.CancelInvitationUseCase>(
        () => _i141.CancelInvitationUseCase(gh<_i107.InvitationRepository>()));
    gh.factory<_i142.CheckAuthenticationStatusUseCase>(() =>
        _i142.CheckAuthenticationStatusUseCase(gh<_i135.AuthRepository>()));
    gh.factory<_i143.CurrentUserService>(
        () => _i143.CurrentUserService(gh<_i118.SessionStorage>()));
    gh.factory<_i144.DeleteCachedAudioUseCase>(() =>
        _i144.DeleteCachedAudioUseCase(gh<_i131.AudioStorageRepository>()));
    gh.lazySingleton<_i145.GenerateMagicLinkUseCase>(
        () => _i145.GenerateMagicLinkUseCase(
              gh<_i32.MagicLinkRepository>(),
              gh<_i135.AuthRepository>(),
            ));
    gh.lazySingleton<_i146.GetAuthStateUseCase>(
        () => _i146.GetAuthStateUseCase(gh<_i135.AuthRepository>()));
    gh.factory<_i147.GetCachedAudioCommentUseCase>(
        () => _i147.GetCachedAudioCommentUseCase(
              gh<_i131.AudioStorageRepository>(),
              gh<_i129.AudioFileRepository>(),
            ));
    gh.factory<_i148.GetCachedTrackPathUseCase>(() =>
        _i148.GetCachedTrackPathUseCase(gh<_i131.AudioStorageRepository>()));
    gh.factory<_i149.GetCurrentUserUseCase>(
        () => _i149.GetCurrentUserUseCase(gh<_i135.AuthRepository>()));
    gh.lazySingleton<_i150.GetPendingInvitationsCountUseCase>(() =>
        _i150.GetPendingInvitationsCountUseCase(
            gh<_i107.InvitationRepository>()));
    gh.factory<_i151.MarkAllNotificationsAsReadUseCase>(
        () => _i151.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i38.NotificationRepository>(),
              currentUserService: gh<_i143.CurrentUserService>(),
            ));
    gh.factory<_i152.NotificationActorBloc>(() => _i152.NotificationActorBloc(
          createNotificationUseCase: gh<_i91.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i110.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i109.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i151.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i93.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i153.NotificationWatcherBloc>(
        () => _i153.NotificationWatcherBloc(
              notificationRepository: gh<_i38.NotificationRepository>(),
              currentUserService: gh<_i143.CurrentUserService>(),
            ));
    gh.lazySingleton<_i154.OnboardingRepository>(() =>
        _i155.OnboardingRepositoryImpl(
            gh<_i113.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i156.OnboardingUseCase>(
        () => _i156.OnboardingUseCase(gh<_i154.OnboardingRepository>()));
    gh.lazySingleton<_i157.PlaylistRepository>(
        () => _i158.PlaylistRepositoryImpl(
              localDataSource: gh<_i48.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i137.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
            ));
    gh.factory<_i159.ProjectInvitationWatcherBloc>(
        () => _i159.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i107.InvitationRepository>(),
              currentUserService: gh<_i143.CurrentUserService>(),
            ));
    gh.lazySingleton<_i160.ProjectsRepository>(
        () => _i161.ProjectsRepositoryImpl(
              localDataSource: gh<_i51.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i137.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i162.RemoveCollaboratorUseCase>(
        () => _i162.RemoveCollaboratorUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.factory<_i163.RemoveTrackCacheUseCase>(() =>
        _i163.RemoveTrackCacheUseCase(gh<_i131.AudioStorageRepository>()));
    gh.lazySingleton<_i164.SignOutUseCase>(
        () => _i164.SignOutUseCase(gh<_i135.AuthRepository>()));
    gh.lazySingleton<_i165.SignUpUseCase>(
        () => _i165.SignUpUseCase(gh<_i135.AuthRepository>()));
    gh.factory<_i166.TrackUploadStatusCubit>(() => _i166.TrackUploadStatusCubit(
        gh<_i125.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i167.TrackVersionRemoteDataSource>(
        () => _i167.TrackVersionRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i129.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i168.TrackVersionRepository>(
        () => _i169.TrackVersionRepositoryImpl(
              gh<_i69.TrackVersionLocalDataSource>(),
              gh<_i137.BackgroundSyncCoordinator>(),
              gh<_i114.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i170.TriggerUpstreamSyncUseCase>(() =>
        _i170.TriggerUpstreamSyncUseCase(
            gh<_i137.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i171.UpdateCollaboratorRoleUseCase>(
        () => _i171.UpdateCollaboratorRoleUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.UpdateProjectUseCase>(
        () => _i172.UpdateProjectUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i173.UserProfileRepository>(
        () => _i174.UserProfileRepositoryImpl(
              localDataSource: gh<_i70.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i71.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i35.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i137.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
              firestore: gh<_i20.FirebaseFirestore>(),
              sessionStorage: gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i175.WatchAllProjectsUseCase>(
        () => _i175.WatchAllProjectsUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.factory<_i176.WatchCachedAudiosUseCase>(() =>
        _i176.WatchCachedAudiosUseCase(gh<_i131.AudioStorageRepository>()));
    gh.lazySingleton<_i177.WatchCollaboratorsBundleUseCase>(
        () => _i177.WatchCollaboratorsBundleUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i126.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i178.WatchStorageUsageUseCase>(() =>
        _i178.WatchStorageUsageUseCase(gh<_i131.AudioStorageRepository>()));
    gh.factory<_i179.WatchTrackCacheStatusUseCase>(() =>
        _i179.WatchTrackCacheStatusUseCase(gh<_i131.AudioStorageRepository>()));
    gh.lazySingleton<_i180.WatchTrackVersionsUseCase>(() =>
        _i180.WatchTrackVersionsUseCase(gh<_i168.TrackVersionRepository>()));
    gh.lazySingleton<_i181.WatchUserProfileUseCase>(
        () => _i181.WatchUserProfileUseCase(
              gh<_i173.UserProfileRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.factory<_i182.WaveformRepository>(() => _i183.WaveformRepositoryImpl(
          localDataSource: gh<_i80.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i81.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i137.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i184.AcceptInvitationUseCase>(
        () => _i184.AcceptInvitationUseCase(
              invitationRepository: gh<_i107.InvitationRepository>(),
              projectRepository: gh<_i160.ProjectsRepository>(),
              userProfileRepository: gh<_i173.UserProfileRepository>(),
              notificationService: gh<_i40.NotificationService>(),
            ));
    gh.lazySingleton<_i185.AddCollaboratorToProjectUseCase>(
        () => _i185.AddCollaboratorToProjectUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i186.AppleSignInUseCase>(
        () => _i186.AppleSignInUseCase(gh<_i135.AuthRepository>()));
    gh.factory<_i187.AudioCommentOperationExecutor>(
        () => _i187.AudioCommentOperationExecutor(
              gh<_i84.AudioCommentRemoteDataSource>(),
              gh<_i129.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i188.AudioCommentRepository>(
        () => _i189.AudioCommentRepositoryImpl(
              localDataSource: gh<_i83.AudioCommentLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i137.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i114.PendingOperationsManager>(),
              trackVersionRepository: gh<_i168.TrackVersionRepository>(),
              audioStorageRepository: gh<_i131.AudioStorageRepository>(),
            ));
    gh.factory<_i190.AudioSourceResolver>(() => _i191.AudioSourceResolverImpl(
          gh<_i131.AudioStorageRepository>(),
          gh<_i129.AudioFileRepository>(),
          gh<_i15.DirectoryService>(),
        ));
    gh.lazySingleton<_i192.AudioTrackRepository>(
        () => _i193.AudioTrackRepositoryImpl(
              gh<_i85.AudioTrackLocalDataSource>(),
              gh<_i137.BackgroundSyncCoordinator>(),
              gh<_i114.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i194.CacheMaintenanceService>(() =>
        _i195.CacheMaintenanceServiceImpl(
            gh<_i139.CacheManagementLocalDataSource>()));
    gh.factory<_i196.CheckProfileCompletenessUseCase>(() =>
        _i196.CheckProfileCompletenessUseCase(
            gh<_i173.UserProfileRepository>()));
    gh.factory<_i197.CleanupCacheUseCase>(
        () => _i197.CleanupCacheUseCase(gh<_i194.CacheMaintenanceService>()));
    gh.lazySingleton<_i198.CreateProjectUseCase>(
        () => _i198.CreateProjectUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.factory<_i199.CreateUserProfileUseCase>(
        () => _i199.CreateUserProfileUseCase(
              gh<_i173.UserProfileRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i200.DeclineInvitationUseCase>(
        () => _i200.DeclineInvitationUseCase(
              invitationRepository: gh<_i107.InvitationRepository>(),
              projectRepository: gh<_i160.ProjectsRepository>(),
              userProfileRepository: gh<_i173.UserProfileRepository>(),
              notificationService: gh<_i40.NotificationService>(),
            ));
    gh.lazySingleton<_i201.DeleteTrackVersionUseCase>(
        () => _i201.DeleteTrackVersionUseCase(
              gh<_i168.TrackVersionRepository>(),
              gh<_i182.WaveformRepository>(),
              gh<_i188.AudioCommentRepository>(),
              gh<_i131.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i202.FindUserByEmailUseCase>(
        () => _i202.FindUserByEmailUseCase(gh<_i173.UserProfileRepository>()));
    gh.factory<_i203.GenerateAndStoreWaveform>(
        () => _i203.GenerateAndStoreWaveform(
              gh<_i182.WaveformRepository>(),
              gh<_i78.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i204.GetActiveVersionUseCase>(() =>
        _i204.GetActiveVersionUseCase(gh<_i168.TrackVersionRepository>()));
    gh.factory<_i205.GetCacheStorageStatsUseCase>(() =>
        _i205.GetCacheStorageStatsUseCase(gh<_i194.CacheMaintenanceService>()));
    gh.lazySingleton<_i206.GetProjectByIdUseCase>(
        () => _i206.GetProjectByIdUseCase(gh<_i160.ProjectsRepository>()));
    gh.lazySingleton<_i207.GetVersionByIdUseCase>(
        () => _i207.GetVersionByIdUseCase(gh<_i168.TrackVersionRepository>()));
    gh.factory<_i208.GetWaveformByVersion>(
        () => _i208.GetWaveformByVersion(gh<_i182.WaveformRepository>()));
    gh.lazySingleton<_i209.GoogleSignInUseCase>(() => _i209.GoogleSignInUseCase(
          gh<_i135.AuthRepository>(),
          gh<_i173.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i23.IncrementalSyncService<_i210.TrackVersionDTO>>(
        () => _i211.TrackVersionIncrementalSyncService(
              gh<_i167.TrackVersionRemoteDataSource>(),
              gh<_i69.TrackVersionLocalDataSource>(),
              gh<_i85.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i212.JoinProjectWithIdUseCase>(
        () => _i212.JoinProjectWithIdUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i213.LeaveProjectUseCase>(() => _i213.LeaveProjectUseCase(
          gh<_i160.ProjectsRepository>(),
          gh<_i118.SessionStorage>(),
        ));
    gh.factory<_i214.LoadTrackContextUseCase>(
        () => _i214.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i192.AudioTrackRepository>(),
              trackVersionRepository: gh<_i168.TrackVersionRepository>(),
              userProfileRepository: gh<_i173.UserProfileRepository>(),
              projectsRepository: gh<_i160.ProjectsRepository>(),
            ));
    gh.factory<_i215.MagicLinkBloc>(() => _i215.MagicLinkBloc(
          generateMagicLink: gh<_i145.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i72.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i90.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i54.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i95.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i212.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i135.AuthRepository>(),
        ));
    gh.factory<_i216.OnboardingBloc>(() => _i216.OnboardingBloc(
          onboardingUseCase: gh<_i156.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i149.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i217.PlayPlaylistUseCase>(() => _i217.PlayPlaylistUseCase(
          playlistRepository: gh<_i157.PlaylistRepository>(),
          audioTrackRepository: gh<_i192.AudioTrackRepository>(),
          trackVersionRepository: gh<_i168.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i131.AudioStorageRepository>(),
        ));
    gh.factory<_i218.PlayVersionUseCase>(() => _i218.PlayVersionUseCase(
          audioTrackRepository: gh<_i192.AudioTrackRepository>(),
          audioStorageRepository: gh<_i131.AudioStorageRepository>(),
          trackVersionRepository: gh<_i168.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i219.ProjectCommentService>(
        () => _i219.ProjectCommentService(gh<_i188.AudioCommentRepository>()));
    gh.lazySingleton<_i220.ProjectTrackService>(
        () => _i220.ProjectTrackService(gh<_i192.AudioTrackRepository>()));
    gh.lazySingleton<_i221.RenameTrackVersionUseCase>(() =>
        _i221.RenameTrackVersionUseCase(gh<_i168.TrackVersionRepository>()));
    gh.factory<_i222.ResolveTrackVersionUseCase>(
        () => _i222.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i192.AudioTrackRepository>(),
              trackVersionRepository: gh<_i168.TrackVersionRepository>(),
            ));
    gh.factory<_i223.RestorePlaybackStateUseCase>(
        () => _i223.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i46.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i192.AudioTrackRepository>(),
              audioStorageRepository: gh<_i131.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i224.SendInvitationUseCase>(
        () => _i224.SendInvitationUseCase(
              invitationRepository: gh<_i107.InvitationRepository>(),
              notificationService: gh<_i40.NotificationService>(),
              findUserByEmail: gh<_i202.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i32.MagicLinkRepository>(),
              currentUserService: gh<_i143.CurrentUserService>(),
            ));
    gh.factory<_i225.SessionCleanupService>(() => _i225.SessionCleanupService(
          userProfileRepository: gh<_i173.UserProfileRepository>(),
          projectsRepository: gh<_i160.ProjectsRepository>(),
          audioTrackRepository: gh<_i192.AudioTrackRepository>(),
          audioCommentRepository: gh<_i188.AudioCommentRepository>(),
          invitationRepository: gh<_i107.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i46.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i118.SessionStorage>(),
          pendingOperationsRepository: gh<_i45.PendingOperationsRepository>(),
          waveformRepository: gh<_i182.WaveformRepository>(),
          trackVersionRepository: gh<_i168.TrackVersionRepository>(),
          syncCoordinator: gh<_i66.SyncCoordinator>(),
        ));
    gh.factory<_i226.SessionService>(() => _i226.SessionService(
          checkAuthUseCase: gh<_i142.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i149.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i156.OnboardingUseCase>(),
          profileUseCase: gh<_i196.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i227.SetActiveTrackVersionUseCase>(() =>
        _i227.SetActiveTrackVersionUseCase(gh<_i192.AudioTrackRepository>()));
    gh.lazySingleton<_i228.SignInUseCase>(() => _i228.SignInUseCase(
          gh<_i135.AuthRepository>(),
          gh<_i173.UserProfileRepository>(),
        ));
    gh.factory<_i229.TrackCacheBloc>(() => _i229.TrackCacheBloc(
          cacheTrackUseCase: gh<_i140.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i179.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i163.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i148.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i230.TrackVersionOperationExecutor>(
        () => _i230.TrackVersionOperationExecutor(
              gh<_i167.TrackVersionRemoteDataSource>(),
              gh<_i69.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i231.TriggerDownstreamSyncUseCase>(
        () => _i231.TriggerDownstreamSyncUseCase(
              gh<_i137.BackgroundSyncCoordinator>(),
              gh<_i226.SessionService>(),
            ));
    gh.lazySingleton<_i232.TriggerForegroundSyncUseCase>(
        () => _i232.TriggerForegroundSyncUseCase(
              gh<_i137.BackgroundSyncCoordinator>(),
              gh<_i226.SessionService>(),
            ));
    gh.lazySingleton<_i233.TriggerStartupSyncUseCase>(
        () => _i233.TriggerStartupSyncUseCase(
              gh<_i137.BackgroundSyncCoordinator>(),
              gh<_i226.SessionService>(),
            ));
    gh.factory<_i234.UpdateUserProfileUseCase>(
        () => _i234.UpdateUserProfileUseCase(
              gh<_i173.UserProfileRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.factory<_i235.UserProfileBloc>(() => _i235.UserProfileBloc(
          updateUserProfileUseCase: gh<_i234.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i199.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i181.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i196.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i149.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i236.WatchAudioCommentsBundleUseCase>(
        () => _i236.WatchAudioCommentsBundleUseCase(
              gh<_i192.AudioTrackRepository>(),
              gh<_i188.AudioCommentRepository>(),
              gh<_i121.UserProfileCacheRepository>(),
            ));
    gh.factory<_i237.WatchCachedTrackBundlesUseCase>(
        () => _i237.WatchCachedTrackBundlesUseCase(
              gh<_i194.CacheMaintenanceService>(),
              gh<_i192.AudioTrackRepository>(),
              gh<_i173.UserProfileRepository>(),
              gh<_i160.ProjectsRepository>(),
              gh<_i168.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i238.WatchProjectDetailUseCase>(
        () => _i238.WatchProjectDetailUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i192.AudioTrackRepository>(),
              gh<_i121.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i239.WatchProjectPlaylistUseCase>(
        () => _i239.WatchProjectPlaylistUseCase(
              gh<_i192.AudioTrackRepository>(),
              gh<_i168.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i240.WatchTrackVersionsBundleUseCase>(
        () => _i240.WatchTrackVersionsBundleUseCase(
              gh<_i192.AudioTrackRepository>(),
              gh<_i168.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i241.WatchTracksByProjectIdUseCase>(() =>
        _i241.WatchTracksByProjectIdUseCase(gh<_i192.AudioTrackRepository>()));
    gh.factory<_i242.WaveformBloc>(() => _i242.WaveformBloc(
          waveformRepository: gh<_i182.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i243.AddAudioCommentUseCase>(
        () => _i243.AddAudioCommentUseCase(
              gh<_i219.ProjectCommentService>(),
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i244.AddCollaboratorByEmailUseCase>(
        () => _i244.AddCollaboratorByEmailUseCase(
              gh<_i202.FindUserByEmailUseCase>(),
              gh<_i185.AddCollaboratorToProjectUseCase>(),
              gh<_i40.NotificationService>(),
            ));
    gh.lazySingleton<_i245.AddTrackVersionUseCase>(
        () => _i245.AddTrackVersionUseCase(
              gh<_i118.SessionStorage>(),
              gh<_i168.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i131.AudioStorageRepository>(),
              gh<_i203.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i246.AppFlowBloc>(() => _i246.AppFlowBloc(
          sessionService: gh<_i226.SessionService>(),
          getAuthStateUseCase: gh<_i146.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i225.SessionCleanupService>(),
        ));
    gh.factory<_i247.AudioContextBloc>(() => _i247.AudioContextBloc(
        loadTrackContextUseCase: gh<_i214.LoadTrackContextUseCase>()));
    gh.factory<_i248.AudioPlayerService>(() => _i248.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i26.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i218.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i217.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i222.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i43.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i55.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i64.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i61.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i62.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i57.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i68.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i67.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i59.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i58.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i56.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i223.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i249.AuthBloc>(() => _i249.AuthBloc(
          signIn: gh<_i228.SignInUseCase>(),
          signUp: gh<_i165.SignUpUseCase>(),
          googleSignIn: gh<_i209.GoogleSignInUseCase>(),
          appleSignIn: gh<_i186.AppleSignInUseCase>(),
          signOut: gh<_i164.SignOutUseCase>(),
        ));
    gh.factory<_i250.CacheManagementBloc>(() => _i250.CacheManagementBloc(
          deleteOne: gh<_i144.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i178.WatchStorageUsageUseCase>(),
          getStats: gh<_i205.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i197.CleanupCacheUseCase>(),
          watchBundles: gh<_i237.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i251.DeleteAudioCommentUseCase>(
        () => _i251.DeleteAudioCommentUseCase(
              gh<_i219.ProjectCommentService>(),
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
            ));
    gh.lazySingleton<_i252.DeleteAudioTrack>(() => _i252.DeleteAudioTrack(
          gh<_i118.SessionStorage>(),
          gh<_i160.ProjectsRepository>(),
          gh<_i220.ProjectTrackService>(),
          gh<_i168.TrackVersionRepository>(),
          gh<_i182.WaveformRepository>(),
          gh<_i131.AudioStorageRepository>(),
          gh<_i188.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i253.DeleteProjectUseCase>(
        () => _i253.DeleteProjectUseCase(
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
              gh<_i220.ProjectTrackService>(),
              gh<_i252.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i254.EditAudioTrackUseCase>(
        () => _i254.EditAudioTrackUseCase(
              gh<_i220.ProjectTrackService>(),
              gh<_i160.ProjectsRepository>(),
            ));
    gh.factory<_i255.ManageCollaboratorsBloc>(
        () => _i255.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i162.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i171.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i213.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i202.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i244.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i177.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.lazySingleton<_i256.PlayVoiceMemoUseCase>(
        () => _i256.PlayVoiceMemoUseCase(gh<_i248.AudioPlayerService>()));
    gh.factory<_i257.PlaylistBloc>(
        () => _i257.PlaylistBloc(gh<_i239.WatchProjectPlaylistUseCase>()));
    gh.factory<_i258.ProjectDetailBloc>(() => _i258.ProjectDetailBloc(
        watchProjectDetail: gh<_i238.WatchProjectDetailUseCase>()));
    gh.factory<_i259.ProjectInvitationActorBloc>(
        () => _i259.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i224.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i184.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i200.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i141.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i202.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i260.ProjectsBloc>(() => _i260.ProjectsBloc(
          createProject: gh<_i198.CreateProjectUseCase>(),
          updateProject: gh<_i172.UpdateProjectUseCase>(),
          deleteProject: gh<_i253.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i175.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i261.SyncBloc>(() => _i261.SyncBloc(
          gh<_i233.TriggerStartupSyncUseCase>(),
          gh<_i170.TriggerUpstreamSyncUseCase>(),
          gh<_i232.TriggerForegroundSyncUseCase>(),
          gh<_i231.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i262.SyncStatusCubit>(() => _i262.SyncStatusCubit(
          gh<_i119.SyncStatusProvider>(),
          gh<_i114.PendingOperationsManager>(),
          gh<_i170.TriggerUpstreamSyncUseCase>(),
          gh<_i232.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i263.TrackVersionsBloc>(() => _i263.TrackVersionsBloc(
          gh<_i240.WatchTrackVersionsBundleUseCase>(),
          gh<_i227.SetActiveTrackVersionUseCase>(),
          gh<_i245.AddTrackVersionUseCase>(),
          gh<_i221.RenameTrackVersionUseCase>(),
          gh<_i201.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i264.UploadAudioTrackUseCase>(
        () => _i264.UploadAudioTrackUseCase(
              gh<_i220.ProjectTrackService>(),
              gh<_i160.ProjectsRepository>(),
              gh<_i118.SessionStorage>(),
              gh<_i245.AddTrackVersionUseCase>(),
              gh<_i192.AudioTrackRepository>(),
            ));
    gh.factory<_i265.VoiceMemoBloc>(() => _i265.VoiceMemoBloc(
          gh<_i77.WatchVoiceMemosUseCase>(),
          gh<_i92.CreateVoiceMemoUseCase>(),
          gh<_i120.UpdateVoiceMemoUseCase>(),
          gh<_i94.DeleteVoiceMemoUseCase>(),
          gh<_i256.PlayVoiceMemoUseCase>(),
        ));
    gh.factory<_i266.AudioCommentBloc>(() => _i266.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i243.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i251.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i236.WatchAudioCommentsBundleUseCase>(),
          getCachedAudioCommentUseCase:
              gh<_i147.GetCachedAudioCommentUseCase>(),
        ));
    gh.factory<_i267.AudioPlayerBloc>(() => _i267.AudioPlayerBloc(
        audioPlayerService: gh<_i248.AudioPlayerService>()));
    gh.factory<_i268.AudioTrackBloc>(() => _i268.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i241.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i252.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i264.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i254.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i269.AppModule {}
