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
    as _i30;
import 'package:isar/isar.dart' as _i32;
import 'package:shared_preferences/shared_preferences.dart' as _i63;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i121;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i18;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i229;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i230;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i145;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i149;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i152;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i251;
import 'package:trackflow/core/audio/data/unified_audio_service.dart' as _i133;
import 'package:trackflow/core/audio/domain/audio_file_repository.dart'
    as _i132;
import 'package:trackflow/core/di/app_module.dart' as _i278;
import 'package:trackflow/core/infrastructure/domain/directory_service.dart'
    as _i15;
import 'package:trackflow/core/infrastructure/services/directory_service_impl.dart'
    as _i16;
import 'package:trackflow/core/network/network_state_manager.dart' as _i38;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i40;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i42;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i27;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i41;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i43;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i94;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i96;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i99;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i154;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i112;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i113;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i44;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i155;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i156;
import 'package:trackflow/core/services/deep_link_service.dart' as _i13;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i17;
import 'package:trackflow/core/session/current_user_service.dart' as _i146;
import 'package:trackflow/core/storage/data/image_storage_repository_impl.dart'
    as _i25;
import 'package:trackflow/core/storage/domain/image_storage_repository.dart'
    as _i24;
import 'package:trackflow/core/storage/services/image_compression_service.dart'
    as _i23;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i47;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i48;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i191;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i136;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i45;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i119;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i233;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i127;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i131;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i140;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i26;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i117;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i69;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i122;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i234;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i235;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i236;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i173;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i269;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i270;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i90;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i134;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i143;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i151;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i166;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i183;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i180;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i271;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i86;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i87;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i101;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i193;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i102;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i192;
import 'package:trackflow/features/audio_comment/domain/services/comment_audio_playback_service.dart'
    as _i10;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i223;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i248;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i258;
import 'package:trackflow/features/audio_comment/domain/usecases/get_cached_audio_comment_usecase.dart'
    as _i150;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i240;
import 'package:trackflow/features/audio_comment/infrastructure/services/comment_audio_playback_service_impl.dart'
    as _i11;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i275;
import 'package:trackflow/features/audio_comment/presentation/cubit/comment_audio_cubit.dart'
    as _i92;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i218;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i252;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i253;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i194;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i29;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i46;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i221;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i222;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i226;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i227;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i61;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i64;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i65;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i70;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i71;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i50;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i195;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i276;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i55;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i91;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i68;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i56;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i120;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i88;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i89;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i105;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i197;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i106;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i196;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i224;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i259;
import 'package:trackflow/features/audio_track/domain/usecases/download_track_usecase.dart'
    as _i261;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i262;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i273;
import 'package:trackflow/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart'
    as _i238;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i246;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i277;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i169;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i137;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i139;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i85;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i100;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i138;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i190;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i213;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i232;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i167;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i168;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i254;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i142;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i199;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i198;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i201;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i147;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i209;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i241;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i182;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i255;
import 'package:trackflow/features/dashboard/domain/usecases/watch_dashboard_bundle_usecase.dart'
    as _i242;
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i257;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i109;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i31;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i111;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i110;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i188;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i144;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i204;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i153;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i114;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i115;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i228;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i267;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i162;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i33;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i34;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i36;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i35;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i93;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i148;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i98;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i57;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i75;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i219;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i249;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i189;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i206;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i216;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i217;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i165;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i174;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i181;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i263;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i37;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i28;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i116;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i159;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i157;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i220;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i51;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i52;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i161;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i160;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i244;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i265;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i243;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i266;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i54;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i53;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i107;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i164;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i108;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i163;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i202;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i260;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i210;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i175;
import 'package:trackflow/features/projects/domain/usecases/upload_cover_art_usecase.dart'
    as _i176;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i179;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i268;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i72;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i170;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i214;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i172;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i215;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i171;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i250;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i205;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i208;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i211;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i225;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i231;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i245;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i184;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i272;
import 'package:trackflow/features/track_version/presentation/cubit/version_selector_cubit.dart'
    as _i76;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i103;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i125;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i178;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i126;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i104;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i177;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i124;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i200;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i203;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i237;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i185;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i129;
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart'
    as _i256;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart'
    as _i239;
import 'package:trackflow/features/voice_memos/data/datasources/voice_memo_local_datasource.dart'
    as _i77;
import 'package:trackflow/features/voice_memos/data/repositories/voice_memo_repository_impl.dart'
    as _i79;
import 'package:trackflow/features/voice_memos/domain/repositories/voice_memo_repository.dart'
    as _i78;
import 'package:trackflow/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart'
    as _i95;
import 'package:trackflow/features/voice_memos/domain/usecases/delete_voice_memo_usecase.dart'
    as _i97;
import 'package:trackflow/features/voice_memos/domain/usecases/play_voice_memo_usecase.dart'
    as _i264;
import 'package:trackflow/features/voice_memos/domain/usecases/update_voice_memo_usecase.dart'
    as _i123;
import 'package:trackflow/features/voice_memos/domain/usecases/watch_voice_memos_usecase.dart'
    as _i80;
