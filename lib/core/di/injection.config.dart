// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i11;

import 'package:cloud_firestore/cloud_firestore.dart' as _i15;
import 'package:connectivity_plus/connectivity_plus.dart' as _i9;
import 'package:firebase_auth/firebase_auth.dart' as _i14;
import 'package:firebase_storage/firebase_storage.dart' as _i16;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i17;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i22;
import 'package:isar/isar.dart' as _i24;
import 'package:shared_preferences/shared_preferences.dart' as _i55;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i109;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i13;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i214;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i215;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i133;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i137;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i139;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i234;
import 'package:trackflow/core/di/app_module.dart' as _i255;
import 'package:trackflow/core/network/network_state_manager.dart' as _i30;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i31;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i32;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i34;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i19;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i33;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i35;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i83;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i86;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i143;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i100;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i101;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i36;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i144;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i145;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/services/firebase_audio_upload_service.dart'
    as _i84;
import 'package:trackflow/core/session/current_user_service.dart' as _i134;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i40;
import 'package:trackflow/core/sync/data/services/background_sync_coordinator_impl.dart'
    as _i129;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i119;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i124;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i107;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i159;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i128;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i18;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i61;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart'
    as _i219;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i220;
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart'
    as _i221;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i162;
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart' as _i248;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i249;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i78;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart'
    as _i79;
import 'package:trackflow/features/audio_cache/data/repositories/audio_download_repository_impl.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i123;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i131;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i138;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i155;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i171;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i168;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i218;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i93;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i180;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i94;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i179;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i208;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i231;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i239;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i224;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i252;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i203;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i235;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i236;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i181;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i206;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i207;
import 'package:trackflow/features/audio_player/domain/usecases/resolve_track_version_usecase.dart'
    as _i211;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i212;
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
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i42;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i182;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i253;
import 'package:trackflow/features/audio_recording/domain/services/recording_service.dart'
    as _i47;
import 'package:trackflow/features/audio_recording/domain/usecases/cancel_recording_usecase.dart'
    as _i80;
