// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i15;

import 'package:cloud_firestore/cloud_firestore.dart' as _i21;
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:firebase_auth/firebase_auth.dart' as _i20;
import 'package:firebase_storage/firebase_storage.dart' as _i22;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i23;
import 'package:http/http.dart' as _i9;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i28;
import 'package:isar/isar.dart' as _i30;
import 'package:shared_preferences/shared_preferences.dart' as _i61;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i114;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i19;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i220;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i221;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i137;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i141;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i144;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i241;
import 'package:trackflow/core/audio/data/unified_audio_service.dart' as _i125;
import 'package:trackflow/core/audio/domain/audio_file_repository.dart'
    as _i124;
import 'package:trackflow/core/di/app_module.dart' as _i263;
import 'package:trackflow/core/infrastructure/domain/directory_service.dart'
    as _i16;
import 'package:trackflow/core/infrastructure/services/directory_service_impl.dart'
    as _i17;
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
    as _i89;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i90;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i92;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i146;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i105;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i106;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i42;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i147;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i148;
import 'package:trackflow/core/services/deep_link_service.dart' as _i13;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i18;
import 'package:trackflow/core/session/current_user_service.dart' as _i138;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i45;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i46;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i133;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i182;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i128;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i43;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i112;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i225;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i119;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i123;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i132;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i24;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i67;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i226;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i227;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i228;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i165;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i256;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i257;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i86;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i126;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i143;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i158;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i174;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i171;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i224;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i82;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i83;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i96;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i184;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i97;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i183;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i214;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i238;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i246;
import 'package:trackflow/features/audio_comment/domain/usecases/get_cached_audio_comment_usecase.dart'
    as _i142;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i231;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i260;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i209;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i242;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i47;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i243;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i185;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i27;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i212;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i213;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i217;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i218;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i57;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i65;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i68;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i69;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i48;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i186;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i261;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i53;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i87;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i64;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i54;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i113;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i84;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i85;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i100;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i188;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i101;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i187;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i215;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i247;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i249;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i259;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i236;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i120;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i262;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i161;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i129;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i131;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i81;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i93;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i130;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i181;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i204;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i223;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i159;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i160;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i244;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i134;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i190;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i189;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i192;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i139;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i200;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i232;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i173;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i245;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i102;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i29;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i104;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i103;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i179;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i136;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i195;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i145;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i107;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i108;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i219;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i254;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i154;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i31;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i32;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i34;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i33;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i88;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i140;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i91;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i55;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i75;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i210;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i239;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i180;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i197;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i207;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i208;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i157;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i166;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i172;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i250;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i35;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i26;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i109;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i150;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i151;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i149;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i211;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i50;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i153;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i152;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i234;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i252;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i233;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i253;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i52;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i51;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i94;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i156;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i95;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i155;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i193;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i248;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i201;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i167;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i170;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i255;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i71;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i162;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i205;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i164;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i206;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i163;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i240;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i196;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i199;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i202;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i216;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i222;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i235;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i175;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i258;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i70;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i98;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i117;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i169;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i118;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i99;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i168;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i116;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i191;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i194;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i229;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i176;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i121;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i230;
import 'package:trackflow/features/voice_memos/domain/repositories/voice_memo_repository.dart'
    as _i12;
import 'package:trackflow/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart'
    as _i11;
import 'package:trackflow/features/voice_memos/domain/usecases/delete_voice_memo_usecase.dart'
    as _i14;
import 'package:trackflow/features/voice_memos/domain/usecases/play_voice_memo_usecase.dart'
    as _i251;
import 'package:trackflow/features/voice_memos/domain/usecases/update_voice_memo_usecase.dart'
    as _i72;