import 'package:trackflow/features/voice_memos/presentation/bloc/voice_memo_bloc.dart'
    as _i274;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i83;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i84;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i187;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i82;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i130;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i186;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i81;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i207;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i212;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i247;

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
    gh.lazySingleton<_i23.ImageCompressionService>(
        () => _i23.ImageCompressionService());
    gh.lazySingleton<_i24.ImageStorageRepository>(
        () => _i25.ImageStorageRepositoryImpl(
              gh<_i21.FirebaseStorage>(),
              gh<_i15.DirectoryService>(),
              gh<_i23.ImageCompressionService>(),
            ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i27.Notification>>(
        () => _i28.NotificationIncrementalSyncService());
    gh.factory<_i29.InitializeAudioPlayerUseCase>(() =>
        _i29.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i30.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i31.InvitationRemoteDataSource>(() =>
        _i31.FirestoreInvitationRemoteDataSource(gh<_i20.FirebaseFirestore>()));
    await gh.factoryAsync<_i32.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i33.MagicLinkLocalDataSource>(
        () => _i33.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i34.MagicLinkRemoteDataSource>(
        () => _i34.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i20.FirebaseFirestore>(),
              deepLinkService: gh<_i13.DeepLinkService>(),
            ));
    gh.factory<_i35.MagicLinkRepository>(() =>
        _i36.MagicLinkRepositoryImp(gh<_i34.MagicLinkRemoteDataSource>()));
    gh.factory<_i37.NavigationCubit>(() => _i37.NavigationCubit());
    gh.lazySingleton<_i38.NetworkStateManager>(() => _i38.NetworkStateManager(
          gh<_i30.InternetConnectionChecker>(),
          gh<_i12.Connectivity>(),
        ));
    gh.lazySingleton<_i39.NotificationLocalDataSource>(
        () => _i39.IsarNotificationLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i40.NotificationRemoteDataSource>(() =>
        _i40.FirestoreNotificationRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i41.NotificationRepository>(
        () => _i42.NotificationRepositoryImpl(
              localDataSource: gh<_i39.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i40.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i38.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i43.NotificationService>(
        () => _i43.NotificationService(gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i44.ObserveNotificationsUseCase>(() =>
        _i44.ObserveNotificationsUseCase(gh<_i41.NotificationRepository>()));
    gh.factory<_i45.OperationExecutorFactory>(
        () => _i45.OperationExecutorFactory());
    gh.factory<_i46.PauseAudioUseCase>(() => _i46.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i47.PendingOperationsLocalDataSource>(
        () => _i47.IsarPendingOperationsLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i48.PendingOperationsRepository>(() =>
        _i48.PendingOperationsRepositoryImpl(
            gh<_i47.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i49.PlaybackPersistenceRepository>(
        () => _i50.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i51.PlaylistLocalDataSource>(
        () => _i51.PlaylistLocalDataSourceImpl(gh<_i32.Isar>()));
    gh.lazySingleton<_i52.PlaylistRemoteDataSource>(
        () => _i52.PlaylistRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i53.ProjectRemoteDataSource>(() =>
        _i53.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i54.ProjectsLocalDataSource>(
        () => _i54.ProjectsLocalDataSourceImpl(gh<_i32.Isar>()));
    gh.lazySingleton<_i55.RecordingService>(
        () => _i56.PlatformRecordingService());
    gh.lazySingleton<_i57.ResendMagicLinkUseCase>(
        () => _i57.ResendMagicLinkUseCase(gh<_i35.MagicLinkRepository>()));
    gh.factory<_i58.ResumeAudioUseCase>(() => _i58.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.SavePlaybackStateUseCase>(
        () => _i59.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i49.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i60.SeekAudioUseCase>(() =>
        _i60.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i61.SetPlaybackSpeedUseCase>(() => _i61.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i62.SetVolumeUseCase>(() =>
        _i62.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i63.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i64.SkipToNextUseCase>(() => _i64.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i65.SkipToPreviousUseCase>(() => _i65.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i66.StartRecordingUseCase>(
        () => _i66.StartRecordingUseCase(gh<_i55.RecordingService>()));
    gh.factory<_i67.StopAudioUseCase>(() =>
        _i67.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i68.StopRecordingUseCase>(
        () => _i68.StopRecordingUseCase(gh<_i55.RecordingService>()));
    gh.lazySingleton<_i69.SyncCoordinator>(
        () => _i69.SyncCoordinator(gh<_i63.SharedPreferences>()));
    gh.factory<_i70.ToggleRepeatModeUseCase>(() => _i70.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i71.ToggleShuffleUseCase>(() => _i71.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i72.TrackVersionLocalDataSource>(
        () => _i72.IsarTrackVersionLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i73.UserProfileLocalDataSource>(
        () => _i73.IsarUserProfileLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i74.UserProfileRemoteDataSource>(
        () => _i74.UserProfileRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i21.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i75.ValidateMagicLinkUseCase>(
        () => _i75.ValidateMagicLinkUseCase(gh<_i35.MagicLinkRepository>()));
    gh.factory<_i76.VersionSelectorCubit>(() => _i76.VersionSelectorCubit());
    gh.lazySingleton<_i77.VoiceMemoLocalDataSource>(
        () => _i77.IsarVoiceMemoLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i78.VoiceMemoRepository>(
        () => _i79.VoiceMemoRepositoryImpl(
              gh<_i77.VoiceMemoLocalDataSource>(),
              gh<_i15.DirectoryService>(),
            ));
    gh.lazySingleton<_i80.WatchVoiceMemosUseCase>(
        () => _i80.WatchVoiceMemosUseCase(gh<_i78.VoiceMemoRepository>()));
    gh.factory<_i81.WaveformGeneratorService>(() =>
        _i82.JustWaveformGeneratorService(cacheDir: gh<_i14.Directory>()));
    gh.factory<_i83.WaveformLocalDataSource>(
        () => _i83.WaveformLocalDataSourceImpl(isar: gh<_i32.Isar>()));
    gh.lazySingleton<_i84.WaveformRemoteDataSource>(() =>
        _i84.FirebaseStorageWaveformRemoteDataSource(
            gh<_i21.FirebaseStorage>()));
    gh.lazySingleton<_i85.AppleAuthService>(
        () => _i85.AppleAuthService(gh<_i19.FirebaseAuth>()));
    gh.lazySingleton<_i86.AudioCommentLocalDataSource>(
        () => _i86.IsarAudioCommentLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i87.AudioCommentRemoteDataSource>(() =>
        _i87.FirebaseAudioCommentRemoteDataSource(
            gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i88.AudioTrackLocalDataSource>(
        () => _i88.IsarAudioTrackLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i89.AudioTrackRemoteDataSource>(() =>
        _i89.AudioTrackRemoteDataSourceImpl(gh<_i20.FirebaseFirestore>()));
    gh.lazySingleton<_i90.CacheStorageLocalDataSource>(
        () => _i90.CacheStorageLocalDataSourceImpl(gh<_i32.Isar>()));
    gh.factory<_i91.CancelRecordingUseCase>(
        () => _i91.CancelRecordingUseCase(gh<_i55.RecordingService>()));
    gh.factory<_i92.CommentAudioCubit>(
        () => _i92.CommentAudioCubit(gh<_i10.CommentAudioPlaybackService>()));
    gh.lazySingleton<_i93.ConsumeMagicLinkUseCase>(
        () => _i93.ConsumeMagicLinkUseCase(gh<_i35.MagicLinkRepository>()));
    gh.factory<_i94.CreateNotificationUseCase>(() =>
        _i94.CreateNotificationUseCase(gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i95.CreateVoiceMemoUseCase>(
        () => _i95.CreateVoiceMemoUseCase(
              gh<_i78.VoiceMemoRepository>(),
              gh<_i81.WaveformGeneratorService>(),
            ));
    gh.factory<_i96.DeleteNotificationUseCase>(() =>
        _i96.DeleteNotificationUseCase(gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i97.DeleteVoiceMemoUseCase>(
        () => _i97.DeleteVoiceMemoUseCase(gh<_i78.VoiceMemoRepository>()));
    gh.lazySingleton<_i98.GetMagicLinkStatusUseCase>(
        () => _i98.GetMagicLinkStatusUseCase(gh<_i35.MagicLinkRepository>()));
    gh.lazySingleton<_i99.GetUnreadNotificationsCountUseCase>(() =>
        _i99.GetUnreadNotificationsCountUseCase(
            gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i100.GoogleAuthService>(() => _i100.GoogleAuthService(
          gh<_i22.GoogleSignIn>(),
          gh<_i19.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i101.AudioCommentDTO>>(
        () => _i102.AudioCommentIncrementalSyncService(
              gh<_i87.AudioCommentRemoteDataSource>(),
              gh<_i86.AudioCommentLocalDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i103.UserProfileDTO>>(
        () => _i104.UserProfileIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i105.AudioTrackDTO>>(
        () => _i106.AudioTrackIncrementalSyncService(
              gh<_i89.AudioTrackRemoteDataSource>(),
              gh<_i88.AudioTrackLocalDataSource>(),
              gh<_i54.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i107.ProjectDTO>>(
        () => _i108.ProjectIncrementalSyncService(
              gh<_i53.ProjectRemoteDataSource>(),
              gh<_i54.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i109.InvitationLocalDataSource>(
        () => _i109.IsarInvitationLocalDataSource(gh<_i32.Isar>()));
    gh.lazySingleton<_i110.InvitationRepository>(
        () => _i111.InvitationRepositoryImpl(
              localDataSource: gh<_i109.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i31.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i38.NetworkStateManager>(),
            ));
    gh.factory<_i112.MarkAsUnreadUseCase>(
        () => _i112.MarkAsUnreadUseCase(gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i113.MarkNotificationAsReadUseCase>(() =>
        _i113.MarkNotificationAsReadUseCase(gh<_i41.NotificationRepository>()));
    gh.lazySingleton<_i114.ObservePendingInvitationsUseCase>(() =>
        _i114.ObservePendingInvitationsUseCase(
            gh<_i110.InvitationRepository>()));
    gh.lazySingleton<_i115.ObserveSentInvitationsUseCase>(() =>
        _i115.ObserveSentInvitationsUseCase(gh<_i110.InvitationRepository>()));
    gh.lazySingleton<_i116.OnboardingStateLocalDataSource>(() =>
        _i116.OnboardingStateLocalDataSourceImpl(gh<_i63.SharedPreferences>()));
    gh.lazySingleton<_i117.PendingOperationsManager>(
        () => _i117.PendingOperationsManager(
              gh<_i48.PendingOperationsRepository>(),
              gh<_i38.NetworkStateManager>(),
              gh<_i45.OperationExecutorFactory>(),
            ));
    gh.factory<_i118.PlaylistOperationExecutor>(() =>
        _i118.PlaylistOperationExecutor(gh<_i52.PlaylistRemoteDataSource>()));
    gh.factory<_i119.ProjectOperationExecutor>(() =>
        _i119.ProjectOperationExecutor(gh<_i53.ProjectRemoteDataSource>()));
    gh.factory<_i120.RecordingBloc>(() => _i120.RecordingBloc(
          gh<_i66.StartRecordingUseCase>(),
          gh<_i68.StopRecordingUseCase>(),
          gh<_i91.CancelRecordingUseCase>(),
          gh<_i55.RecordingService>(),
        ));
    gh.lazySingleton<_i121.SessionStorage>(
        () => _i121.SessionStorageImpl(prefs: gh<_i63.SharedPreferences>()));
    gh.factory<_i122.SyncStatusProvider>(() => _i122.SyncStatusProvider(
          syncCoordinator: gh<_i69.SyncCoordinator>(),
          pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i123.UpdateVoiceMemoUseCase>(
        () => _i123.UpdateVoiceMemoUseCase(gh<_i78.VoiceMemoRepository>()));
    gh.lazySingleton<_i124.UserProfileCacheRepository>(
        () => _i125.UserProfileCacheRepositoryImpl(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i38.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i126.UserProfileCollaboratorIncrementalSyncService>(
        () => _i126.UserProfileCollaboratorIncrementalSyncService(
              gh<_i74.UserProfileRemoteDataSource>(),
              gh<_i73.UserProfileLocalDataSource>(),
              gh<_i54.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i127.UserProfileOperationExecutor>(() =>
        _i127.UserProfileOperationExecutor(
            gh<_i74.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i128.WatchTrackUploadStatusUseCase>(() =>
        _i128.WatchTrackUploadStatusUseCase(
            gh<_i117.PendingOperationsManager>()));
    gh.lazySingleton<_i129.WatchUserProfilesUseCase>(() =>
        _i129.WatchUserProfilesUseCase(gh<_i124.UserProfileCacheRepository>()));
    gh.lazySingleton<_i130.WaveformIncrementalSyncService>(
        () => _i130.WaveformIncrementalSyncService(
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i83.WaveformLocalDataSource>(),
              gh<_i84.WaveformRemoteDataSource>(),
            ));
    gh.factory<_i131.WaveformOperationExecutor>(() =>
        _i131.WaveformOperationExecutor(gh<_i84.WaveformRemoteDataSource>()));
    gh.lazySingleton<_i132.AudioFileRepository>(
        () => _i133.AudioFileRepositoryImpl(
              gh<_i21.FirebaseStorage>(),
              gh<_i15.DirectoryService>(),
              gh<_i90.CacheStorageLocalDataSource>(),
              httpClient: gh<_i9.Client>(),
            ));
    gh.lazySingleton<_i134.AudioStorageRepository>(
        () => _i135.AudioStorageRepositoryImpl(
              localDataSource: gh<_i90.CacheStorageLocalDataSource>(),
              directoryService: gh<_i15.DirectoryService>(),
            ));
    gh.factory<_i136.AudioTrackOperationExecutor>(
        () => _i136.AudioTrackOperationExecutor(
              gh<_i89.AudioTrackRemoteDataSource>(),
              gh<_i88.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i137.AuthRemoteDataSource>(
        () => _i137.AuthRemoteDataSourceImpl(
              gh<_i19.FirebaseAuth>(),
              gh<_i100.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i138.AuthRepository>(() => _i139.AuthRepositoryImpl(
          remote: gh<_i137.AuthRemoteDataSource>(),
          sessionStorage: gh<_i121.SessionStorage>(),
          networkStateManager: gh<_i38.NetworkStateManager>(),
          googleAuthService: gh<_i100.GoogleAuthService>(),
          appleAuthService: gh<_i85.AppleAuthService>(),
        ));
    gh.lazySingleton<_i140.BackgroundSyncCoordinator>(
        () => _i141.BackgroundSyncCoordinatorImpl(
              gh<_i38.NetworkStateManager>(),
              gh<_i69.SyncCoordinator>(),
              gh<_i117.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i142.CacheManagementLocalDataSource>(
        () => _i142.CacheManagementLocalDataSourceImpl(
              local: gh<_i90.CacheStorageLocalDataSource>(),
              directoryService: gh<_i15.DirectoryService>(),
            ));
    gh.factory<_i143.CacheTrackUseCase>(() => _i143.CacheTrackUseCase(
          gh<_i132.AudioFileRepository>(),
          gh<_i134.AudioStorageRepository>(),
          gh<_i15.DirectoryService>(),
        ));
    gh.lazySingleton<_i144.CancelInvitationUseCase>(
        () => _i144.CancelInvitationUseCase(gh<_i110.InvitationRepository>()));
    gh.factory<_i145.CheckAuthenticationStatusUseCase>(() =>
        _i145.CheckAuthenticationStatusUseCase(gh<_i138.AuthRepository>()));
    gh.factory<_i146.CurrentUserService>(
        () => _i146.CurrentUserService(gh<_i121.SessionStorage>()));
    gh.factory<_i147.DeleteCachedAudioUseCase>(() =>
        _i147.DeleteCachedAudioUseCase(gh<_i134.AudioStorageRepository>()));
    gh.lazySingleton<_i148.GenerateMagicLinkUseCase>(
        () => _i148.GenerateMagicLinkUseCase(
              gh<_i35.MagicLinkRepository>(),
              gh<_i138.AuthRepository>(),
            ));
    gh.lazySingleton<_i149.GetAuthStateUseCase>(
        () => _i149.GetAuthStateUseCase(gh<_i138.AuthRepository>()));
    gh.factory<_i150.GetCachedAudioCommentUseCase>(
        () => _i150.GetCachedAudioCommentUseCase(
              gh<_i134.AudioStorageRepository>(),
              gh<_i132.AudioFileRepository>(),
            ));
    gh.factory<_i151.GetCachedTrackPathUseCase>(() =>
        _i151.GetCachedTrackPathUseCase(gh<_i134.AudioStorageRepository>()));
    gh.factory<_i152.GetCurrentUserUseCase>(
        () => _i152.GetCurrentUserUseCase(gh<_i138.AuthRepository>()));
    gh.lazySingleton<_i153.GetPendingInvitationsCountUseCase>(() =>
        _i153.GetPendingInvitationsCountUseCase(
            gh<_i110.InvitationRepository>()));
    gh.factory<_i154.MarkAllNotificationsAsReadUseCase>(
        () => _i154.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i41.NotificationRepository>(),
              currentUserService: gh<_i146.CurrentUserService>(),
            ));
    gh.factory<_i155.NotificationActorBloc>(() => _i155.NotificationActorBloc(
          createNotificationUseCase: gh<_i94.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i113.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i112.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i154.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i96.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i156.NotificationWatcherBloc>(
        () => _i156.NotificationWatcherBloc(
              notificationRepository: gh<_i41.NotificationRepository>(),
              currentUserService: gh<_i146.CurrentUserService>(),
            ));
    gh.lazySingleton<_i157.OnboardingRepository>(() =>
        _i158.OnboardingRepositoryImpl(
            gh<_i116.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i159.OnboardingUseCase>(
        () => _i159.OnboardingUseCase(gh<_i157.OnboardingRepository>()));
    gh.lazySingleton<_i160.PlaylistRepository>(
        () => _i161.PlaylistRepositoryImpl(
              localDataSource: gh<_i51.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i140.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
            ));
    gh.factory<_i162.ProjectInvitationWatcherBloc>(
        () => _i162.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i110.InvitationRepository>(),
              currentUserService: gh<_i146.CurrentUserService>(),
            ));
    gh.lazySingleton<_i163.ProjectsRepository>(
        () => _i164.ProjectsRepositoryImpl(
              localDataSource: gh<_i54.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i140.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i165.RemoveCollaboratorUseCase>(
        () => _i165.RemoveCollaboratorUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.factory<_i166.RemoveTrackCacheUseCase>(() =>
        _i166.RemoveTrackCacheUseCase(gh<_i134.AudioStorageRepository>()));
    gh.lazySingleton<_i167.SignOutUseCase>(
        () => _i167.SignOutUseCase(gh<_i138.AuthRepository>()));
    gh.lazySingleton<_i168.SignUpUseCase>(
        () => _i168.SignUpUseCase(gh<_i138.AuthRepository>()));
    gh.factory<_i169.TrackUploadStatusCubit>(() => _i169.TrackUploadStatusCubit(
        gh<_i128.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i170.TrackVersionRemoteDataSource>(
        () => _i170.TrackVersionRemoteDataSourceImpl(
              gh<_i20.FirebaseFirestore>(),
              gh<_i132.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i171.TrackVersionRepository>(
        () => _i172.TrackVersionRepositoryImpl(
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i140.BackgroundSyncCoordinator>(),
              gh<_i117.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i173.TriggerUpstreamSyncUseCase>(() =>
        _i173.TriggerUpstreamSyncUseCase(
            gh<_i140.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i174.UpdateCollaboratorRoleUseCase>(
        () => _i174.UpdateCollaboratorRoleUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i175.UpdateProjectUseCase>(
        () => _i175.UpdateProjectUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i176.UploadCoverArtUseCase>(
        () => _i176.UploadCoverArtUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i24.ImageStorageRepository>(),
              gh<_i15.DirectoryService>(),
            ));
    gh.lazySingleton<_i177.UserProfileRepository>(
        () => _i178.UserProfileRepositoryImpl(
              localDataSource: gh<_i73.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i74.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i38.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i140.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
              firestore: gh<_i20.FirebaseFirestore>(),
              sessionStorage: gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i179.WatchAllProjectsUseCase>(
        () => _i179.WatchAllProjectsUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.factory<_i180.WatchCachedAudiosUseCase>(() =>
        _i180.WatchCachedAudiosUseCase(gh<_i134.AudioStorageRepository>()));
    gh.lazySingleton<_i181.WatchCollaboratorsBundleUseCase>(
        () => _i181.WatchCollaboratorsBundleUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i129.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i182.WatchStorageUsageUseCase>(() =>
        _i182.WatchStorageUsageUseCase(gh<_i134.AudioStorageRepository>()));
    gh.factory<_i183.WatchTrackCacheStatusUseCase>(() =>
        _i183.WatchTrackCacheStatusUseCase(gh<_i134.AudioStorageRepository>()));
    gh.lazySingleton<_i184.WatchTrackVersionsUseCase>(() =>
        _i184.WatchTrackVersionsUseCase(gh<_i171.TrackVersionRepository>()));
    gh.lazySingleton<_i185.WatchUserProfileUseCase>(
        () => _i185.WatchUserProfileUseCase(
              gh<_i177.UserProfileRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.factory<_i186.WaveformRepository>(() => _i187.WaveformRepositoryImpl(
          localDataSource: gh<_i83.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i84.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i140.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i188.AcceptInvitationUseCase>(
        () => _i188.AcceptInvitationUseCase(
              invitationRepository: gh<_i110.InvitationRepository>(),
              projectRepository: gh<_i163.ProjectsRepository>(),
              userProfileRepository: gh<_i177.UserProfileRepository>(),
              notificationService: gh<_i43.NotificationService>(),
            ));
    gh.lazySingleton<_i189.AddCollaboratorToProjectUseCase>(
        () => _i189.AddCollaboratorToProjectUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i190.AppleSignInUseCase>(
        () => _i190.AppleSignInUseCase(gh<_i138.AuthRepository>()));
    gh.factory<_i191.AudioCommentOperationExecutor>(
        () => _i191.AudioCommentOperationExecutor(
              gh<_i87.AudioCommentRemoteDataSource>(),
              gh<_i132.AudioFileRepository>(),
            ));
    gh.lazySingleton<_i192.AudioCommentRepository>(
        () => _i193.AudioCommentRepositoryImpl(
              localDataSource: gh<_i86.AudioCommentLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i140.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i117.PendingOperationsManager>(),
              trackVersionRepository: gh<_i171.TrackVersionRepository>(),
              audioStorageRepository: gh<_i134.AudioStorageRepository>(),
            ));
    gh.factory<_i194.AudioSourceResolver>(() => _i195.AudioSourceResolverImpl(
          gh<_i134.AudioStorageRepository>(),
          gh<_i132.AudioFileRepository>(),
          gh<_i15.DirectoryService>(),
        ));
    gh.lazySingleton<_i196.AudioTrackRepository>(
        () => _i197.AudioTrackRepositoryImpl(
              gh<_i88.AudioTrackLocalDataSource>(),
              gh<_i140.BackgroundSyncCoordinator>(),
              gh<_i117.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i198.CacheMaintenanceService>(() =>
        _i199.CacheMaintenanceServiceImpl(
            gh<_i142.CacheManagementLocalDataSource>()));
    gh.factory<_i200.CheckProfileCompletenessUseCase>(() =>
        _i200.CheckProfileCompletenessUseCase(
            gh<_i177.UserProfileRepository>()));
    gh.factory<_i201.CleanupCacheUseCase>(
        () => _i201.CleanupCacheUseCase(gh<_i198.CacheMaintenanceService>()));
    gh.lazySingleton<_i202.CreateProjectUseCase>(
        () => _i202.CreateProjectUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.factory<_i203.CreateUserProfileUseCase>(
        () => _i203.CreateUserProfileUseCase(
              gh<_i177.UserProfileRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i204.DeclineInvitationUseCase>(
        () => _i204.DeclineInvitationUseCase(
              invitationRepository: gh<_i110.InvitationRepository>(),
              projectRepository: gh<_i163.ProjectsRepository>(),
              userProfileRepository: gh<_i177.UserProfileRepository>(),
              notificationService: gh<_i43.NotificationService>(),
            ));
    gh.lazySingleton<_i205.DeleteTrackVersionUseCase>(
        () => _i205.DeleteTrackVersionUseCase(
              gh<_i171.TrackVersionRepository>(),
              gh<_i186.WaveformRepository>(),
              gh<_i192.AudioCommentRepository>(),
              gh<_i134.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i206.FindUserByEmailUseCase>(
        () => _i206.FindUserByEmailUseCase(gh<_i177.UserProfileRepository>()));
    gh.factory<_i207.GenerateAndStoreWaveform>(
        () => _i207.GenerateAndStoreWaveform(
              gh<_i186.WaveformRepository>(),
              gh<_i81.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i208.GetActiveVersionUseCase>(() =>
        _i208.GetActiveVersionUseCase(gh<_i171.TrackVersionRepository>()));
    gh.factory<_i209.GetCacheStorageStatsUseCase>(() =>
        _i209.GetCacheStorageStatsUseCase(gh<_i198.CacheMaintenanceService>()));
    gh.lazySingleton<_i210.GetProjectByIdUseCase>(
        () => _i210.GetProjectByIdUseCase(gh<_i163.ProjectsRepository>()));
    gh.lazySingleton<_i211.GetVersionByIdUseCase>(
        () => _i211.GetVersionByIdUseCase(gh<_i171.TrackVersionRepository>()));
    gh.factory<_i212.GetWaveformByVersion>(
        () => _i212.GetWaveformByVersion(gh<_i186.WaveformRepository>()));
    gh.lazySingleton<_i213.GoogleSignInUseCase>(() => _i213.GoogleSignInUseCase(
          gh<_i138.AuthRepository>(),
          gh<_i177.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i26.IncrementalSyncService<_i214.TrackVersionDTO>>(
        () => _i215.TrackVersionIncrementalSyncService(
              gh<_i170.TrackVersionRemoteDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
              gh<_i88.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i216.JoinProjectWithIdUseCase>(
        () => _i216.JoinProjectWithIdUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i217.LeaveProjectUseCase>(() => _i217.LeaveProjectUseCase(
          gh<_i163.ProjectsRepository>(),
          gh<_i121.SessionStorage>(),
        ));
    gh.factory<_i218.LoadTrackContextUseCase>(
        () => _i218.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i196.AudioTrackRepository>(),
              trackVersionRepository: gh<_i171.TrackVersionRepository>(),
              userProfileRepository: gh<_i177.UserProfileRepository>(),
              projectsRepository: gh<_i163.ProjectsRepository>(),
            ));
    gh.factory<_i219.MagicLinkBloc>(() => _i219.MagicLinkBloc(
          generateMagicLink: gh<_i148.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i75.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i93.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i57.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i98.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i216.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i138.AuthRepository>(),
        ));
    gh.factory<_i220.OnboardingBloc>(() => _i220.OnboardingBloc(
          onboardingUseCase: gh<_i159.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i152.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i221.PlayPlaylistUseCase>(() => _i221.PlayPlaylistUseCase(
          playlistRepository: gh<_i160.PlaylistRepository>(),
          audioTrackRepository: gh<_i196.AudioTrackRepository>(),
          trackVersionRepository: gh<_i171.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i134.AudioStorageRepository>(),
        ));
    gh.factory<_i222.PlayVersionUseCase>(() => _i222.PlayVersionUseCase(
          audioTrackRepository: gh<_i196.AudioTrackRepository>(),
          audioStorageRepository: gh<_i134.AudioStorageRepository>(),
          trackVersionRepository: gh<_i171.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i223.ProjectCommentService>(
        () => _i223.ProjectCommentService(gh<_i192.AudioCommentRepository>()));
    gh.lazySingleton<_i224.ProjectTrackService>(
        () => _i224.ProjectTrackService(gh<_i196.AudioTrackRepository>()));
    gh.lazySingleton<_i225.RenameTrackVersionUseCase>(() =>
        _i225.RenameTrackVersionUseCase(gh<_i171.TrackVersionRepository>()));
    gh.factory<_i226.ResolveTrackVersionUseCase>(
        () => _i226.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i196.AudioTrackRepository>(),
              trackVersionRepository: gh<_i171.TrackVersionRepository>(),
            ));
    gh.factory<_i227.RestorePlaybackStateUseCase>(
        () => _i227.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i49.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i196.AudioTrackRepository>(),
              audioStorageRepository: gh<_i134.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i228.SendInvitationUseCase>(
        () => _i228.SendInvitationUseCase(
              invitationRepository: gh<_i110.InvitationRepository>(),
              notificationService: gh<_i43.NotificationService>(),
              findUserByEmail: gh<_i206.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i35.MagicLinkRepository>(),
              currentUserService: gh<_i146.CurrentUserService>(),
            ));
    gh.factory<_i229.SessionCleanupService>(() => _i229.SessionCleanupService(
          userProfileRepository: gh<_i177.UserProfileRepository>(),
          projectsRepository: gh<_i163.ProjectsRepository>(),
          audioTrackRepository: gh<_i196.AudioTrackRepository>(),
          audioCommentRepository: gh<_i192.AudioCommentRepository>(),
          invitationRepository: gh<_i110.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i49.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i121.SessionStorage>(),
          pendingOperationsRepository: gh<_i48.PendingOperationsRepository>(),
          waveformRepository: gh<_i186.WaveformRepository>(),
          trackVersionRepository: gh<_i171.TrackVersionRepository>(),
          syncCoordinator: gh<_i69.SyncCoordinator>(),
        ));
    gh.factory<_i230.SessionService>(() => _i230.SessionService(
          checkAuthUseCase: gh<_i145.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i152.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i159.OnboardingUseCase>(),
          profileUseCase: gh<_i200.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i231.SetActiveTrackVersionUseCase>(() =>
        _i231.SetActiveTrackVersionUseCase(gh<_i196.AudioTrackRepository>()));
    gh.lazySingleton<_i232.SignInUseCase>(() => _i232.SignInUseCase(
          gh<_i138.AuthRepository>(),
          gh<_i177.UserProfileRepository>(),
        ));
    gh.factory<_i233.TrackVersionOperationExecutor>(
        () => _i233.TrackVersionOperationExecutor(
              gh<_i170.TrackVersionRemoteDataSource>(),
              gh<_i72.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i234.TriggerDownstreamSyncUseCase>(
        () => _i234.TriggerDownstreamSyncUseCase(
              gh<_i140.BackgroundSyncCoordinator>(),
              gh<_i230.SessionService>(),
            ));
    gh.lazySingleton<_i235.TriggerForegroundSyncUseCase>(
        () => _i235.TriggerForegroundSyncUseCase(
              gh<_i140.BackgroundSyncCoordinator>(),
              gh<_i230.SessionService>(),
            ));
    gh.lazySingleton<_i236.TriggerStartupSyncUseCase>(
        () => _i236.TriggerStartupSyncUseCase(
              gh<_i140.BackgroundSyncCoordinator>(),
              gh<_i230.SessionService>(),
            ));
    gh.factory<_i237.UpdateUserProfileUseCase>(
        () => _i237.UpdateUserProfileUseCase(
              gh<_i177.UserProfileRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i238.UploadTrackCoverArtUseCase>(
        () => _i238.UploadTrackCoverArtUseCase(
              gh<_i196.AudioTrackRepository>(),
              gh<_i24.ImageStorageRepository>(),
              gh<_i15.DirectoryService>(),
            ));
    gh.factory<_i239.UserProfilesBloc>(() => _i239.UserProfilesBloc(
          watchUserProfileUseCase: gh<_i185.WatchUserProfileUseCase>(),
          watchUserProfilesUseCase: gh<_i129.WatchUserProfilesUseCase>(),
        ));
    gh.lazySingleton<_i240.WatchAudioCommentsBundleUseCase>(
        () => _i240.WatchAudioCommentsBundleUseCase(
              gh<_i196.AudioTrackRepository>(),
              gh<_i192.AudioCommentRepository>(),
              gh<_i124.UserProfileCacheRepository>(),
            ));
    gh.factory<_i241.WatchCachedTrackBundlesUseCase>(
        () => _i241.WatchCachedTrackBundlesUseCase(
              gh<_i198.CacheMaintenanceService>(),
              gh<_i196.AudioTrackRepository>(),
              gh<_i177.UserProfileRepository>(),
              gh<_i163.ProjectsRepository>(),
              gh<_i171.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i242.WatchDashboardBundleUseCase>(
        () => _i242.WatchDashboardBundleUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i196.AudioTrackRepository>(),
              gh<_i192.AudioCommentRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i243.WatchProjectDetailUseCase>(
        () => _i243.WatchProjectDetailUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i196.AudioTrackRepository>(),
              gh<_i124.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i244.WatchProjectPlaylistUseCase>(
        () => _i244.WatchProjectPlaylistUseCase(
              gh<_i196.AudioTrackRepository>(),
              gh<_i171.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i245.WatchTrackVersionsBundleUseCase>(
        () => _i245.WatchTrackVersionsBundleUseCase(
              gh<_i196.AudioTrackRepository>(),
              gh<_i171.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i246.WatchTracksByProjectIdUseCase>(() =>
        _i246.WatchTracksByProjectIdUseCase(gh<_i196.AudioTrackRepository>()));
    gh.factory<_i247.WaveformBloc>(() => _i247.WaveformBloc(
          waveformRepository: gh<_i186.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i248.AddAudioCommentUseCase>(
        () => _i248.AddAudioCommentUseCase(
              gh<_i223.ProjectCommentService>(),
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i249.AddCollaboratorByEmailUseCase>(
        () => _i249.AddCollaboratorByEmailUseCase(
              gh<_i206.FindUserByEmailUseCase>(),
              gh<_i189.AddCollaboratorToProjectUseCase>(),
              gh<_i43.NotificationService>(),
            ));
    gh.lazySingleton<_i250.AddTrackVersionUseCase>(
        () => _i250.AddTrackVersionUseCase(
              gh<_i121.SessionStorage>(),
              gh<_i171.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i134.AudioStorageRepository>(),
              gh<_i207.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i251.AppFlowBloc>(() => _i251.AppFlowBloc(
          sessionService: gh<_i230.SessionService>(),
          getAuthStateUseCase: gh<_i149.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i229.SessionCleanupService>(),
        ));
    gh.factory<_i252.AudioContextBloc>(() => _i252.AudioContextBloc(
        loadTrackContextUseCase: gh<_i218.LoadTrackContextUseCase>()));
    gh.factory<_i253.AudioPlayerService>(() => _i253.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i29.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i222.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i221.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i226.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i46.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i58.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i67.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i64.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i65.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i60.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i71.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i70.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i62.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i61.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i59.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i227.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i254.AuthBloc>(() => _i254.AuthBloc(
          signIn: gh<_i232.SignInUseCase>(),
          signUp: gh<_i168.SignUpUseCase>(),
          googleSignIn: gh<_i213.GoogleSignInUseCase>(),
          appleSignIn: gh<_i190.AppleSignInUseCase>(),
          signOut: gh<_i167.SignOutUseCase>(),
        ));
    gh.factory<_i255.CacheManagementBloc>(() => _i255.CacheManagementBloc(
          deleteOne: gh<_i147.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i182.WatchStorageUsageUseCase>(),
          getStats: gh<_i209.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i201.CleanupCacheUseCase>(),
          watchBundles: gh<_i241.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.factory<_i256.CurrentUserBloc>(() => _i256.CurrentUserBloc(
          updateUserProfileUseCase: gh<_i237.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i203.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i185.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i200.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i152.GetCurrentUserUseCase>(),
          getAuthStateUseCase: gh<_i149.GetAuthStateUseCase>(),
        ));
    gh.factory<_i257.DashboardBloc>(() => _i257.DashboardBloc(
        watchDashboardBundleUseCase: gh<_i242.WatchDashboardBundleUseCase>()));
    gh.lazySingleton<_i258.DeleteAudioCommentUseCase>(
        () => _i258.DeleteAudioCommentUseCase(
              gh<_i223.ProjectCommentService>(),
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
            ));
    gh.lazySingleton<_i259.DeleteAudioTrack>(() => _i259.DeleteAudioTrack(
          gh<_i121.SessionStorage>(),
          gh<_i163.ProjectsRepository>(),
          gh<_i224.ProjectTrackService>(),
          gh<_i171.TrackVersionRepository>(),
          gh<_i186.WaveformRepository>(),
          gh<_i134.AudioStorageRepository>(),
          gh<_i192.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i260.DeleteProjectUseCase>(
        () => _i260.DeleteProjectUseCase(
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
              gh<_i224.ProjectTrackService>(),
              gh<_i259.DeleteAudioTrack>(),
            ));
    gh.factory<_i261.DownloadTrackUseCase>(() => _i261.DownloadTrackUseCase(
          audioStorageRepository: gh<_i134.AudioStorageRepository>(),
          audioTrackRepository: gh<_i196.AudioTrackRepository>(),
          trackVersionRepository: gh<_i171.TrackVersionRepository>(),
          projectsRepository: gh<_i163.ProjectsRepository>(),
          sessionService: gh<_i230.SessionService>(),
        ));
    gh.lazySingleton<_i262.EditAudioTrackUseCase>(
        () => _i262.EditAudioTrackUseCase(
              gh<_i224.ProjectTrackService>(),
              gh<_i163.ProjectsRepository>(),
            ));
    gh.factory<_i263.ManageCollaboratorsBloc>(
        () => _i263.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i165.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i174.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i217.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i206.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i249.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i181.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.lazySingleton<_i264.PlayVoiceMemoUseCase>(
        () => _i264.PlayVoiceMemoUseCase(gh<_i253.AudioPlayerService>()));
    gh.factory<_i265.PlaylistBloc>(
        () => _i265.PlaylistBloc(gh<_i244.WatchProjectPlaylistUseCase>()));
    gh.factory<_i266.ProjectDetailBloc>(() => _i266.ProjectDetailBloc(
        watchProjectDetail: gh<_i243.WatchProjectDetailUseCase>()));
    gh.factory<_i267.ProjectInvitationActorBloc>(
        () => _i267.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i228.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i188.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i204.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i144.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i206.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i268.ProjectsBloc>(() => _i268.ProjectsBloc(
          createProject: gh<_i202.CreateProjectUseCase>(),
          updateProject: gh<_i175.UpdateProjectUseCase>(),
          deleteProject: gh<_i260.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i179.WatchAllProjectsUseCase>(),
          uploadCoverArt: gh<_i176.UploadCoverArtUseCase>(),
        ));
    gh.factory<_i269.SyncBloc>(() => _i269.SyncBloc(
          gh<_i236.TriggerStartupSyncUseCase>(),
          gh<_i173.TriggerUpstreamSyncUseCase>(),
          gh<_i235.TriggerForegroundSyncUseCase>(),
          gh<_i234.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i270.SyncStatusCubit>(() => _i270.SyncStatusCubit(
          gh<_i122.SyncStatusProvider>(),
          gh<_i117.PendingOperationsManager>(),
          gh<_i173.TriggerUpstreamSyncUseCase>(),
          gh<_i235.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i271.TrackCacheBloc>(() => _i271.TrackCacheBloc(
          cacheTrackUseCase: gh<_i143.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i183.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i166.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i151.GetCachedTrackPathUseCase>(),
          downloadTrackUseCase: gh<_i261.DownloadTrackUseCase>(),
        ));
    gh.factory<_i272.TrackVersionsBloc>(() => _i272.TrackVersionsBloc(
          gh<_i245.WatchTrackVersionsBundleUseCase>(),
          gh<_i231.SetActiveTrackVersionUseCase>(),
          gh<_i250.AddTrackVersionUseCase>(),
          gh<_i225.RenameTrackVersionUseCase>(),
          gh<_i205.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i273.UploadAudioTrackUseCase>(
        () => _i273.UploadAudioTrackUseCase(
              gh<_i224.ProjectTrackService>(),
              gh<_i163.ProjectsRepository>(),
              gh<_i121.SessionStorage>(),
              gh<_i250.AddTrackVersionUseCase>(),
              gh<_i196.AudioTrackRepository>(),
            ));
    gh.factory<_i274.VoiceMemoBloc>(() => _i274.VoiceMemoBloc(
          gh<_i80.WatchVoiceMemosUseCase>(),
          gh<_i95.CreateVoiceMemoUseCase>(),
          gh<_i123.UpdateVoiceMemoUseCase>(),
          gh<_i97.DeleteVoiceMemoUseCase>(),
          gh<_i264.PlayVoiceMemoUseCase>(),
        ));
    gh.factory<_i275.AudioCommentBloc>(() => _i275.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i248.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i258.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i240.WatchAudioCommentsBundleUseCase>(),
          getCachedAudioCommentUseCase:
              gh<_i150.GetCachedAudioCommentUseCase>(),
        ));
    gh.factory<_i276.AudioPlayerBloc>(() => _i276.AudioPlayerBloc(
        audioPlayerService: gh<_i253.AudioPlayerService>()));
    gh.factory<_i277.AudioTrackBloc>(() => _i277.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i246.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i259.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i273.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i262.EditAudioTrackUseCase>(),
          uploadTrackCoverArt: gh<_i238.UploadTrackCoverArtUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i278.AppModule {}