import 'package:trackflow/features/audio_recording/domain/usecases/start_recording_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_recording/domain/usecases/stop_recording_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_recording/infrastructure/services/platform_recording_service.dart'
    as _i48;
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart'
    as _i108;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i76;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i77;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i91;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i184;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i92;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i183;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i209;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i240;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i242;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i251;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i229;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i116;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i254;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i158;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i125;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i73;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i126;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i178;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i200;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i217;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i156;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i157;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i237;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i130;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i186;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i185;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i188;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i135;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i196;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i225;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i170;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i238;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i97;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i23;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i99;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i98;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i176;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i132;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i191;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i140;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i102;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i103;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i213;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i246;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i151;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i26;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i28;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i81;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i136;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i85;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i49;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i204;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i232;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i177;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i193;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i201;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i202;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i154;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i163;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i243;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i29;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i20;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i104;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i147;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i148;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i146;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i205;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i43;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i150;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i149;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i227;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i244;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i226;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i245;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i88;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i153;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i152;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i189;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i241;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i197;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i164;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i167;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i247;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i65;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i111;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i141;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i161;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i142;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i160;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i233;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i192;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i195;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i198;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i210;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i216;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i228;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i172;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i250;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i66;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i67;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i95;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i113;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i166;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i114;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i96;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i165;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i112;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i187;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i190;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i222;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i173;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i117;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i223;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i71;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i72;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i175;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i70;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i90;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i174;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i69;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i194;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i199;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i230;

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
    gh.lazySingleton<_i7.ConflictResolutionServiceImpl<dynamic>>(
        () => _i7.ConflictResolutionServiceImpl<dynamic>());
    gh.lazySingleton<_i9.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i10.DeepLinkService>(() => _i10.DeepLinkService());
    await gh.factoryAsync<_i11.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i12.DynamicLinkService>(() => _i12.DynamicLinkService());
    gh.factory<_i13.ExampleComplexBloc>(() => _i13.ExampleComplexBloc());
    gh.factory<_i13.ExampleConditionalBloc>(
        () => _i13.ExampleConditionalBloc());
    gh.factory<_i13.ExampleNavigationCubit>(
        () => _i13.ExampleNavigationCubit());
    gh.factory<_i13.ExampleSimpleBloc>(() => _i13.ExampleSimpleBloc());
    gh.factory<_i13.ExampleUserProfileBloc>(
        () => _i13.ExampleUserProfileBloc());
    gh.lazySingleton<_i14.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i15.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i16.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i17.GoogleSignIn>(() => appModule.googleSignIn);
    gh.lazySingleton<_i18.IncrementalSyncService<_i19.Notification>>(
        () => _i20.NotificationIncrementalSyncService());
    gh.factory<_i21.InitializeAudioPlayerUseCase>(() =>
        _i21.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i22.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i23.InvitationRemoteDataSource>(() =>
        _i23.FirestoreInvitationRemoteDataSource(gh<_i15.FirebaseFirestore>()));
    await gh.factoryAsync<_i24.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i25.MagicLinkLocalDataSource>(
        () => _i25.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i26.MagicLinkRemoteDataSource>(
        () => _i26.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i15.FirebaseFirestore>(),
              deepLinkService: gh<_i10.DeepLinkService>(),
            ));
    gh.factory<_i27.MagicLinkRepository>(() =>
        _i28.MagicLinkRepositoryImp(gh<_i26.MagicLinkRemoteDataSource>()));
    gh.factory<_i29.NavigationCubit>(() => _i29.NavigationCubit());
    gh.lazySingleton<_i30.NetworkStateManager>(() => _i30.NetworkStateManager(
          gh<_i22.InternetConnectionChecker>(),
          gh<_i9.Connectivity>(),
        ));
    gh.lazySingleton<_i31.NotificationLocalDataSource>(
        () => _i31.IsarNotificationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i32.NotificationRemoteDataSource>(() =>
        _i32.FirestoreNotificationRemoteDataSource(
            gh<_i15.FirebaseFirestore>()));
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
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i39.PendingOperationsLocalDataSource>(
        () => _i39.IsarPendingOperationsLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i40.PendingOperationsRepository>(() =>
        _i40.PendingOperationsRepositoryImpl(
            gh<_i39.PendingOperationsLocalDataSource>()));
    gh.lazySingleton<_i41.PlaybackPersistenceRepository>(
        () => _i42.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i43.PlaylistLocalDataSource>(
        () => _i43.PlaylistLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i44.PlaylistRemoteDataSource>(
        () => _i44.PlaylistRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i45.ProjectRemoteDataSource>(() =>
        _i45.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i46.ProjectsLocalDataSource>(
        () => _i46.ProjectsLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i47.RecordingService>(
        () => _i48.PlatformRecordingService());
    gh.lazySingleton<_i49.ResendMagicLinkUseCase>(
        () => _i49.ResendMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i50.ResumeAudioUseCase>(() => _i50.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i51.SavePlaybackStateUseCase>(
        () => _i51.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i41.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i52.SeekAudioUseCase>(() =>
        _i52.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i53.SetPlaybackSpeedUseCase>(() => _i53.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i54.SetVolumeUseCase>(() =>
        _i54.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i55.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i56.SkipToNextUseCase>(() => _i56.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i57.SkipToPreviousUseCase>(() => _i57.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i58.StartRecordingUseCase>(
        () => _i58.StartRecordingUseCase(gh<_i47.RecordingService>()));
    gh.factory<_i59.StopAudioUseCase>(() =>
        _i59.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.StopRecordingUseCase>(
        () => _i60.StopRecordingUseCase(gh<_i47.RecordingService>()));
    gh.lazySingleton<_i61.SyncCoordinator>(
        () => _i61.SyncCoordinator(gh<_i55.SharedPreferences>()));
    gh.factory<_i62.ToggleRepeatModeUseCase>(() => _i62.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i63.ToggleShuffleUseCase>(() => _i63.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i64.TrackDetailCubit>(() => _i64.TrackDetailCubit());
    gh.lazySingleton<_i65.TrackVersionLocalDataSource>(
        () => _i65.IsarTrackVersionLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i66.UserProfileLocalDataSource>(
        () => _i66.IsarUserProfileLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i67.UserProfileRemoteDataSource>(
        () => _i67.UserProfileRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i68.ValidateMagicLinkUseCase>(
        () => _i68.ValidateMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i69.WaveformGeneratorService>(() =>
        _i70.JustWaveformGeneratorService(cacheDir: gh<_i11.Directory>()));
    gh.factory<_i71.WaveformLocalDataSource>(
        () => _i71.WaveformLocalDataSourceImpl(isar: gh<_i24.Isar>()));
    gh.lazySingleton<_i72.WaveformRemoteDataSource>(() =>
        _i72.FirebaseStorageWaveformRemoteDataSource(
            gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i73.AppleAuthService>(
        () => _i73.AppleAuthService(gh<_i14.FirebaseAuth>()));
    gh.lazySingleton<_i74.AudioCommentLocalDataSource>(
        () => _i74.IsarAudioCommentLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i75.AudioCommentRemoteDataSource>(() =>
        _i75.FirebaseAudioCommentRemoteDataSource(
            gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i76.AudioTrackLocalDataSource>(
        () => _i76.IsarAudioTrackLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i77.AudioTrackRemoteDataSource>(() =>
        _i77.AudioTrackRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i78.CacheStorageLocalDataSource>(
        () => _i78.CacheStorageLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i79.CacheStorageRemoteDataSource>(() =>
        _i79.CacheStorageRemoteDataSourceImpl(gh<_i16.FirebaseStorage>()));
    gh.factory<_i80.CancelRecordingUseCase>(
        () => _i80.CancelRecordingUseCase(gh<_i47.RecordingService>()));
    gh.lazySingleton<_i81.ConsumeMagicLinkUseCase>(
        () => _i81.ConsumeMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i82.CreateNotificationUseCase>(() =>
        _i82.CreateNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i83.DeleteNotificationUseCase>(() =>
        _i83.DeleteNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i84.FirebaseAudioUploadService>(
        () => _i84.FirebaseAudioUploadService(gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i85.GetMagicLinkStatusUseCase>(
        () => _i85.GetMagicLinkStatusUseCase(gh<_i27.MagicLinkRepository>()));
    gh.lazySingleton<_i86.GetUnreadNotificationsCountUseCase>(() =>
        _i86.GetUnreadNotificationsCountUseCase(
            gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i87.GoogleAuthService>(() => _i87.GoogleAuthService(
          gh<_i17.GoogleSignIn>(),
          gh<_i14.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i88.ProjectDTO>>(
        () => _i89.ProjectIncrementalSyncService(
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<dynamic>>(
        () => _i90.WaveformIncrementalSyncService(
              gh<_i65.TrackVersionLocalDataSource>(),
              gh<_i71.WaveformLocalDataSource>(),
              gh<_i72.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i91.AudioTrackDTO>>(
        () => _i92.AudioTrackIncrementalSyncService(
              gh<_i77.AudioTrackRemoteDataSource>(),
              gh<_i76.AudioTrackLocalDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i93.AudioCommentDTO>>(
        () => _i94.AudioCommentIncrementalSyncService(
              gh<_i75.AudioCommentRemoteDataSource>(),
              gh<_i74.AudioCommentLocalDataSource>(),
              gh<_i65.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i95.UserProfileDTO>>(
        () => _i96.UserProfileIncrementalSyncService(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i97.InvitationLocalDataSource>(
        () => _i97.IsarInvitationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i98.InvitationRepository>(
        () => _i99.InvitationRepositoryImpl(
              localDataSource: gh<_i97.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i23.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
            ));
    gh.factory<_i100.MarkAsUnreadUseCase>(
        () => _i100.MarkAsUnreadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i101.MarkNotificationAsReadUseCase>(() =>
        _i101.MarkNotificationAsReadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i102.ObservePendingInvitationsUseCase>(() =>
        _i102.ObservePendingInvitationsUseCase(
            gh<_i98.InvitationRepository>()));
    gh.lazySingleton<_i103.ObserveSentInvitationsUseCase>(() =>
        _i103.ObserveSentInvitationsUseCase(gh<_i98.InvitationRepository>()));
    gh.lazySingleton<_i104.OnboardingStateLocalDataSource>(() =>
        _i104.OnboardingStateLocalDataSourceImpl(gh<_i55.SharedPreferences>()));
    gh.lazySingleton<_i105.PendingOperationsManager>(
        () => _i105.PendingOperationsManager(
              gh<_i40.PendingOperationsRepository>(),
              gh<_i30.NetworkStateManager>(),
              gh<_i37.OperationExecutorFactory>(),
            ));
    gh.factory<_i106.PlaylistOperationExecutor>(() =>
        _i106.PlaylistOperationExecutor(gh<_i44.PlaylistRemoteDataSource>()));
    gh.factory<_i107.ProjectOperationExecutor>(() =>
        _i107.ProjectOperationExecutor(gh<_i45.ProjectRemoteDataSource>()));
    gh.factory<_i108.RecordingBloc>(() => _i108.RecordingBloc(
          gh<_i58.StartRecordingUseCase>(),
          gh<_i60.StopRecordingUseCase>(),
          gh<_i80.CancelRecordingUseCase>(),
          gh<_i47.RecordingService>(),
        ));
    gh.lazySingleton<_i109.SessionStorage>(
        () => _i109.SessionStorageImpl(prefs: gh<_i55.SharedPreferences>()));
    gh.factory<_i110.SyncStatusProvider>(() => _i110.SyncStatusProvider(
          syncCoordinator: gh<_i61.SyncCoordinator>(),
          pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i111.TrackVersionRemoteDataSource>(
        () => _i111.TrackVersionRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i84.FirebaseAudioUploadService>(),
            ));
    gh.lazySingleton<_i112.UserProfileCacheRepository>(
        () => _i113.UserProfileCacheRepositoryImpl(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
              gh<_i30.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i114.UserProfileCollaboratorIncrementalSyncService>(
        () => _i114.UserProfileCollaboratorIncrementalSyncService(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i115.UserProfileOperationExecutor>(() =>
        _i115.UserProfileOperationExecutor(
            gh<_i67.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i116.WatchTrackUploadStatusUseCase>(() =>
        _i116.WatchTrackUploadStatusUseCase(
            gh<_i105.PendingOperationsManager>()));
    gh.lazySingleton<_i117.WatchUserProfilesUseCase>(() =>
        _i117.WatchUserProfilesUseCase(gh<_i112.UserProfileCacheRepository>()));
    gh.factory<_i118.WaveformOperationExecutor>(() =>
        _i118.WaveformOperationExecutor(gh<_i72.WaveformRemoteDataSource>()));
    gh.factory<_i119.AudioCommentOperationExecutor>(() =>
        _i119.AudioCommentOperationExecutor(
            gh<_i75.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i120.AudioDownloadRepository>(
        () => _i121.AudioDownloadRepositoryImpl(
              remoteDataSource: gh<_i79.CacheStorageRemoteDataSource>(),
              localDataSource: gh<_i78.CacheStorageLocalDataSource>(),
            ));
    gh.lazySingleton<_i122.AudioStorageRepository>(() =>
        _i123.AudioStorageRepositoryImpl(
            localDataSource: gh<_i78.CacheStorageLocalDataSource>()));
    gh.factory<_i124.AudioTrackOperationExecutor>(
        () => _i124.AudioTrackOperationExecutor(
              gh<_i77.AudioTrackRemoteDataSource>(),
              gh<_i76.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i125.AuthRemoteDataSource>(
        () => _i125.AuthRemoteDataSourceImpl(
              gh<_i14.FirebaseAuth>(),
              gh<_i87.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i126.AuthRepository>(() => _i127.AuthRepositoryImpl(
          remote: gh<_i125.AuthRemoteDataSource>(),
          sessionStorage: gh<_i109.SessionStorage>(),
          networkStateManager: gh<_i30.NetworkStateManager>(),
          googleAuthService: gh<_i87.GoogleAuthService>(),
          appleAuthService: gh<_i73.AppleAuthService>(),
        ));
    gh.lazySingleton<_i128.BackgroundSyncCoordinator>(
        () => _i129.BackgroundSyncCoordinatorImpl(
              gh<_i30.NetworkStateManager>(),
              gh<_i61.SyncCoordinator>(),
              gh<_i105.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i130.CacheManagementLocalDataSource>(() =>
        _i130.CacheManagementLocalDataSourceImpl(
            local: gh<_i78.CacheStorageLocalDataSource>()));
    gh.factory<_i131.CacheTrackUseCase>(() => _i131.CacheTrackUseCase(
          gh<_i120.AudioDownloadRepository>(),
          gh<_i122.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i132.CancelInvitationUseCase>(
        () => _i132.CancelInvitationUseCase(gh<_i98.InvitationRepository>()));
    gh.factory<_i133.CheckAuthenticationStatusUseCase>(() =>
        _i133.CheckAuthenticationStatusUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i134.CurrentUserService>(
        () => _i134.CurrentUserService(gh<_i109.SessionStorage>()));
    gh.factory<_i135.DeleteCachedAudioUseCase>(() =>
        _i135.DeleteCachedAudioUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i136.GenerateMagicLinkUseCase>(
        () => _i136.GenerateMagicLinkUseCase(
              gh<_i27.MagicLinkRepository>(),
              gh<_i126.AuthRepository>(),
            ));
    gh.lazySingleton<_i137.GetAuthStateUseCase>(
        () => _i137.GetAuthStateUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i138.GetCachedTrackPathUseCase>(() =>
        _i138.GetCachedTrackPathUseCase(gh<_i122.AudioStorageRepository>()));
    gh.factory<_i139.GetCurrentUserUseCase>(
        () => _i139.GetCurrentUserUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i140.GetPendingInvitationsCountUseCase>(() =>
        _i140.GetPendingInvitationsCountUseCase(
            gh<_i98.InvitationRepository>()));
    gh.lazySingleton<_i18.IncrementalSyncService<_i141.TrackVersionDTO>>(
        () => _i142.TrackVersionIncrementalSyncService(
              gh<_i111.TrackVersionRemoteDataSource>(),
              gh<_i65.TrackVersionLocalDataSource>(),
              gh<_i76.AudioTrackLocalDataSource>(),
            ));
    gh.factory<_i143.MarkAllNotificationsAsReadUseCase>(
        () => _i143.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i134.CurrentUserService>(),
            ));
    gh.factory<_i144.NotificationActorBloc>(() => _i144.NotificationActorBloc(
          createNotificationUseCase: gh<_i82.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i101.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i100.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i143.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i83.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i145.NotificationWatcherBloc>(
        () => _i145.NotificationWatcherBloc(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i134.CurrentUserService>(),
            ));
    gh.lazySingleton<_i146.OnboardingRepository>(() =>
        _i147.OnboardingRepositoryImpl(
            gh<_i104.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i148.OnboardingUseCase>(
        () => _i148.OnboardingUseCase(gh<_i146.OnboardingRepository>()));
    gh.lazySingleton<_i149.PlaylistRepository>(
        () => _i150.PlaylistRepositoryImpl(
              localDataSource: gh<_i43.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
            ));
    gh.factory<_i151.ProjectInvitationWatcherBloc>(
        () => _i151.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i98.InvitationRepository>(),
              currentUserService: gh<_i134.CurrentUserService>(),
            ));
    gh.lazySingleton<_i152.ProjectsRepository>(
        () => _i153.ProjectsRepositoryImpl(
              localDataSource: gh<_i46.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i154.RemoveCollaboratorUseCase>(
        () => _i154.RemoveCollaboratorUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i155.RemoveTrackCacheUseCase>(() =>
        _i155.RemoveTrackCacheUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i156.SignOutUseCase>(
        () => _i156.SignOutUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i157.SignUpUseCase>(
        () => _i157.SignUpUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i158.TrackUploadStatusCubit>(() => _i158.TrackUploadStatusCubit(
        gh<_i116.WatchTrackUploadStatusUseCase>()));
    gh.factory<_i159.TrackVersionOperationExecutor>(
        () => _i159.TrackVersionOperationExecutor(
              gh<_i111.TrackVersionRemoteDataSource>(),
              gh<_i65.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i160.TrackVersionRepository>(
        () => _i161.TrackVersionRepositoryImpl(
              gh<_i65.TrackVersionLocalDataSource>(),
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i105.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i162.TriggerUpstreamSyncUseCase>(() =>
        _i162.TriggerUpstreamSyncUseCase(
            gh<_i128.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i163.UpdateCollaboratorRoleUseCase>(
        () => _i163.UpdateCollaboratorRoleUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i164.UpdateProjectUseCase>(
        () => _i164.UpdateProjectUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i165.UserProfileRepository>(
        () => _i166.UserProfileRepositoryImpl(
              localDataSource: gh<_i66.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i67.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
              firestore: gh<_i15.FirebaseFirestore>(),
              sessionStorage: gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i167.WatchAllProjectsUseCase>(
        () => _i167.WatchAllProjectsUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i168.WatchCachedAudiosUseCase>(() =>
        _i168.WatchCachedAudiosUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i169.WatchCollaboratorsBundleUseCase>(
        () => _i169.WatchCollaboratorsBundleUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i117.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i170.WatchStorageUsageUseCase>(() =>
        _i170.WatchStorageUsageUseCase(gh<_i122.AudioStorageRepository>()));
    gh.factory<_i171.WatchTrackCacheStatusUseCase>(() =>
        _i171.WatchTrackCacheStatusUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i172.WatchTrackVersionsUseCase>(() =>
        _i172.WatchTrackVersionsUseCase(gh<_i160.TrackVersionRepository>()));
    gh.lazySingleton<_i173.WatchUserProfileUseCase>(
        () => _i173.WatchUserProfileUseCase(
              gh<_i165.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i174.WaveformRepository>(() => _i175.WaveformRepositoryImpl(
          localDataSource: gh<_i71.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i72.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i176.AcceptInvitationUseCase>(
        () => _i176.AcceptInvitationUseCase(
              invitationRepository: gh<_i98.InvitationRepository>(),
              projectRepository: gh<_i152.ProjectsRepository>(),
              userProfileRepository: gh<_i165.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i177.AddCollaboratorToProjectUseCase>(
        () => _i177.AddCollaboratorToProjectUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i178.AppleSignInUseCase>(
        () => _i178.AppleSignInUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i179.AudioCommentRepository>(
        () => _i180.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i75.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i74.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i105.PendingOperationsManager>(),
              trackVersionRepository: gh<_i160.TrackVersionRepository>(),
            ));
    gh.factory<_i181.AudioSourceResolver>(() => _i182.AudioSourceResolverImpl(
          gh<_i122.AudioStorageRepository>(),
          gh<_i120.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i183.AudioTrackRepository>(
        () => _i184.AudioTrackRepositoryImpl(
              gh<_i76.AudioTrackLocalDataSource>(),
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i105.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i185.CacheMaintenanceService>(() =>
        _i186.CacheMaintenanceServiceImpl(
            gh<_i130.CacheManagementLocalDataSource>()));
    gh.factory<_i187.CheckProfileCompletenessUseCase>(() =>
        _i187.CheckProfileCompletenessUseCase(
            gh<_i165.UserProfileRepository>()));
    gh.factory<_i188.CleanupCacheUseCase>(
        () => _i188.CleanupCacheUseCase(gh<_i185.CacheMaintenanceService>()));
    gh.lazySingleton<_i189.CreateProjectUseCase>(
        () => _i189.CreateProjectUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i190.CreateUserProfileUseCase>(
        () => _i190.CreateUserProfileUseCase(
              gh<_i165.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i191.DeclineInvitationUseCase>(
        () => _i191.DeclineInvitationUseCase(
              invitationRepository: gh<_i98.InvitationRepository>(),
              projectRepository: gh<_i152.ProjectsRepository>(),
              userProfileRepository: gh<_i165.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i192.DeleteTrackVersionUseCase>(
        () => _i192.DeleteTrackVersionUseCase(
              gh<_i160.TrackVersionRepository>(),
              gh<_i174.WaveformRepository>(),
              gh<_i179.AudioCommentRepository>(),
              gh<_i122.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i193.FindUserByEmailUseCase>(
        () => _i193.FindUserByEmailUseCase(gh<_i165.UserProfileRepository>()));
    gh.factory<_i194.GenerateAndStoreWaveform>(
        () => _i194.GenerateAndStoreWaveform(
              gh<_i174.WaveformRepository>(),
              gh<_i69.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i195.GetActiveVersionUseCase>(() =>
        _i195.GetActiveVersionUseCase(gh<_i160.TrackVersionRepository>()));
    gh.factory<_i196.GetCacheStorageStatsUseCase>(() =>
        _i196.GetCacheStorageStatsUseCase(gh<_i185.CacheMaintenanceService>()));
    gh.lazySingleton<_i197.GetProjectByIdUseCase>(
        () => _i197.GetProjectByIdUseCase(gh<_i152.ProjectsRepository>()));
    gh.lazySingleton<_i198.GetVersionByIdUseCase>(
        () => _i198.GetVersionByIdUseCase(gh<_i160.TrackVersionRepository>()));
    gh.factory<_i199.GetWaveformByVersion>(
        () => _i199.GetWaveformByVersion(gh<_i174.WaveformRepository>()));
    gh.lazySingleton<_i200.GoogleSignInUseCase>(() => _i200.GoogleSignInUseCase(
          gh<_i126.AuthRepository>(),
          gh<_i165.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i201.JoinProjectWithIdUseCase>(
        () => _i201.JoinProjectWithIdUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i202.LeaveProjectUseCase>(() => _i202.LeaveProjectUseCase(
          gh<_i152.ProjectsRepository>(),
          gh<_i109.SessionStorage>(),
        ));
    gh.factory<_i203.LoadTrackContextUseCase>(
        () => _i203.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i183.AudioTrackRepository>(),
              trackVersionRepository: gh<_i160.TrackVersionRepository>(),
              userProfileRepository: gh<_i165.UserProfileRepository>(),
              projectsRepository: gh<_i152.ProjectsRepository>(),
            ));
    gh.factory<_i204.MagicLinkBloc>(() => _i204.MagicLinkBloc(
          generateMagicLink: gh<_i136.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i68.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i81.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i49.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i85.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i201.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i126.AuthRepository>(),
        ));
    gh.factory<_i205.OnboardingBloc>(() => _i205.OnboardingBloc(
          onboardingUseCase: gh<_i148.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i139.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i206.PlayPlaylistUseCase>(() => _i206.PlayPlaylistUseCase(
          playlistRepository: gh<_i149.PlaylistRepository>(),
          audioTrackRepository: gh<_i183.AudioTrackRepository>(),
          trackVersionRepository: gh<_i160.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i122.AudioStorageRepository>(),
        ));
    gh.factory<_i207.PlayVersionUseCase>(() => _i207.PlayVersionUseCase(
          audioTrackRepository: gh<_i183.AudioTrackRepository>(),
          audioStorageRepository: gh<_i122.AudioStorageRepository>(),
          trackVersionRepository: gh<_i160.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i208.ProjectCommentService>(
        () => _i208.ProjectCommentService(gh<_i179.AudioCommentRepository>()));
    gh.lazySingleton<_i209.ProjectTrackService>(
        () => _i209.ProjectTrackService(gh<_i183.AudioTrackRepository>()));
    gh.lazySingleton<_i210.RenameTrackVersionUseCase>(() =>
        _i210.RenameTrackVersionUseCase(gh<_i160.TrackVersionRepository>()));
    gh.factory<_i211.ResolveTrackVersionUseCase>(
        () => _i211.ResolveTrackVersionUseCase(
              audioTrackRepository: gh<_i183.AudioTrackRepository>(),
              trackVersionRepository: gh<_i160.TrackVersionRepository>(),
            ));
    gh.factory<_i212.RestorePlaybackStateUseCase>(
        () => _i212.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i41.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i183.AudioTrackRepository>(),
              audioStorageRepository: gh<_i122.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i213.SendInvitationUseCase>(
        () => _i213.SendInvitationUseCase(
              invitationRepository: gh<_i98.InvitationRepository>(),
              notificationService: gh<_i35.NotificationService>(),
              findUserByEmail: gh<_i193.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i27.MagicLinkRepository>(),
              currentUserService: gh<_i134.CurrentUserService>(),
            ));
    gh.factory<_i214.SessionCleanupService>(() => _i214.SessionCleanupService(
          userProfileRepository: gh<_i165.UserProfileRepository>(),
          projectsRepository: gh<_i152.ProjectsRepository>(),
          audioTrackRepository: gh<_i183.AudioTrackRepository>(),
          audioCommentRepository: gh<_i179.AudioCommentRepository>(),
          invitationRepository: gh<_i98.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i41.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i109.SessionStorage>(),
          pendingOperationsRepository: gh<_i40.PendingOperationsRepository>(),
          waveformRepository: gh<_i174.WaveformRepository>(),
          trackVersionRepository: gh<_i160.TrackVersionRepository>(),
          syncCoordinator: gh<_i61.SyncCoordinator>(),
        ));
    gh.factory<_i215.SessionService>(() => _i215.SessionService(
          checkAuthUseCase: gh<_i133.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i139.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i148.OnboardingUseCase>(),
          profileUseCase: gh<_i187.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i216.SetActiveTrackVersionUseCase>(() =>
        _i216.SetActiveTrackVersionUseCase(gh<_i183.AudioTrackRepository>()));
    gh.lazySingleton<_i217.SignInUseCase>(() => _i217.SignInUseCase(
          gh<_i126.AuthRepository>(),
          gh<_i165.UserProfileRepository>(),
        ));
    gh.factory<_i218.TrackCacheBloc>(() => _i218.TrackCacheBloc(
          cacheTrackUseCase: gh<_i131.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i171.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i155.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i138.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i219.TriggerDownstreamSyncUseCase>(
        () => _i219.TriggerDownstreamSyncUseCase(
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i215.SessionService>(),
            ));
    gh.lazySingleton<_i220.TriggerForegroundSyncUseCase>(
        () => _i220.TriggerForegroundSyncUseCase(
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i215.SessionService>(),
            ));
    gh.lazySingleton<_i221.TriggerStartupSyncUseCase>(
        () => _i221.TriggerStartupSyncUseCase(
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i215.SessionService>(),
            ));
    gh.factory<_i222.UpdateUserProfileUseCase>(
        () => _i222.UpdateUserProfileUseCase(
              gh<_i165.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i223.UserProfileBloc>(() => _i223.UserProfileBloc(
          updateUserProfileUseCase: gh<_i222.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i190.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i173.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i187.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i139.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i224.WatchAudioCommentsBundleUseCase>(
        () => _i224.WatchAudioCommentsBundleUseCase(
              gh<_i183.AudioTrackRepository>(),
              gh<_i179.AudioCommentRepository>(),
              gh<_i112.UserProfileCacheRepository>(),
            ));
    gh.factory<_i225.WatchCachedTrackBundlesUseCase>(
        () => _i225.WatchCachedTrackBundlesUseCase(
              gh<_i185.CacheMaintenanceService>(),
              gh<_i183.AudioTrackRepository>(),
              gh<_i165.UserProfileRepository>(),
              gh<_i152.ProjectsRepository>(),
              gh<_i160.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i226.WatchProjectDetailUseCase>(
        () => _i226.WatchProjectDetailUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i183.AudioTrackRepository>(),
              gh<_i112.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i227.WatchProjectPlaylistUseCase>(
        () => _i227.WatchProjectPlaylistUseCase(
              gh<_i183.AudioTrackRepository>(),
              gh<_i160.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i228.WatchTrackVersionsBundleUseCase>(
        () => _i228.WatchTrackVersionsBundleUseCase(
              gh<_i183.AudioTrackRepository>(),
              gh<_i160.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i229.WatchTracksByProjectIdUseCase>(() =>
        _i229.WatchTracksByProjectIdUseCase(gh<_i183.AudioTrackRepository>()));
    gh.factory<_i230.WaveformBloc>(() => _i230.WaveformBloc(
          waveformRepository: gh<_i174.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i231.AddAudioCommentUseCase>(
        () => _i231.AddAudioCommentUseCase(
              gh<_i208.ProjectCommentService>(),
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i232.AddCollaboratorByEmailUseCase>(
        () => _i232.AddCollaboratorByEmailUseCase(
              gh<_i193.FindUserByEmailUseCase>(),
              gh<_i177.AddCollaboratorToProjectUseCase>(),
              gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i233.AddTrackVersionUseCase>(
        () => _i233.AddTrackVersionUseCase(
              gh<_i109.SessionStorage>(),
              gh<_i160.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i122.AudioStorageRepository>(),
              gh<_i194.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i234.AppFlowBloc>(() => _i234.AppFlowBloc(
          sessionService: gh<_i215.SessionService>(),
          getAuthStateUseCase: gh<_i137.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i214.SessionCleanupService>(),
        ));
    gh.factory<_i235.AudioContextBloc>(() => _i235.AudioContextBloc(
        loadTrackContextUseCase: gh<_i203.LoadTrackContextUseCase>()));
    gh.factory<_i236.AudioPlayerService>(() => _i236.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i21.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i207.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i206.PlayPlaylistUseCase>(),
          resolveTrackVersionUseCase: gh<_i211.ResolveTrackVersionUseCase>(),
          pauseAudioUseCase: gh<_i38.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i50.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i59.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i56.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i57.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i52.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i63.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i62.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i54.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i53.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i51.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i212.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i237.AuthBloc>(() => _i237.AuthBloc(
          signIn: gh<_i217.SignInUseCase>(),
          signUp: gh<_i157.SignUpUseCase>(),
          googleSignIn: gh<_i200.GoogleSignInUseCase>(),
          appleSignIn: gh<_i178.AppleSignInUseCase>(),
          signOut: gh<_i156.SignOutUseCase>(),
        ));
    gh.factory<_i238.CacheManagementBloc>(() => _i238.CacheManagementBloc(
          deleteOne: gh<_i135.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i170.WatchStorageUsageUseCase>(),
          getStats: gh<_i196.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i188.CleanupCacheUseCase>(),
          watchBundles: gh<_i225.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i239.DeleteAudioCommentUseCase>(
        () => _i239.DeleteAudioCommentUseCase(
              gh<_i208.ProjectCommentService>(),
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i240.DeleteAudioTrack>(() => _i240.DeleteAudioTrack(
          gh<_i109.SessionStorage>(),
          gh<_i152.ProjectsRepository>(),
          gh<_i209.ProjectTrackService>(),
          gh<_i160.TrackVersionRepository>(),
          gh<_i174.WaveformRepository>(),
          gh<_i122.AudioStorageRepository>(),
          gh<_i179.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i241.DeleteProjectUseCase>(
        () => _i241.DeleteProjectUseCase(
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
              gh<_i209.ProjectTrackService>(),
              gh<_i240.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i242.EditAudioTrackUseCase>(
        () => _i242.EditAudioTrackUseCase(
              gh<_i209.ProjectTrackService>(),
              gh<_i152.ProjectsRepository>(),
            ));
    gh.factory<_i243.ManageCollaboratorsBloc>(
        () => _i243.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i154.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i163.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i202.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i193.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i232.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i169.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i244.PlaylistBloc>(
        () => _i244.PlaylistBloc(gh<_i227.WatchProjectPlaylistUseCase>()));
    gh.factory<_i245.ProjectDetailBloc>(() => _i245.ProjectDetailBloc(
        watchProjectDetail: gh<_i226.WatchProjectDetailUseCase>()));
    gh.factory<_i246.ProjectInvitationActorBloc>(
        () => _i246.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i213.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i176.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i191.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i132.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i193.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i247.ProjectsBloc>(() => _i247.ProjectsBloc(
          createProject: gh<_i189.CreateProjectUseCase>(),
          updateProject: gh<_i164.UpdateProjectUseCase>(),
          deleteProject: gh<_i241.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i167.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i248.SyncBloc>(() => _i248.SyncBloc(
          gh<_i221.TriggerStartupSyncUseCase>(),
          gh<_i162.TriggerUpstreamSyncUseCase>(),
          gh<_i220.TriggerForegroundSyncUseCase>(),
          gh<_i219.TriggerDownstreamSyncUseCase>(),
        ));
    gh.factory<_i249.SyncStatusCubit>(() => _i249.SyncStatusCubit(
          gh<_i110.SyncStatusProvider>(),
          gh<_i105.PendingOperationsManager>(),
          gh<_i162.TriggerUpstreamSyncUseCase>(),
          gh<_i220.TriggerForegroundSyncUseCase>(),
        ));
    gh.factory<_i250.TrackVersionsBloc>(() => _i250.TrackVersionsBloc(
          gh<_i228.WatchTrackVersionsBundleUseCase>(),
          gh<_i216.SetActiveTrackVersionUseCase>(),
          gh<_i233.AddTrackVersionUseCase>(),
          gh<_i210.RenameTrackVersionUseCase>(),
          gh<_i192.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i251.UploadAudioTrackUseCase>(
        () => _i251.UploadAudioTrackUseCase(
              gh<_i209.ProjectTrackService>(),
              gh<_i152.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
              gh<_i233.AddTrackVersionUseCase>(),
              gh<_i183.AudioTrackRepository>(),
            ));
    gh.factory<_i252.AudioCommentBloc>(() => _i252.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i231.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i239.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i224.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i253.AudioPlayerBloc>(() => _i253.AudioPlayerBloc(
        audioPlayerService: gh<_i236.AudioPlayerService>()));
    gh.factory<_i254.AudioTrackBloc>(() => _i254.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i229.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i240.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i251.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i242.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i255.AppModule {}