import 'package:trackflow/features/voice_memos/domain/usecases/watch_voice_memos_usecase.dart'
    as _i76;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i79;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i80;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i178;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i78;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i122;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i177;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i77;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i198;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i203;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i237;

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
    gh.lazySingleton<_i11.CreateVoiceMemoUseCase>(
        () => _i11.CreateVoiceMemoUseCase(gh<_i12.VoiceMemoRepository>()));
    gh.singleton<_i13.DeepLinkService>(() => _i13.DeepLinkService());
    gh.lazySingleton<_i14.DeleteVoiceMemoUseCase>(
        () => _i14.DeleteVoiceMemoUseCase(gh<_i12.VoiceMemoRepository>()));
    await gh.factoryAsync<_i15.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.lazySingleton<_i16.DirectoryService>(() => _i17.DirectoryServiceImpl());
    gh.singleton<_i18.DynamicLinkService>(() => _i18.DynamicLinkService());
    gh.factory<_i19.ExampleComplexBloc>(() => _i19.ExampleComplexBloc());
    gh.factory<_i19.ExampleConditionalBloc>(
        () => _i19.ExampleConditionalBloc());
    gh.factory<_i19.ExampleNavigationCubit>(
        () => _i19.ExampleNavigationCubit());
    gh.factory<_i19.ExampleSimpleBloc>(() => _i19.ExampleSimpleBloc());
    gh.factory<_i19.ExampleUserProfileBloc>(
        () => _i19.ExampleUserProfileBloc());
    gh.lazySingleton<_i20.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i21.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i22.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i23.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i24.IncrementalSyncService<_i25.Notification>>(
        () => _i26.NotificationIncrementalSyncService());
    gh.factory<_i27.InitializeAudioPlayerUseCase>(() =>
        _i27.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i28.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i29.InvitationRemoteDataSource>(() =>
        _i29.FirestoreInvitationRemoteDataSource(gh<_i21.FirebaseFirestore>()));
    await gh.factoryAsync<_i30.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i31.MagicLinkLocalDataSource>(
        () => _i31.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i32.MagicLinkRemoteDataSource>(
        () => _i32.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i21.FirebaseFirestore>(),
              deepLinkService: gh<_i13.DeepLinkService>(),
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
            gh<_i21.FirebaseFirestore>()));
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
        () => _i50.PlaylistRemoteDataSourceImpl(gh<_i21.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i51.ProjectRemoteDataSource>(() =>
        _i51.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i21.FirebaseFirestore>()));
    gh.lazySingleton<_i52.ProjectsLocalDataSource>(
        () => _i52.ProjectsLocalDataSourceImpl(gh<_i30.Isar>()));
    gh.lazySingleton<_i53.RecordingService>(
        () => _i54.PlatformRecordingService());
    gh.lazySingleton<_i55.ResendMagicLinkUseCase>(
        () => _i55.ResendMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.factory<_i56.ResumeAudioUseCase>(() => _i56.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i57.SavePlaybackStateUseCase>(
        () => _i57.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i47.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i58.SeekAudioUseCase>(() =>
        _i58.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.SetPlaybackSpeedUseCase>(() => _i59.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.SetVolumeUseCase>(() =>
        _i60.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i61.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i62.SkipToNextUseCase>(() => _i62.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i63.SkipToPreviousUseCase>(() => _i63.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i64.StartRecordingUseCase>(
        () => _i64.StartRecordingUseCase(gh<_i53.RecordingService>()));
    gh.factory<_i65.StopAudioUseCase>(() =>
        _i65.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i66.StopRecordingUseCase>(
        () => _i66.StopRecordingUseCase(gh<_i53.RecordingService>()));
    gh.lazySingleton<_i67.SyncCoordinator>(
        () => _i67.SyncCoordinator(gh<_i61.SharedPreferences>()));
    gh.factory<_i68.ToggleRepeatModeUseCase>(() => _i68.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i69.ToggleShuffleUseCase>(() => _i69.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i70.TrackDetailCubit>(() => _i70.TrackDetailCubit());
    gh.lazySingleton<_i71.TrackVersionLocalDataSource>(
        () => _i71.IsarTrackVersionLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i72.UpdateVoiceMemoUseCase>(
        () => _i72.UpdateVoiceMemoUseCase(gh<_i12.VoiceMemoRepository>()));
    gh.lazySingleton<_i73.UserProfileLocalDataSource>(
        () => _i73.IsarUserProfileLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i74.UserProfileRemoteDataSource>(
        () => _i74.UserProfileRemoteDataSourceImpl(
              gh<_i21.FirebaseFirestore>(),
              gh<_i22.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i75.ValidateMagicLinkUseCase>(
        () => _i75.ValidateMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.lazySingleton<_i76.WatchVoiceMemosUseCase>(
        () => _i76.WatchVoiceMemosUseCase(gh<_i12.VoiceMemoRepository>()));
    gh.factory<_i77.WaveformGeneratorService>(() =>
        _i78.JustWaveformGeneratorService(cacheDir: gh<_i15.Directory>()));
    gh.factory<_i79.WaveformLocalDataSource>(
        () => _i79.WaveformLocalDataSourceImpl(isar: gh<_i30.Isar>()));
    gh.lazySingleton<_i80.WaveformRemoteDataSource>(() =>
        _i80.FirebaseStorageWaveformRemoteDataSource(
            gh<_i22.FirebaseStorage>()));
    gh.lazySingleton<_i81.AppleAuthService>(
        () => _i81.AppleAuthService(gh<_i20.FirebaseAuth>()));
    gh.lazySingleton<_i82.AudioCommentLocalDataSource>(
        () => _i82.IsarAudioCommentLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i83.AudioCommentRemoteDataSource>(() =>
        _i83.FirebaseAudioCommentRemoteDataSource(
            gh<_i21.FirebaseFirestore>()));
    gh.lazySingleton<_i84.AudioTrackLocalDataSource>(
        () => _i84.IsarAudioTrackLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i85.AudioTrackRemoteDataSource>(() =>
        _i85.AudioTrackRemoteDataSourceImpl(gh<_i21.FirebaseFirestore>()));
    gh.lazySingleton<_i86.CacheStorageLocalDataSource>(
        () => _i86.CacheStorageLocalDataSourceImpl(gh<_i30.Isar>()));
    gh.factory<_i87.CancelRecordingUseCase>(
        () => _i87.CancelRecordingUseCase(gh<_i53.RecordingService>()));
    gh.lazySingleton<_i88.ConsumeMagicLinkUseCase>(
        () => _i88.ConsumeMagicLinkUseCase(gh<_i33.MagicLinkRepository>()));
    gh.factory<_i89.CreateNotificationUseCase>(() =>
        _i89.CreateNotificationUseCase(gh<_i39.NotificationRepository>()));
    gh.factory<_i90.DeleteNotificationUseCase>(() =>
        _i90.DeleteNotificationUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i91.GetMagicLinkStatusUseCase>(
        () => _i91.GetMagicLinkStatusUseCase(gh<_i33.MagicLinkRepository>()));
    gh.lazySingleton<_i92.GetUnreadNotificationsCountUseCase>(() =>
        _i92.GetUnreadNotificationsCountUseCase(
            gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i93.GoogleAuthService>(() => _i93.GoogleAuthService(
          gh<_i23.GoogleSignIn>(),
          gh<_i20.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i94.ProjectDTO>>(
        () => _i95.ProjectIncrementalSyncService(
              gh<_i51.ProjectRemoteDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i96.AudioCommentDTO>>(
        () => _i97.AudioCommentIncrementalSyncService(
              gh<_i83.AudioCommentRemoteDataSource>(),
              gh<_i82.AudioCommentLocalDataSource>(),
              gh<_i71.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i98.UserProfileDTO>>(
        () => _i99.UserProfileIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i100.AudioTrackDTO>>(
        () => _i101.AudioTrackIncrementalSyncService(
              gh<_i85.AudioTrackRemoteDataSource>(),
              gh<_i84.AudioTrackLocalDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i102.InvitationLocalDataSource>(
        () => _i102.IsarInvitationLocalDataSource(gh<_i30.Isar>()));
    gh.lazySingleton<_i103.InvitationRepository>(
        () => _i104.InvitationRepositoryImpl(
              localDataSource: gh<_i102.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i29.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
            ));
    gh.factory<_i105.MarkAsUnreadUseCase>(
        () => _i105.MarkAsUnreadUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i106.MarkNotificationAsReadUseCase>(() =>
        _i106.MarkNotificationAsReadUseCase(gh<_i39.NotificationRepository>()));
    gh.lazySingleton<_i107.ObservePendingInvitationsUseCase>(() =>
        _i107.ObservePendingInvitationsUseCase(
            gh<_i103.InvitationRepository>()));
    gh.lazySingleton<_i108.ObserveSentInvitationsUseCase>(() =>
        _i108.ObserveSentInvitationsUseCase(gh<_i103.InvitationRepository>()));
    gh.lazySingleton<_i109.OnboardingStateLocalDataSource>(() =>
        _i109.OnboardingStateLocalDataSourceImpl(gh<_i61.SharedPreferences>()));
    gh.lazySingleton<_i110.PendingOperationsManager>(
        () => _i110.PendingOperationsManager(
              gh<_i46.PendingOperationsRepository>(),
              gh<_i36.NetworkStateManager>(),
              gh<_i43.OperationExecutorFactory>(),
            ));
    gh.factory<_i111.PlaylistOperationExecutor>(() =>
        _i111.PlaylistOperationExecutor(gh<_i50.PlaylistRemoteDataSource>()));
    gh.factory<_i112.ProjectOperationExecutor>(() =>
        _i112.ProjectOperationExecutor(gh<_i51.ProjectRemoteDataSource>()));
    gh.factory<_i113.RecordingBloc>(() => _i113.RecordingBloc(
          gh<_i64.StartRecordingUseCase>(),
          gh<_i66.StopRecordingUseCase>(),
          gh<_i87.CancelRecordingUseCase>(),
          gh<_i53.RecordingService>(),
        ));
    gh.lazySingleton<_i114.SessionStorage>(
        () => _i114.SessionStorageImpl(prefs: gh<_i61.SharedPreferences>()));
    gh.factory<_i115.SyncStatusProvider>(() => _i115.SyncStatusProvider(
          syncCoordinator: gh<_i67.SyncCoordinator>(),
          pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i116.UserProfileCacheRepository>(
        () => _i117.UserProfileCacheRepositoryImpl(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i36.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i118.UserProfileCollaboratorIncrementalSyncService>(
        () => _i118.UserProfileCollaboratorIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i52.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i119.UserProfileOperationExecutor>(() =>
        _i119.UserProfileOperationExecutor(
            gh<_i74.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i120.WatchTrackUploadStatusUseCase>(() =>
        _i120.WatchTrackUploadStatusUseCase(
            gh<_i110.PendingOperationsManager>()));
    gh.lazySingleton<_i121.WatchUserProfilesUseCase>(() =>
        _i121.WatchUserProfilesUseCase(gh<_i116.UserProfileCacheRepository>()));
    gh.lazySingleton<_i122.WaveformIncrementalSyncService>(
        () => _i122.WaveformIncrementalSyncService(
              gh<_i71.TrackVersionLocalDataSource>(),
              gh<_i79.WaveformLocalDataSource>(),
              gh<_i80.WaveformRemoteDataSource>(),
            ));
    gh.factory<_i123.WaveformOperationExecutor>(() =>
        _i123.WaveformOperationExecutor(gh<_i80.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i124.AudioFileRepository>(
        () => _i125.AudioFileRepositoryImpl(
              gh<_i22.FirebaseStorage>(),
              gh<_i16.DirectoryService>(),
              gh<_i86.CacheStorageLocalDataSource>(),
              httpClient: gh<_i9.Client>(),
            ));
    gh.lazySingleton<_i126.AudioStorageRepository>(
        () => _i127.AudioStorageRepositoryImpl(
              localDataSource: gh<_i86.CacheStorageLocalDataSource>(),
              directoryService: gh<_i16.DirectoryService>(),
            ));
    gh.factory<_i128.AudioTrackOperationExecutor>(
        () => _i128.AudioTrackOperationExecutor(
              gh<_i85.AudioTrackRemoteDataSource>(),
              gh<_i84.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i129.AuthRemoteDataSource>(
        () => _i129.AuthRemoteDataSourceImpl(
              gh<_i20.FirebaseAuth>(),
              gh<_i93.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i130.AuthRepository>(() => _i131.AuthRepositoryImpl(
          remote: gh<_i129.AuthRemoteDataSource>(),
          sessionStorage: gh<_i114.SessionStorage>(),
          networkStateManager: gh<_i36.NetworkStateManager>(),
          googleAuthService: gh<_i93.GoogleAuthService>(),
          appleAuthService: gh<_i81.AppleAuthService>(),
        ));
    gh.lazySingleton<_i132.BackgroundSyncCoordinator>(
        () => _i133.BackgroundSyncCoordinatorImpl(
              gh<_i36.NetworkStateManager>(),
              gh<_i67.SyncCoordinator>(),
              gh<_i110.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i134.CacheManagementLocalDataSource>(
        () => _i134.CacheManagementLocalDataSourceImpl(
              local: gh<_i86.CacheStorageLocalDataSource>(),
              directoryService: gh<_i16.DirectoryService>(),
            ));
    gh.factory<_i135.CacheTrackUseCase>(() => _i135.CacheTrackUseCase(
          gh<_i124.AudioFileRepository>(),
          gh<_i126.AudioStorageRepository>(),
          gh<_i16.DirectoryService>(),
        ));
    gh.lazySingleton<_i136.CancelInvitationUseCase>(
        () => _i136.CancelInvitationUseCase(gh<_i103.InvitationRepository>()));
    gh.factory<_i137.CheckAuthenticationStatusUseCase>(() =>
        _i137.CheckAuthenticationStatusUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i138.CurrentUserService>(
        () => _i138.CurrentUserService(gh<_i114.SessionStorage>()));
    gh.factory<_i139.DeleteCachedAudioUseCase>(() =>
        _i139.DeleteCachedAudioUseCase(gh<_i126.AudioStorageRepository>()));
    gh.lazySingleton<_i140.GenerateMagicLinkUseCase>(
        () => _i140.GenerateMagicLinkUseCase(
              gh<_i33.MagicLinkRepository>(),
              gh<_i130.AuthRepository>(),
            ));
    gh.lazySingleton<_i141.GetAuthStateUseCase>(
        () => _i141.GetAuthStateUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i142.GetCachedAudioCommentUseCase>(
        () => _i142.GetCachedAudioCommentUseCase(
              gh<_i126.AudioStorageRepository>(),
              gh<_i124.AudioFileRepository>(),
            ));
    gh.factory<_i143.GetCachedTrackPathUseCase>(() =>
        _i143.GetCachedTrackPathUseCase(gh<_i126.AudioStorageRepository>()));
    gh.factory<_i144.GetCurrentUserUseCase>(
        () => _i144.GetCurrentUserUseCase(gh<_i130.AuthRepository>()));
    gh.lazySingleton<_i145.GetPendingInvitationsCountUseCase>(() =>
        _i145.GetPendingInvitationsCountUseCase(
            gh<_i103.InvitationRepository>()));
    gh.factory<_i146.MarkAllNotificationsAsReadUseCase>(
        () => _i146.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i39.NotificationRepository>(),
              currentUserService: gh<_i138.CurrentUserService>(),
            ));
    gh.factory<_i147.NotificationActorBloc>(() => _i147.NotificationActorBloc(
          createNotificationUseCase: gh<_i89.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i106.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i105.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i146.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i90.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i148.NotificationWatcherBloc>(
        () => _i148.NotificationWatcherBloc(
              notificationRepository: gh<_i39.NotificationRepository>(),
              currentUserService: gh<_i138.CurrentUserService>(),
            ));
    gh.lazySingleton<_i149.OnboardingRepository>(() =>
        _i150.OnboardingRepositoryImpl(
            gh<_i109.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i151.OnboardingUseCase>(
        () => _i151.OnboardingUseCase(gh<_i149.OnboardingRepository>()));
    gh.lazySingleton<_i152.PlaylistRepository>(
        () => _i153.PlaylistRepositoryImpl(
              localDataSource: gh<_i49.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
            ));
    gh.factory<_i154.ProjectInvitationWatcherBloc>(
        () => _i154.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i103.InvitationRepository>(),
              currentUserService: gh<_i138.CurrentUserService>(),
            ));
    gh.lazySingleton<_i155.ProjectsRepository>(
        () => _i156.ProjectsRepositoryImpl(
              localDataSource: gh<_i52.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i157.RemoveCollaboratorUseCase>(
        () => _i157.RemoveCollaboratorUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.factory<_i158.RemoveTrackCacheUseCase>(() =>
        _i158.RemoveTrackCacheUseCase(gh<_i126.AudioStorageRepository>()));
    gh.lazySingleton<_i159.SignOutUseCase>(
        () => _i159.SignOutUseCase(gh<_i130.AuthRepository>()));
    gh.lazySingleton<_i160.SignUpUseCase>(
        () => _i160.SignUpUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i161.TrackUploadStatusCubit>(() => _i161.TrackUploadStatusCubit(
        gh<_i120.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i162.TrackVersionRemoteDataSource>(
        () => _i162.TrackVersionRemoteDataSourceImpl(
              gh<_i21.FirebaseFirestore>(),
              gh<_i124.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i163.TrackVersionRepository>(
        () => _i164.TrackVersionRepositoryImpl(
              gh<_i71.TrackVersionLocalDataSource>(),
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i110.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i165.TriggerUpstreamSyncUseCase>(() =>
        _i165.TriggerUpstreamSyncUseCase(
            gh<_i132.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i166.UpdateCollaboratorRoleUseCase>(
        () => _i166.UpdateCollaboratorRoleUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i167.UpdateProjectUseCase>(
        () => _i167.UpdateProjectUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i168.UserProfileRepository>(
        () => _i169.UserProfileRepositoryImpl(
              localDataSource: gh<_i73.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i74.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i36.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
              firestore: gh<_i21.FirebaseFirestore>(),
              sessionStorage: gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i170.WatchAllProjectsUseCase>(
        () => _i170.WatchAllProjectsUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.factory<_i171.WatchCachedAudiosUseCase>(() =>
        _i171.WatchCachedAudiosUseCase(gh<_i126.AudioStorageRepository>()));
    gh.lazySingleton<_i172.WatchCollaboratorsBundleUseCase>(
        () => _i172.WatchCollaboratorsBundleUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i121.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i173.WatchStorageUsageUseCase>(() =>
        _i173.WatchStorageUsageUseCase(gh<_i126.AudioStorageRepository>()));
    gh.factory<_i174.WatchTrackCacheStatusUseCase>(() =>
        _i174.WatchTrackCacheStatusUseCase(gh<_i126.AudioStorageRepository>()));
    gh.lazySingleton<_i175.WatchTrackVersionsUseCase>(() =>
        _i175.WatchTrackVersionsUseCase(gh<_i163.TrackVersionRepository>()));
    gh.lazySingleton<_i176.WatchUserProfileUseCase>(
        () => _i176.WatchUserProfileUseCase(
              gh<_i168.UserProfileRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.factory<_i177.WaveformRepository>(() => _i178.WaveformRepositoryImpl(
          localDataSource: gh<_i79.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i80.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i179.AcceptInvitationUseCase>(
        () => _i179.AcceptInvitationUseCase(
              invitationRepository: gh<_i103.InvitationRepository>(),
              projectRepository: gh<_i155.ProjectsRepository>(),
              userProfileRepository: gh<_i168.UserProfileRepository>(),
              notificationService: gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i180.AddCollaboratorToProjectUseCase>(
        () => _i180.AddCollaboratorToProjectUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i181.AppleSignInUseCase>(
        () => _i181.AppleSignInUseCase(gh<_i130.AuthRepository>()));
    gh.factory<_i182.AudioCommentOperationExecutor>(
        () => _i182.AudioCommentOperationExecutor(
              gh<_i83.AudioCommentRemoteDataSource>(),
              gh<_i124.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i183.AudioCommentRepository>(
        () => _i184.AudioCommentRepositoryImpl(
              localDataSource: gh<_i82.AudioCommentLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i132.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i110.PendingOperationsManager>(),
              trackVersionRepository: gh<_i163.TrackVersionRepository>(),
              audioStorageRepository: gh<_i126.AudioStorageRepository>(),
            ));
    gh.factory<_i185.AudioSourceResolver>(() => _i186.AudioSourceResolverImpl(
          gh<_i126.AudioStorageRepository>(),
          gh<_i124.AudioFileRepository>(),
          gh<_i16.DirectoryService>(),
        ));
    gh.lazySingleton<_i187.AudioTrackRepository>(
        () => _i188.AudioTrackRepositoryImpl(
              gh<_i84.AudioTrackLocalDataSource>(),
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i110.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i189.CacheMaintenanceService>(() =>
        _i190.CacheMaintenanceServiceImpl(
            gh<_i134.CacheManagementLocalDataSource>()));
    gh.factory<_i191.CheckProfileCompletenessUseCase>(() =>
        _i191.CheckProfileCompletenessUseCase(
            gh<_i168.UserProfileRepository>()));
    gh.factory<_i192.CleanupCacheUseCase>(
        () => _i192.CleanupCacheUseCase(gh<_i189.CacheMaintenanceService>()));
    gh.lazySingleton<_i193.CreateProjectUseCase>(
        () => _i193.CreateProjectUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.factory<_i194.CreateUserProfileUseCase>(
        () => _i194.CreateUserProfileUseCase(
              gh<_i168.UserProfileRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i195.DeclineInvitationUseCase>(
        () => _i195.DeclineInvitationUseCase(
              invitationRepository: gh<_i103.InvitationRepository>(),
              projectRepository: gh<_i155.ProjectsRepository>(),
              userProfileRepository: gh<_i168.UserProfileRepository>(),
              notificationService: gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i196.DeleteTrackVersionUseCase>(
        () => _i196.DeleteTrackVersionUseCase(
              gh<_i163.TrackVersionRepository>(),
              gh<_i177.WaveformRepository>(),
              gh<_i183.AudioCommentRepository>(),
              gh<_i126.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i197.FindUserByEmailUseCase>(
        () => _i197.FindUserByEmailUseCase(gh<_i168.UserProfileRepository>()));
    gh.factory<_i198.GenerateAndStoreWaveform>(
        () => _i198.GenerateAndStoreWaveform(
              gh<_i177.WaveformRepository>(),
              gh<_i77.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i199.GetActiveVersionUseCase>(() =>
        _i199.GetActiveVersionUseCase(gh<_i163.TrackVersionRepository>()));
    gh.factory<_i200.GetCacheStorageStatsUseCase>(() =>
        _i200.GetCacheStorageStatsUseCase(gh<_i189.CacheMaintenanceService>()));
    gh.lazySingleton<_i201.GetProjectByIdUseCase>(
        () => _i201.GetProjectByIdUseCase(gh<_i155.ProjectsRepository>()));
    gh.lazySingleton<_i202.GetVersionByIdUseCase>(
        () => _i202.GetVersionByIdUseCase(gh<_i163.TrackVersionRepository>()));
    gh.factory<_i203.GetWaveformByVersion>(
        () => _i203.GetWaveformByVersion(gh<_i177.WaveformRepository>()));
    gh.lazySingleton<_i204.GoogleSignInUseCase>(() => _i204.GoogleSignInUseCase(
          gh<_i130.AuthRepository>(),
          gh<_i168.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i24.IncrementalSyncService<_i205.TrackVersionDTO>>(
        () => _i206.TrackVersionIncrementalSyncService(
              gh<_i162.TrackVersionRemoteDataSource>(),
              gh<_i71.TrackVersionLocalDataSource>(),
              gh<_i84.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i207.JoinProjectWithIdUseCase>(
        () => _i207.JoinProjectWithIdUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i208.LeaveProjectUseCase>(() => _i208.LeaveProjectUseCase(
          gh<_i155.ProjectsRepository>(),
          gh<_i114.SessionStorage>(),
        ));
    gh.factory<_i209.LoadTrackContextUseCase>(
        () => _i209.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i187.AudioTrackRepository>(),
              trackVersionRepository: gh<_i163.TrackVersionRepository>(),
              userProfileRepository: gh<_i168.UserProfileRepository>(),
              projectsRepository: gh<_i155.ProjectsRepository>(),
            ));
    gh.factory<_i210.MagicLinkBloc>(() => _i210.MagicLinkBloc(
          generateMagicLink: gh<_i140.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i75.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i88.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i55.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i91.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i207.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i130.AuthRepository>(),
        ));
    gh.factory<_i211.OnboardingBloc>(() => _i211.OnboardingBloc(
          onboardingUseCase: gh<_i151.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i144.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i212.PlayPlaylistUseCase>(() => _i212.PlayPlaylistUseCase(
          playlistRepository: gh<_i152.PlaylistRepository>(),
          audioTrackRepository: gh<_i187.AudioTrackRepository>(),
          trackVersionRepository: gh<_i163.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i126.AudioStorageRepository>(),
        ));
    gh.factory<_i213.PlayVersionUseCase>(() => _i213.PlayVersionUseCase(
          audioTrackRepository: gh<_i187.AudioTrackRepository>(),
          audioStorageRepository: gh<_i126.AudioStorageRepository>(),
          trackVersionRepository: gh<_i163.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i214.ProjectCommentService>(
        () => _i214.ProjectCommentService(gh<_i183.AudioCommentRepository>()));
    gh.lazySingleton<_i215.ProjectTrackService>(
        () => _i215.ProjectTrackService(gh<_i187.AudioTrackRepository>()));
    gh.lazySingleton<_i216.RenameTrackVersionUseCase>(() =>
        _i216.RenameTrackVersionUseCase(gh<_i163.TrackVersionRepository>()));
    gh.factory<_i217.ResolveTrackVersionUseCase>(
        () => _i217.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i187.AudioTrackRepository>(),
              trackVersionRepository: gh<_i163.TrackVersionRepository>(),
            ));
    gh.factory<_i218.RestorePlaybackStateUseCase>(
        () => _i218.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i47.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i187.AudioTrackRepository>(),
              audioStorageRepository: gh<_i126.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i219.SendInvitationUseCase>(
        () => _i219.SendInvitationUseCase(
              invitationRepository: gh<_i103.InvitationRepository>(),
              notificationService: gh<_i41.NotificationService>(),
              findUserByEmail: gh<_i197.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i33.MagicLinkRepository>(),
              currentUserService: gh<_i138.CurrentUserService>(),
            ));
    gh.factory<_i220.SessionCleanupService>(() => _i220.SessionCleanupService(
          userProfileRepository: gh<_i168.UserProfileRepository>(),
          projectsRepository: gh<_i155.ProjectsRepository>(),
          audioTrackRepository: gh<_i187.AudioTrackRepository>(),
          audioCommentRepository: gh<_i183.AudioCommentRepository>(),
          invitationRepository: gh<_i103.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i47.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i114.SessionStorage>(),
          pendingOperationsRepository: gh<_i46.PendingOperationsRepository>(),
          waveformRepository: gh<_i177.WaveformRepository>(),
          trackVersionRepository: gh<_i163.TrackVersionRepository>(),
          syncCoordinator: gh<_i67.SyncCoordinator>(),
        ));
    gh.factory<_i221.SessionService>(() => _i221.SessionService(
          checkAuthUseCase: gh<_i137.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i144.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i151.OnboardingUseCase>(),
          profileUseCase: gh<_i191.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i222.SetActiveTrackVersionUseCase>(() =>
        _i222.SetActiveTrackVersionUseCase(gh<_i187.AudioTrackRepository>()));
    gh.lazySingleton<_i223.SignInUseCase>(() => _i223.SignInUseCase(
          gh<_i130.AuthRepository>(),
          gh<_i168.UserProfileRepository>(),
        ));
    gh.factory<_i224.TrackCacheBloc>(() => _i224.TrackCacheBloc(
          cacheTrackUseCase: gh<_i135.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i174.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i158.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i143.GetCachedTrackPathUseCase>(),
        ));
    gh.factory<_i225.TrackVersionOperationExecutor>(
        () => _i225.TrackVersionOperationExecutor(
              gh<_i162.TrackVersionRemoteDataSource>(),
              gh<_i71.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i226.TriggerDownstreamSyncUseCase>(
        () => _i226.TriggerDownstreamSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i221.SessionService>(),
            ));
    gh.lazySingleton<_i227.TriggerForegroundSyncUseCase>(
        () => _i227.TriggerForegroundSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i221.SessionService>(),
            ));
    gh.lazySingleton<_i228.TriggerStartupSyncUseCase>(
        () => _i228.TriggerStartupSyncUseCase(
              gh<_i132.BackgroundSyncCoordinator>(),
              gh<_i221.SessionService>(),
            ));
    gh.factory<_i229.UpdateUserProfileUseCase>(
        () => _i229.UpdateUserProfileUseCase(
              gh<_i168.UserProfileRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.factory<_i230.UserProfileBloc>(() => _i230.UserProfileBloc(
          updateUserProfileUseCase: gh<_i229.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i194.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i176.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i191.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i144.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i231.WatchAudioCommentsBundleUseCase>(
        () => _i231.WatchAudioCommentsBundleUseCase(
              gh<_i187.AudioTrackRepository>(),
              gh<_i183.AudioCommentRepository>(),
              gh<_i116.UserProfileCacheRepository>(),
            ));
    gh.factory<_i232.WatchCachedTrackBundlesUseCase>(
        () => _i232.WatchCachedTrackBundlesUseCase(
              gh<_i189.CacheMaintenanceService>(),
              gh<_i187.AudioTrackRepository>(),
              gh<_i168.UserProfileRepository>(),
              gh<_i155.ProjectsRepository>(),
              gh<_i163.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i233.WatchProjectDetailUseCase>(
        () => _i233.WatchProjectDetailUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i187.AudioTrackRepository>(),
              gh<_i116.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i234.WatchProjectPlaylistUseCase>(
        () => _i234.WatchProjectPlaylistUseCase(
              gh<_i187.AudioTrackRepository>(),
              gh<_i163.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i235.WatchTrackVersionsBundleUseCase>(
        () => _i235.WatchTrackVersionsBundleUseCase(
              gh<_i187.AudioTrackRepository>(),
              gh<_i163.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i236.WatchTracksByProjectIdUseCase>(() =>
        _i236.WatchTracksByProjectIdUseCase(gh<_i187.AudioTrackRepository>()));
    gh.factory<_i237.WaveformBloc>(() => _i237.WaveformBloc(
          waveformRepository: gh<_i177.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i238.AddAudioCommentUseCase>(
        () => _i238.AddAudioCommentUseCase(
              gh<_i214.ProjectCommentService>(),
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i239.AddCollaboratorByEmailUseCase>(
        () => _i239.AddCollaboratorByEmailUseCase(
              gh<_i197.FindUserByEmailUseCase>(),
              gh<_i180.AddCollaboratorToProjectUseCase>(),
              gh<_i41.NotificationService>(),
            ));
    gh.lazySingleton<_i240.AddTrackVersionUseCase>(
        () => _i240.AddTrackVersionUseCase(
              gh<_i114.SessionStorage>(),
              gh<_i163.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i126.AudioStorageRepository>(),
              gh<_i198.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i241.AppFlowBloc>(() => _i241.AppFlowBloc(
          sessionService: gh<_i221.SessionService>(),
          getAuthStateUseCase: gh<_i141.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i220.SessionCleanupService>(),
        ));
    gh.factory<_i242.AudioContextBloc>(() => _i242.AudioContextBloc(
        loadTrackContextUseCase: gh<_i209.LoadTrackContextUseCase>()));
    gh.factory<_i243.AudioPlayerService>(() => _i243.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i27.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i213.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i212.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i217.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i44.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i56.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i65.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i62.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i63.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i58.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i69.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i68.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i60.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i59.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i57.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i218.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i244.AuthBloc>(() => _i244.AuthBloc(
          signIn: gh<_i223.SignInUseCase>(),
          signUp: gh<_i160.SignUpUseCase>(),
          googleSignIn: gh<_i204.GoogleSignInUseCase>(),
          appleSignIn: gh<_i181.AppleSignInUseCase>(),
          signOut: gh<_i159.SignOutUseCase>(),
        ));
    gh.factory<_i245.CacheManagementBloc>(() => _i245.CacheManagementBloc(
          deleteOne: gh<_i139.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i173.WatchStorageUsageUseCase>(),
          getStats: gh<_i200.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i192.CleanupCacheUseCase>(),
          watchBundles: gh<_i232.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i246.DeleteAudioCommentUseCase>(
        () => _i246.DeleteAudioCommentUseCase(
              gh<_i214.ProjectCommentService>(),
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
            ));
    gh.lazySingleton<_i247.DeleteAudioTrack>(() => _i247.DeleteAudioTrack(
          gh<_i114.SessionStorage>(),
          gh<_i155.ProjectsRepository>(),
          gh<_i215.ProjectTrackService>(),
          gh<_i163.TrackVersionRepository>(),
          gh<_i177.WaveformRepository>(),
          gh<_i126.AudioStorageRepository>(),
          gh<_i183.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i248.DeleteProjectUseCase>(
        () => _i248.DeleteProjectUseCase(
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
              gh<_i215.ProjectTrackService>(),
              gh<_i247.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i249.EditAudioTrackUseCase>(
        () => _i249.EditAudioTrackUseCase(
              gh<_i215.ProjectTrackService>(),
              gh<_i155.ProjectsRepository>(),
            ));
    gh.factory<_i250.ManageCollaboratorsBloc>(
        () => _i250.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i157.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i166.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i208.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i197.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i239.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i172.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.lazySingleton<_i251.PlayVoiceMemoUseCase>(
        () => _i251.PlayVoiceMemoUseCase(gh<_i243.AudioPlayerService>()));
    gh.factory<_i252.PlaylistBloc>(
        () => _i252.PlaylistBloc(gh<_i234.WatchProjectPlaylistUseCase>()));
    gh.factory<_i253.ProjectDetailBloc>(() => _i253.ProjectDetailBloc(
        watchProjectDetail: gh<_i233.WatchProjectDetailUseCase>()));
    gh.factory<_i254.ProjectInvitationActorBloc>(
        () => _i254.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i219.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i179.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i195.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i136.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i197.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i255.ProjectsBloc>(() => _i255.ProjectsBloc(
          createProject: gh<_i193.CreateProjectUseCase>(),
          updateProject: gh<_i167.UpdateProjectUseCase>(),
          deleteProject: gh<_i248.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i170.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i256.SyncBloc>(() => _i256.SyncBloc(
          gh<_i228.TriggerStartupSyncUseCase>(),
          gh<_i165.TriggerUpstreamSyncUseCase>(),
          gh<_i227.TriggerForegroundSyncUseCase>(),
          gh<_i226.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i257.SyncStatusCubit>(() => _i257.SyncStatusCubit(
          gh<_i115.SyncStatusProvider>(),
          gh<_i110.PendingOperationsManager>(),
          gh<_i165.TriggerUpstreamSyncUseCase>(),
          gh<_i227.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i258.TrackVersionsBloc>(() => _i258.TrackVersionsBloc(
          gh<_i235.WatchTrackVersionsBundleUseCase>(),
          gh<_i222.SetActiveTrackVersionUseCase>(),
          gh<_i240.AddTrackVersionUseCase>(),
          gh<_i216.RenameTrackVersionUseCase>(),
          gh<_i196.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i259.UploadAudioTrackUseCase>(
        () => _i259.UploadAudioTrackUseCase(
              gh<_i215.ProjectTrackService>(),
              gh<_i155.ProjectsRepository>(),
              gh<_i114.SessionStorage>(),
              gh<_i240.AddTrackVersionUseCase>(),
              gh<_i187.AudioTrackRepository>(),
            ));
    gh.factory<_i260.AudioCommentBloc>(() => _i260.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i238.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i246.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i231.WatchAudioCommentsBundleUseCase>(),
          getCachedAudioCommentUseCase:
              gh<_i142.GetCachedAudioCommentUseCase>(),
        ));
    gh.factory<_i261.AudioPlayerBloc>(() => _i261.AudioPlayerBloc(
        audioPlayerService: gh<_i243.AudioPlayerService>()));
    gh.factory<_i262.AudioTrackBloc>(() => _i262.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i236.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i247.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i259.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i249.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i263.AppModule {}
