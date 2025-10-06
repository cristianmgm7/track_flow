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
    as _i24;
import 'package:isar/isar.dart' as _i26;
import 'package:shared_preferences/shared_preferences.dart' as _i56;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i109;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i14;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i228;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i9;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i209;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i210;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i132;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i136;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i138;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i229;
import 'package:trackflow/core/di/app_module.dart' as _i248;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i8;
import 'package:trackflow/core/network/network_state_manager.dart' as _i32;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i33;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i34;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i36;
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as _i21;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i35;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i37;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i83;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i85;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i140;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i101;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i102;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i38;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i141;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i142;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i82;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i13;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i19;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i43;
import 'package:trackflow/core/session/current_user_service.dart' as _i133;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i41;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i42;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i119;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i124;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i39;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i107;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i108;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i118;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i128;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i20;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i60;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i215;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i158;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i213;
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
    as _i130;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i137;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i152;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i167;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i164;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i214;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i92;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i176;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i93;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i175;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i204;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i225;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i234;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i218;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i245;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i230;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i44;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i231;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i177;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i23;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i202;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i203;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i207;
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
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i178;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i246;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i76;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i77;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i94;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i180;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i95;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i179;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i205;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i235;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i237;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i244;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i223;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i116;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i247;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i155;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i125;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i127;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i73;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i86;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i126;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i174;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i196;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i212;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i153;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i154;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i232;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i129;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i182;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i181;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i184;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i134;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i192;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i219;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i166;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i233;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i98;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i25;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i100;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i99;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i172;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i131;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i187;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i139;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i103;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i104;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i208;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i241;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i148;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i27;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i28;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i30;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i29;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i80;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i135;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i84;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i50;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i68;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i200;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i226;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i173;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i189;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i197;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i198;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i151;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i159;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i165;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i238;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i31;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i22;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i105;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i144;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i145;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i143;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i201;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i47;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i147;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i146;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i221;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i239;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i220;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i240;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i49;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i48;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i87;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i150;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i88;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i149;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i185;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i236;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i193;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i160;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i163;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i242;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i64;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i96;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i157;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i97;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i156;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i227;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i188;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i191;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i194;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i206;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i211;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i222;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i168;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i243;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i63;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i66;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i67;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i90;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i113;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i162;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i114;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i91;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i161;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i112;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i183;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i186;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i216;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i169;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i117;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i217;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i71;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i72;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i171;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i70;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i89;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i170;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i69;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i190;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i195;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i224;

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
    gh.lazySingleton<_i20.IncrementalSyncService<_i21.Notification>>(
        () => _i22.NotificationIncrementalSyncService());
    gh.factory<_i23.InitializeAudioPlayerUseCase>(() =>
        _i23.InitializeAudioPlayerUseCase(
            playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i24.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    gh.lazySingleton<_i25.InvitationRemoteDataSource>(() =>
        _i25.FirestoreInvitationRemoteDataSource(gh<_i16.FirebaseFirestore>()));
    await gh.factoryAsync<_i26.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i27.MagicLinkLocalDataSource>(
        () => _i27.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i28.MagicLinkRemoteDataSource>(
        () => _i28.MagicLinkRemoteDataSourceImpl(
              firestore: gh<_i16.FirebaseFirestore>(),
              deepLinkService: gh<_i11.DeepLinkService>(),
            ));
    gh.factory<_i29.MagicLinkRepository>(() =>
        _i30.MagicLinkRepositoryImp(gh<_i28.MagicLinkRemoteDataSource>()));
    gh.factory<_i31.NavigationCubit>(() => _i31.NavigationCubit());
    gh.lazySingleton<_i32.NetworkStateManager>(() => _i32.NetworkStateManager(
          gh<_i24.InternetConnectionChecker>(),
          gh<_i10.Connectivity>(),
        ));
    gh.lazySingleton<_i33.NotificationLocalDataSource>(
        () => _i33.IsarNotificationLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i34.NotificationRemoteDataSource>(() =>
        _i34.FirestoreNotificationRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
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
        playbackService: gh<_i5.AudioPlaybackService>()));
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
        () => _i47.PlaylistRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i48.ProjectRemoteDataSource>(() =>
        _i48.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i49.ProjectsLocalDataSource>(
        () => _i49.ProjectsLocalDataSourceImpl(gh<_i26.Isar>()));
    gh.lazySingleton<_i50.ResendMagicLinkUseCase>(
        () => _i50.ResendMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.factory<_i51.ResumeAudioUseCase>(() => _i51.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i52.SavePlaybackStateUseCase>(
        () => _i52.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i53.SeekAudioUseCase>(() =>
        _i53.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i54.SetPlaybackSpeedUseCase>(() => _i54.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i55.SetVolumeUseCase>(() =>
        _i55.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i56.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i57.SkipToNextUseCase>(() => _i57.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i58.SkipToPreviousUseCase>(() => _i58.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.StopAudioUseCase>(() =>
        _i59.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i60.SyncCoordinator>(
        () => _i60.SyncCoordinator(gh<_i56.SharedPreferences>()));
    gh.factory<_i61.ToggleRepeatModeUseCase>(() => _i61.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i62.ToggleShuffleUseCase>(() => _i62.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i63.TrackDetailCubit>(() => _i63.TrackDetailCubit());
    gh.lazySingleton<_i64.TrackVersionLocalDataSource>(
        () => _i64.IsarTrackVersionLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i65.TrackVersionRemoteDataSource>(
        () => _i65.TrackVersionRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i66.UserProfileLocalDataSource>(
        () => _i66.IsarUserProfileLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i67.UserProfileRemoteDataSource>(
        () => _i67.UserProfileRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i68.ValidateMagicLinkUseCase>(
        () => _i68.ValidateMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.factory<_i69.WaveformGeneratorService>(() =>
        _i70.JustWaveformGeneratorService(cacheDir: gh<_i12.Directory>()));
    gh.factory<_i71.WaveformLocalDataSource>(
        () => _i71.WaveformLocalDataSourceImpl(isar: gh<_i26.Isar>()));
    gh.lazySingleton<_i72.WaveformRemoteDataSource>(() =>
        _i72.FirebaseStorageWaveformRemoteDataSource(
            gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i73.AppleAuthService>(
        () => _i73.AppleAuthService(gh<_i15.FirebaseAuth>()));
    gh.lazySingleton<_i74.AudioCommentLocalDataSource>(
        () => _i74.IsarAudioCommentLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i75.AudioCommentRemoteDataSource>(() =>
        _i75.FirebaseAudioCommentRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i76.AudioTrackLocalDataSource>(
        () => _i76.IsarAudioTrackLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i77.AudioTrackRemoteDataSource>(() =>
        _i77.AudioTrackRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i78.CacheStorageLocalDataSource>(
        () => _i78.CacheStorageLocalDataSourceImpl(gh<_i26.Isar>()));
    gh.lazySingleton<_i79.CacheStorageRemoteDataSource>(() =>
        _i79.CacheStorageRemoteDataSourceImpl(gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i80.ConsumeMagicLinkUseCase>(
        () => _i80.ConsumeMagicLinkUseCase(gh<_i29.MagicLinkRepository>()));
    gh.factory<_i81.CreateNotificationUseCase>(() =>
        _i81.CreateNotificationUseCase(gh<_i35.NotificationRepository>()));
    gh.factory<_i82.DatabaseHealthMonitor>(
        () => _i82.DatabaseHealthMonitor(gh<_i26.Isar>()));
    gh.factory<_i83.DeleteNotificationUseCase>(() =>
        _i83.DeleteNotificationUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i84.GetMagicLinkStatusUseCase>(
        () => _i84.GetMagicLinkStatusUseCase(gh<_i29.MagicLinkRepository>()));
    gh.lazySingleton<_i85.GetUnreadNotificationsCountUseCase>(() =>
        _i85.GetUnreadNotificationsCountUseCase(
            gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i86.GoogleAuthService>(() => _i86.GoogleAuthService(
          gh<_i18.GoogleSignIn>(),
          gh<_i15.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i20.IncrementalSyncService<_i87.ProjectDTO>>(
        () => _i88.ProjectIncrementalSyncService(
              gh<_i48.ProjectRemoteDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i20.IncrementalSyncService<dynamic>>(
        () => _i89.WaveformIncrementalSyncService(
              gh<_i64.TrackVersionLocalDataSource>(),
              gh<_i71.WaveformLocalDataSource>(),
              gh<_i72.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i20.IncrementalSyncService<_i90.UserProfileDTO>>(
        () => _i91.UserProfileIncrementalSyncService(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i20.IncrementalSyncService<_i92.AudioCommentDTO>>(
        () => _i93.AudioCommentIncrementalSyncService(
              gh<_i75.AudioCommentRemoteDataSource>(),
              gh<_i74.AudioCommentLocalDataSource>(),
              gh<_i64.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i20.IncrementalSyncService<_i94.AudioTrackDTO>>(
        () => _i95.AudioTrackIncrementalSyncService(
              gh<_i77.AudioTrackRemoteDataSource>(),
              gh<_i76.AudioTrackLocalDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i20.IncrementalSyncService<_i96.TrackVersionDTO>>(
        () => _i97.TrackVersionIncrementalSyncService(
              gh<_i65.TrackVersionRemoteDataSource>(),
              gh<_i64.TrackVersionLocalDataSource>(),
              gh<_i76.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i98.InvitationLocalDataSource>(
        () => _i98.IsarInvitationLocalDataSource(gh<_i26.Isar>()));
    gh.lazySingleton<_i99.InvitationRepository>(
        () => _i100.InvitationRepositoryImpl(
              localDataSource: gh<_i98.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i25.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
            ));
    gh.factory<_i101.MarkAsUnreadUseCase>(
        () => _i101.MarkAsUnreadUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i102.MarkNotificationAsReadUseCase>(() =>
        _i102.MarkNotificationAsReadUseCase(gh<_i35.NotificationRepository>()));
    gh.lazySingleton<_i103.ObservePendingInvitationsUseCase>(() =>
        _i103.ObservePendingInvitationsUseCase(
            gh<_i99.InvitationRepository>()));
    gh.lazySingleton<_i104.ObserveSentInvitationsUseCase>(() =>
        _i104.ObserveSentInvitationsUseCase(gh<_i99.InvitationRepository>()));
    gh.lazySingleton<_i105.OnboardingStateLocalDataSource>(() =>
        _i105.OnboardingStateLocalDataSourceImpl(gh<_i56.SharedPreferences>()));
    gh.lazySingleton<_i106.PendingOperationsManager>(
        () => _i106.PendingOperationsManager(
              gh<_i42.PendingOperationsRepository>(),
              gh<_i32.NetworkStateManager>(),
              gh<_i39.OperationExecutorFactory>(),
            ));
    gh.factory<_i107.PlaylistOperationExecutor>(() =>
        _i107.PlaylistOperationExecutor(gh<_i47.PlaylistRemoteDataSource>()));
    gh.factory<_i108.ProjectOperationExecutor>(() =>
        _i108.ProjectOperationExecutor(gh<_i48.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i109.SessionStorage>(
        () => _i109.SessionStorageImpl(prefs: gh<_i56.SharedPreferences>()));
    gh.factory<_i110.SyncStatusProvider>(() => _i110.SyncStatusProvider(
          syncCoordinator: gh<_i60.SyncCoordinator>(),
          pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
        ));
    gh.factory<_i111.TrackVersionOperationExecutor>(
        () => _i111.TrackVersionOperationExecutor(
              gh<_i65.TrackVersionRemoteDataSource>(),
              gh<_i64.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i112.UserProfileCacheRepository>(
        () => _i113.UserProfileCacheRepositoryImpl(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
              gh<_i32.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i114.UserProfileCollaboratorIncrementalSyncService>(
        () => _i114.UserProfileCollaboratorIncrementalSyncService(
              gh<_i67.UserProfileRemoteDataSource>(),
              gh<_i66.UserProfileLocalDataSource>(),
              gh<_i49.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i115.UserProfileOperationExecutor>(() =>
        _i115.UserProfileOperationExecutor(
            gh<_i67.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i116.WatchTrackUploadStatusUseCase>(() =>
        _i116.WatchTrackUploadStatusUseCase(
            gh<_i106.PendingOperationsManager>()));
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
              gh<_i15.FirebaseAuth>(),
              gh<_i86.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i126.AuthRepository>(() => _i127.AuthRepositoryImpl(
          remote: gh<_i125.AuthRemoteDataSource>(),
          sessionStorage: gh<_i109.SessionStorage>(),
          networkStateManager: gh<_i32.NetworkStateManager>(),
          googleAuthService: gh<_i86.GoogleAuthService>(),
          appleAuthService: gh<_i73.AppleAuthService>(),
        ));
    gh.lazySingleton<_i128.BackgroundSyncCoordinator>(
        () => _i128.BackgroundSyncCoordinator(
              gh<_i32.NetworkStateManager>(),
              gh<_i60.SyncCoordinator>(),
              gh<_i106.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i129.CacheManagementLocalDataSource>(() =>
        _i129.CacheManagementLocalDataSourceImpl(
            local: gh<_i78.CacheStorageLocalDataSource>()));
    gh.factory<_i130.CacheTrackUseCase>(() => _i130.CacheTrackUseCase(
          gh<_i120.AudioDownloadRepository>(),
          gh<_i122.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i131.CancelInvitationUseCase>(
        () => _i131.CancelInvitationUseCase(gh<_i99.InvitationRepository>()));
    gh.factory<_i132.CheckAuthenticationStatusUseCase>(() =>
        _i132.CheckAuthenticationStatusUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i133.CurrentUserService>(
        () => _i133.CurrentUserService(gh<_i109.SessionStorage>()));
    gh.factory<_i134.DeleteCachedAudioUseCase>(() =>
        _i134.DeleteCachedAudioUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i135.GenerateMagicLinkUseCase>(
        () => _i135.GenerateMagicLinkUseCase(
              gh<_i29.MagicLinkRepository>(),
              gh<_i126.AuthRepository>(),
            ));
    gh.lazySingleton<_i136.GetAuthStateUseCase>(
        () => _i136.GetAuthStateUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i137.GetCachedTrackPathUseCase>(() =>
        _i137.GetCachedTrackPathUseCase(gh<_i122.AudioStorageRepository>()));
    gh.factory<_i138.GetCurrentUserUseCase>(
        () => _i138.GetCurrentUserUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i139.GetPendingInvitationsCountUseCase>(() =>
        _i139.GetPendingInvitationsCountUseCase(
            gh<_i99.InvitationRepository>()));
    gh.factory<_i140.MarkAllNotificationsAsReadUseCase>(
        () => _i140.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i35.NotificationRepository>(),
              currentUserService: gh<_i133.CurrentUserService>(),
            ));
    gh.factory<_i141.NotificationActorBloc>(() => _i141.NotificationActorBloc(
          createNotificationUseCase: gh<_i81.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i102.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i101.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i140.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i83.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i142.NotificationWatcherBloc>(
        () => _i142.NotificationWatcherBloc(
              notificationRepository: gh<_i35.NotificationRepository>(),
              currentUserService: gh<_i133.CurrentUserService>(),
            ));
    gh.lazySingleton<_i143.OnboardingRepository>(() =>
        _i144.OnboardingRepositoryImpl(
            gh<_i105.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i145.OnboardingUseCase>(
        () => _i145.OnboardingUseCase(gh<_i143.OnboardingRepository>()));
    gh.lazySingleton<_i146.PlaylistRepository>(
        () => _i147.PlaylistRepositoryImpl(
              localDataSource: gh<_i46.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
            ));
    gh.factory<_i148.ProjectInvitationWatcherBloc>(
        () => _i148.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i99.InvitationRepository>(),
              currentUserService: gh<_i133.CurrentUserService>(),
            ));
    gh.lazySingleton<_i149.ProjectsRepository>(
        () => _i150.ProjectsRepositoryImpl(
              localDataSource: gh<_i49.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i151.RemoveCollaboratorUseCase>(
        () => _i151.RemoveCollaboratorUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i152.RemoveTrackCacheUseCase>(() =>
        _i152.RemoveTrackCacheUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i153.SignOutUseCase>(
        () => _i153.SignOutUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i154.SignUpUseCase>(
        () => _i154.SignUpUseCase(gh<_i126.AuthRepository>()));
    gh.factory<_i155.TrackUploadStatusCubit>(() => _i155.TrackUploadStatusCubit(
        gh<_i116.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i156.TrackVersionRepository>(
        () => _i157.TrackVersionRepositoryImpl(
              gh<_i64.TrackVersionLocalDataSource>(),
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i106.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i158.TriggerUpstreamSyncUseCase>(() =>
        _i158.TriggerUpstreamSyncUseCase(
            gh<_i128.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i159.UpdateCollaboratorRoleUseCase>(
        () => _i159.UpdateCollaboratorRoleUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i160.UpdateProjectUseCase>(
        () => _i160.UpdateProjectUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i161.UserProfileRepository>(
        () => _i162.UserProfileRepositoryImpl(
              localDataSource: gh<_i66.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i67.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
              firestore: gh<_i16.FirebaseFirestore>(),
              sessionStorage: gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i163.WatchAllProjectsUseCase>(
        () => _i163.WatchAllProjectsUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i164.WatchCachedAudiosUseCase>(() =>
        _i164.WatchCachedAudiosUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i165.WatchCollaboratorsBundleUseCase>(
        () => _i165.WatchCollaboratorsBundleUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i117.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i166.WatchStorageUsageUseCase>(() =>
        _i166.WatchStorageUsageUseCase(gh<_i122.AudioStorageRepository>()));
    gh.factory<_i167.WatchTrackCacheStatusUseCase>(() =>
        _i167.WatchTrackCacheStatusUseCase(gh<_i122.AudioStorageRepository>()));
    gh.lazySingleton<_i168.WatchTrackVersionsUseCase>(() =>
        _i168.WatchTrackVersionsUseCase(gh<_i156.TrackVersionRepository>()));
    gh.lazySingleton<_i169.WatchUserProfileUseCase>(
        () => _i169.WatchUserProfileUseCase(
              gh<_i161.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i170.WaveformRepository>(() => _i171.WaveformRepositoryImpl(
          localDataSource: gh<_i71.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i72.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i172.AcceptInvitationUseCase>(
        () => _i172.AcceptInvitationUseCase(
              invitationRepository: gh<_i99.InvitationRepository>(),
              projectRepository: gh<_i149.ProjectsRepository>(),
              userProfileRepository: gh<_i161.UserProfileRepository>(),
              notificationService: gh<_i37.NotificationService>(),
            ));
    gh.lazySingleton<_i173.AddCollaboratorToProjectUseCase>(
        () => _i173.AddCollaboratorToProjectUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i174.AppleSignInUseCase>(
        () => _i174.AppleSignInUseCase(gh<_i126.AuthRepository>()));
    gh.lazySingleton<_i175.AudioCommentRepository>(
        () => _i176.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i75.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i74.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i32.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i128.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i106.PendingOperationsManager>(),
              trackVersionRepository: gh<_i156.TrackVersionRepository>(),
            ));
    gh.factory<_i177.AudioSourceResolver>(() => _i178.AudioSourceResolverImpl(
          gh<_i122.AudioStorageRepository>(),
          gh<_i120.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i179.AudioTrackRepository>(
        () => _i180.AudioTrackRepositoryImpl(
              gh<_i76.AudioTrackLocalDataSource>(),
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i106.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i181.CacheMaintenanceService>(() =>
        _i182.CacheMaintenanceServiceImpl(
            gh<_i129.CacheManagementLocalDataSource>()));
    gh.factory<_i183.CheckProfileCompletenessUseCase>(() =>
        _i183.CheckProfileCompletenessUseCase(
            gh<_i161.UserProfileRepository>()));
    gh.factory<_i184.CleanupCacheUseCase>(
        () => _i184.CleanupCacheUseCase(gh<_i181.CacheMaintenanceService>()));
    gh.lazySingleton<_i185.CreateProjectUseCase>(
        () => _i185.CreateProjectUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i186.CreateUserProfileUseCase>(
        () => _i186.CreateUserProfileUseCase(
              gh<_i161.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i187.DeclineInvitationUseCase>(
        () => _i187.DeclineInvitationUseCase(
              invitationRepository: gh<_i99.InvitationRepository>(),
              projectRepository: gh<_i149.ProjectsRepository>(),
              userProfileRepository: gh<_i161.UserProfileRepository>(),
              notificationService: gh<_i37.NotificationService>(),
            ));
    gh.lazySingleton<_i188.DeleteTrackVersionUseCase>(
        () => _i188.DeleteTrackVersionUseCase(
              gh<_i156.TrackVersionRepository>(),
              gh<_i170.WaveformRepository>(),
              gh<_i175.AudioCommentRepository>(),
              gh<_i122.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i189.FindUserByEmailUseCase>(
        () => _i189.FindUserByEmailUseCase(gh<_i161.UserProfileRepository>()));
    gh.factory<_i190.GenerateAndStoreWaveform>(
        () => _i190.GenerateAndStoreWaveform(
              gh<_i170.WaveformRepository>(),
              gh<_i69.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i191.GetActiveVersionUseCase>(() =>
        _i191.GetActiveVersionUseCase(gh<_i156.TrackVersionRepository>()));
    gh.factory<_i192.GetCacheStorageStatsUseCase>(() =>
        _i192.GetCacheStorageStatsUseCase(gh<_i181.CacheMaintenanceService>()));
    gh.lazySingleton<_i193.GetProjectByIdUseCase>(
        () => _i193.GetProjectByIdUseCase(gh<_i149.ProjectsRepository>()));
    gh.lazySingleton<_i194.GetVersionByIdUseCase>(
        () => _i194.GetVersionByIdUseCase(gh<_i156.TrackVersionRepository>()));
    gh.factory<_i195.GetWaveformByVersion>(
        () => _i195.GetWaveformByVersion(gh<_i170.WaveformRepository>()));
    gh.lazySingleton<_i196.GoogleSignInUseCase>(() => _i196.GoogleSignInUseCase(
          gh<_i126.AuthRepository>(),
          gh<_i161.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i197.JoinProjectWithIdUseCase>(
        () => _i197.JoinProjectWithIdUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i198.LeaveProjectUseCase>(() => _i198.LeaveProjectUseCase(
          gh<_i149.ProjectsRepository>(),
          gh<_i109.SessionStorage>(),
        ));
    gh.factory<_i199.LoadTrackContextUseCase>(
        () => _i199.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i179.AudioTrackRepository>(),
              trackVersionRepository: gh<_i156.TrackVersionRepository>(),
              userProfileRepository: gh<_i161.UserProfileRepository>(),
              projectsRepository: gh<_i149.ProjectsRepository>(),
            ));
    gh.factory<_i200.MagicLinkBloc>(() => _i200.MagicLinkBloc(
          generateMagicLink: gh<_i135.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i68.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i80.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i50.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i84.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i197.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i126.AuthRepository>(),
        ));
    gh.factory<_i201.OnboardingBloc>(() => _i201.OnboardingBloc(
          onboardingUseCase: gh<_i145.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i138.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i202.PlayPlaylistUseCase>(() => _i202.PlayPlaylistUseCase(
          playlistRepository: gh<_i146.PlaylistRepository>(),
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i122.AudioStorageRepository>(),
        ));
    gh.factory<_i203.PlayVersionUseCase>(() => _i203.PlayVersionUseCase(
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          audioStorageRepository: gh<_i122.AudioStorageRepository>(),
          trackVersionRepository: gh<_i156.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i204.ProjectCommentService>(
        () => _i204.ProjectCommentService(gh<_i175.AudioCommentRepository>()));
    gh.lazySingleton<_i205.ProjectTrackService>(
        () => _i205.ProjectTrackService(gh<_i179.AudioTrackRepository>()));
    gh.lazySingleton<_i206.RenameTrackVersionUseCase>(() =>
        _i206.RenameTrackVersionUseCase(gh<_i156.TrackVersionRepository>()));
    gh.factory<_i207.RestorePlaybackStateUseCase>(
        () => _i207.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i44.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i179.AudioTrackRepository>(),
              audioStorageRepository: gh<_i122.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i208.SendInvitationUseCase>(
        () => _i208.SendInvitationUseCase(
              invitationRepository: gh<_i99.InvitationRepository>(),
              notificationService: gh<_i37.NotificationService>(),
              findUserByEmail: gh<_i189.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i29.MagicLinkRepository>(),
              currentUserService: gh<_i133.CurrentUserService>(),
            ));
    gh.factory<_i209.SessionCleanupService>(() => _i209.SessionCleanupService(
          userProfileRepository: gh<_i161.UserProfileRepository>(),
          projectsRepository: gh<_i149.ProjectsRepository>(),
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
          audioCommentRepository: gh<_i175.AudioCommentRepository>(),
          invitationRepository: gh<_i99.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i44.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i9.BlocStateCleanupService>(),
          sessionStorage: gh<_i109.SessionStorage>(),
          pendingOperationsRepository: gh<_i42.PendingOperationsRepository>(),
          waveformRepository: gh<_i170.WaveformRepository>(),
          trackVersionRepository: gh<_i156.TrackVersionRepository>(),
          syncCoordinator: gh<_i60.SyncCoordinator>(),
        ));
    gh.factory<_i210.SessionService>(() => _i210.SessionService(
          checkAuthUseCase: gh<_i132.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i138.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i145.OnboardingUseCase>(),
          profileUseCase: gh<_i183.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i211.SetActiveTrackVersionUseCase>(() =>
        _i211.SetActiveTrackVersionUseCase(gh<_i179.AudioTrackRepository>()));
    gh.lazySingleton<_i212.SignInUseCase>(() => _i212.SignInUseCase(
          gh<_i126.AuthRepository>(),
          gh<_i161.UserProfileRepository>(),
        ));
    gh.factory<_i213.SyncStatusCubit>(() => _i213.SyncStatusCubit(
          gh<_i110.SyncStatusProvider>(),
          gh<_i106.PendingOperationsManager>(),
          gh<_i158.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i214.TrackCacheBloc>(() => _i214.TrackCacheBloc(
          cacheTrackUseCase: gh<_i130.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i167.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i152.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i137.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i215.TriggerForegroundSyncUseCase>(
        () => _i215.TriggerForegroundSyncUseCase(
              gh<_i128.BackgroundSyncCoordinator>(),
              gh<_i210.SessionService>(),
            ));
    gh.factory<_i216.UpdateUserProfileUseCase>(
        () => _i216.UpdateUserProfileUseCase(
              gh<_i161.UserProfileRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.factory<_i217.UserProfileBloc>(() => _i217.UserProfileBloc(
          updateUserProfileUseCase: gh<_i216.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i186.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i169.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i183.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i138.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i218.WatchAudioCommentsBundleUseCase>(
        () => _i218.WatchAudioCommentsBundleUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i175.AudioCommentRepository>(),
              gh<_i112.UserProfileCacheRepository>(),
            ));
    gh.factory<_i219.WatchCachedTrackBundlesUseCase>(
        () => _i219.WatchCachedTrackBundlesUseCase(
              gh<_i181.CacheMaintenanceService>(),
              gh<_i179.AudioTrackRepository>(),
              gh<_i161.UserProfileRepository>(),
              gh<_i149.ProjectsRepository>(),
              gh<_i156.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i220.WatchProjectDetailUseCase>(
        () => _i220.WatchProjectDetailUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i179.AudioTrackRepository>(),
              gh<_i112.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i221.WatchProjectPlaylistUseCase>(
        () => _i221.WatchProjectPlaylistUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i156.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i222.WatchTrackVersionsBundleUseCase>(
        () => _i222.WatchTrackVersionsBundleUseCase(
              gh<_i179.AudioTrackRepository>(),
              gh<_i156.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i223.WatchTracksByProjectIdUseCase>(() =>
        _i223.WatchTracksByProjectIdUseCase(gh<_i179.AudioTrackRepository>()));
    gh.factory<_i224.WaveformBloc>(() => _i224.WaveformBloc(
          waveformRepository: gh<_i170.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i225.AddAudioCommentUseCase>(
        () => _i225.AddAudioCommentUseCase(
              gh<_i204.ProjectCommentService>(),
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i226.AddCollaboratorByEmailUseCase>(
        () => _i226.AddCollaboratorByEmailUseCase(
              gh<_i189.FindUserByEmailUseCase>(),
              gh<_i173.AddCollaboratorToProjectUseCase>(),
              gh<_i37.NotificationService>(),
            ));
    gh.lazySingleton<_i227.AddTrackVersionUseCase>(
        () => _i227.AddTrackVersionUseCase(
              gh<_i109.SessionStorage>(),
              gh<_i156.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i122.AudioStorageRepository>(),
              gh<_i190.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i228.AppBootstrap>(() => _i228.AppBootstrap(
          sessionService: gh<_i210.SessionService>(),
          performanceCollector: gh<_i43.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i13.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i82.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i229.AppFlowBloc>(() => _i229.AppFlowBloc(
          appBootstrap: gh<_i228.AppBootstrap>(),
          syncTrigger: gh<_i128.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i136.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i209.SessionCleanupService>(),
        ));
    gh.factory<_i230.AudioContextBloc>(() => _i230.AudioContextBloc(
        loadTrackContextUseCase: gh<_i199.LoadTrackContextUseCase>()));
    gh.factory<_i231.AudioPlayerService>(() => _i231.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i23.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i203.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i202.PlayPlaylistUseCase>(),
          audioTrackRepository: gh<_i179.AudioTrackRepository>(),
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
          restorePlaybackStateUseCase: gh<_i207.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i232.AuthBloc>(() => _i232.AuthBloc(
          signIn: gh<_i212.SignInUseCase>(),
          signUp: gh<_i154.SignUpUseCase>(),
          googleSignIn: gh<_i196.GoogleSignInUseCase>(),
          appleSignIn: gh<_i174.AppleSignInUseCase>(),
          signOut: gh<_i153.SignOutUseCase>(),
        ));
    gh.factory<_i233.CacheManagementBloc>(() => _i233.CacheManagementBloc(
          deleteOne: gh<_i134.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i166.WatchStorageUsageUseCase>(),
          getStats: gh<_i192.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i184.CleanupCacheUseCase>(),
          watchBundles: gh<_i219.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i234.DeleteAudioCommentUseCase>(
        () => _i234.DeleteAudioCommentUseCase(
              gh<_i204.ProjectCommentService>(),
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
            ));
    gh.lazySingleton<_i235.DeleteAudioTrack>(() => _i235.DeleteAudioTrack(
          gh<_i109.SessionStorage>(),
          gh<_i149.ProjectsRepository>(),
          gh<_i205.ProjectTrackService>(),
          gh<_i156.TrackVersionRepository>(),
          gh<_i170.WaveformRepository>(),
          gh<_i122.AudioStorageRepository>(),
          gh<_i175.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i236.DeleteProjectUseCase>(
        () => _i236.DeleteProjectUseCase(
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
              gh<_i205.ProjectTrackService>(),
              gh<_i235.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i237.EditAudioTrackUseCase>(
        () => _i237.EditAudioTrackUseCase(
              gh<_i205.ProjectTrackService>(),
              gh<_i149.ProjectsRepository>(),
            ));
    gh.factory<_i238.ManageCollaboratorsBloc>(
        () => _i238.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i151.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i159.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i198.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i226.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i165.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i239.PlaylistBloc>(
        () => _i239.PlaylistBloc(gh<_i221.WatchProjectPlaylistUseCase>()));
    gh.factory<_i240.ProjectDetailBloc>(() => _i240.ProjectDetailBloc(
        watchProjectDetail: gh<_i220.WatchProjectDetailUseCase>()));
    gh.factory<_i241.ProjectInvitationActorBloc>(
        () => _i241.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i208.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i172.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i187.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i131.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i242.ProjectsBloc>(() => _i242.ProjectsBloc(
          createProject: gh<_i185.CreateProjectUseCase>(),
          updateProject: gh<_i160.UpdateProjectUseCase>(),
          deleteProject: gh<_i236.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i163.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i243.TrackVersionsBloc>(() => _i243.TrackVersionsBloc(
          gh<_i222.WatchTrackVersionsBundleUseCase>(),
          gh<_i211.SetActiveTrackVersionUseCase>(),
          gh<_i227.AddTrackVersionUseCase>(),
          gh<_i206.RenameTrackVersionUseCase>(),
          gh<_i188.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i244.UploadAudioTrackUseCase>(
        () => _i244.UploadAudioTrackUseCase(
              gh<_i205.ProjectTrackService>(),
              gh<_i149.ProjectsRepository>(),
              gh<_i109.SessionStorage>(),
              gh<_i227.AddTrackVersionUseCase>(),
              gh<_i179.AudioTrackRepository>(),
            ));
    gh.factory<_i245.AudioCommentBloc>(() => _i245.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i225.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i234.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i218.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i246.AudioPlayerBloc>(() => _i246.AudioPlayerBloc(
        audioPlayerService: gh<_i231.AudioPlayerService>()));
    gh.factory<_i247.AudioTrackBloc>(() => _i247.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i223.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i235.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i244.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i237.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i248.AppModule {}
