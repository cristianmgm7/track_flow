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
import 'package:shared_preferences/shared_preferences.dart' as _i54;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i107;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i13;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i226;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i207;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i208;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i130;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i134;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i136;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i227;
import 'package:trackflow/core/di/app_module.dart' as _i246;
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
    as _i79;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i83;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i138;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i99;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i100;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i36;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i139;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i140;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i80;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i41;
import 'package:trackflow/core/session/current_user_service.dart' as _i131;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i117;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i122;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i109;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i113;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i126;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i18;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i104;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i58;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i108;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i213;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i156;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i211;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i76;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart'
    as _i77;
import 'package:trackflow/features/audio_cache/data/repositories/audio_download_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart'
    as _i118;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i150;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i165;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i162;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i212;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i73;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i87;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i174;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i88;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i173;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i202;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i223;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i232;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i216;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i243;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i197;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i228;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i42;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i229;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i175;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i200;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i201;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i205;
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
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i43;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i176;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i244;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i89;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i178;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i90;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i177;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i203;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i233;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i235;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i242;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i221;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i114;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i245;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i153;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i123;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i125;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i71;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i84;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i124;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i172;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i194;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i210;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i151;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i152;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i230;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i127;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i180;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i179;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i182;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i132;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i190;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i217;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i164;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i231;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i96;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i23;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i98;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i97;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i170;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i129;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i185;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i137;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i101;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i102;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i206;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i239;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i146;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i26;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i28;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i78;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i133;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i82;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i48;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i198;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i224;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i171;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i187;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i195;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i196;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i149;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i157;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i163;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i236;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i29;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i20;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i103;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i142;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i143;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i141;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i199;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i145;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i144;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i219;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i237;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i218;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i238;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i47;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i93;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i148;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i94;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i147;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i183;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i234;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i191;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i158;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i161;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i240;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i62;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i63;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i85;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i155;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i86;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i154;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i225;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i186;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i189;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i192;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i204;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i209;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i220;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i166;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i241;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i61;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i91;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i111;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i160;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i112;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i92;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i159;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i110;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i181;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i184;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i214;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i167;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i115;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i215;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i69;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i70;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i169;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i68;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i95;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i168;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i67;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i188;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i193;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i222;

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
    gh.factory<_i41.PerformanceMetricsCollector>(
        () => _i41.PerformanceMetricsCollector());
    gh.lazySingleton<_i42.PlaybackPersistenceRepository>(
        () => _i43.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i44.PlaylistLocalDataSource>(
        () => _i44.PlaylistLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i45.PlaylistRemoteDataSource>(
        () => _i45.PlaylistRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i46.ProjectRemoteDataSource>(() =>
        _i46.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i47.ProjectsLocalDataSource>(
        () => _i47.ProjectsLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i48.ResendMagicLinkUseCase>(
        () => _i48.ResendMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
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
    gh.lazySingleton<_i58.SyncCoordinator>(
        () => _i58.SyncCoordinator(gh<_i54.SharedPreferences>()));
    gh.factory<_i59.ToggleRepeatModeUseCase>(() => _i59.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.ToggleShuffleUseCase>(() => _i60.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i61.TrackDetailCubit>(() => _i61.TrackDetailCubit());
    gh.lazySingleton<_i62.TrackVersionLocalDataSource>(
        () => _i62.IsarTrackVersionLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i63.TrackVersionRemoteDataSource>(
        () => _i63.TrackVersionRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i64.UserProfileLocalDataSource>(
        () => _i64.IsarUserProfileLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i65.UserProfileRemoteDataSource>(
        () => _i65.UserProfileRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i66.ValidateMagicLinkUseCase>(
        () => _i66.ValidateMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i67.WaveformGeneratorService>(() =>
        _i68.JustWaveformGeneratorService(cacheDir: gh<_i11.Directory>()));
    gh.factory<_i69.WaveformLocalDataSource>(
        () => _i69.WaveformLocalDataSourceImpl(isar: gh<_i24.Isar>()));
    gh.lazySingleton<_i70.WaveformRemoteDataSource>(() =>
        _i70.FirebaseStorageWaveformRemoteDataSource(
            gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i71.AppleAuthService>(
        () => _i71.AppleAuthService(gh<_i14.FirebaseAuth>()));
    gh.lazySingleton<_i72.AudioCommentLocalDataSource>(
        () => _i72.IsarAudioCommentLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i73.AudioCommentRemoteDataSource>(() =>
        _i73.FirebaseAudioCommentRemoteDataSource(
            gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i74.AudioTrackLocalDataSource>(
        () => _i74.IsarAudioTrackLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i75.AudioTrackRemoteDataSource>(() =>
        _i75.AudioTrackRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i76.CacheStorageLocalDataSource>(
        () => _i76.CacheStorageLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i77.CacheStorageRemoteDataSource>(() =>
        _i77.CacheStorageRemoteDataSourceImpl(gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i78.ConsumeMagicLinkUseCase>(
        () => _i78.ConsumeMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i79.CreateNotificationUseCase>(() =>
        _i79.CreateNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i80.DatabaseHealthMonitor>(
        () => _i80.DatabaseHealthMonitor(gh<_i24.Isar>()));
    gh.factory<_i81.DeleteNotificationUseCase>(() =>
        _i81.DeleteNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i82.GetMagicLinkStatusUseCase>(
        () => _i82.GetMagicLinkStatusUseCase(gh<_i27.MagicLinkRepository>()));
    gh.lazySingleton<_i83.GetUnreadNotificationsCountUseCase>(() =>
        _i83.GetUnreadNotificationsCountUseCase(
            gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i84.GoogleAuthService>(() => _i84.GoogleAuthService(
          gh<_i17.GoogleSignIn>(),
          gh<_i14.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i85.TrackVersionDTO>>(
        () => _i86.TrackVersionIncrementalSyncService(
              gh<_i63.TrackVersionRemoteDataSource>(),
              gh<_i62.TrackVersionLocalDataSource>(),
              gh<_i74.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i87.AudioCommentDTO>>(
        () => _i88.AudioCommentIncrementalSyncService(
              gh<_i73.AudioCommentRemoteDataSource>(),
              gh<_i72.AudioCommentLocalDataSource>(),
              gh<_i62.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i89.AudioTrackDTO>>(
        () => _i90.AudioTrackIncrementalSyncService(
              gh<_i75.AudioTrackRemoteDataSource>(),
              gh<_i74.AudioTrackLocalDataSource>(),
              gh<_i47.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i91.UserProfileDTO>>(
        () => _i92.UserProfileIncrementalSyncService(
              gh<_i65.UserProfileRemoteDataSource>(),
              gh<_i64.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i93.ProjectDTO>>(
        () => _i94.ProjectIncrementalSyncService(
              gh<_i46.ProjectRemoteDataSource>(),
              gh<_i47.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<dynamic>>(
        () => _i95.WaveformIncrementalSyncService(
              gh<_i62.TrackVersionLocalDataSource>(),
              gh<_i69.WaveformLocalDataSource>(),
              gh<_i70.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i96.InvitationLocalDataSource>(
        () => _i96.IsarInvitationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i97.InvitationRepository>(
        () => _i98.InvitationRepositoryImpl(
              localDataSource: gh<_i96.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i23.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
            ));
    gh.factory<_i99.MarkAsUnreadUseCase>(
        () => _i99.MarkAsUnreadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i100.MarkNotificationAsReadUseCase>(() =>
        _i100.MarkNotificationAsReadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i101.ObservePendingInvitationsUseCase>(() =>
        _i101.ObservePendingInvitationsUseCase(
            gh<_i97.InvitationRepository>()));
    gh.lazySingleton<_i102.ObserveSentInvitationsUseCase>(() =>
        _i102.ObserveSentInvitationsUseCase(gh<_i97.InvitationRepository>()));
    gh.lazySingleton<_i103.OnboardingStateLocalDataSource>(() =>
        _i103.OnboardingStateLocalDataSourceImpl(gh<_i54.SharedPreferences>()));
    gh.lazySingleton<_i104.PendingOperationsManager>(
        () => _i104.PendingOperationsManager(
              gh<_i40.PendingOperationsRepository>(),
              gh<_i30.NetworkStateManager>(),
              gh<_i37.OperationExecutorFactory>(),
            ));
    gh.factory<_i105.PlaylistOperationExecutor>(() =>
        _i105.PlaylistOperationExecutor(gh<_i45.PlaylistRemoteDataSource>()));
    gh.factory<_i106.ProjectOperationExecutor>(() =>
        _i106.ProjectOperationExecutor(gh<_i46.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i107.SessionStorage>(
        () => _i107.SessionStorageImpl(prefs: gh<_i54.SharedPreferences>()));
    gh.factory<_i108.SyncStatusProvider>(() => _i108.SyncStatusProvider(
          syncCoordinator: gh<_i58.SyncCoordinator>(),
          pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
        ));
    gh.factory<_i109.TrackVersionOperationExecutor>(
        () => _i109.TrackVersionOperationExecutor(
              gh<_i63.TrackVersionRemoteDataSource>(),
              gh<_i62.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i110.UserProfileCacheRepository>(
        () => _i111.UserProfileCacheRepositoryImpl(
              gh<_i65.UserProfileRemoteDataSource>(),
              gh<_i64.UserProfileLocalDataSource>(),
              gh<_i30.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i112.UserProfileCollaboratorIncrementalSyncService>(
        () => _i112.UserProfileCollaboratorIncrementalSyncService(
              gh<_i65.UserProfileRemoteDataSource>(),
              gh<_i64.UserProfileLocalDataSource>(),
              gh<_i47.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i113.UserProfileOperationExecutor>(() =>
        _i113.UserProfileOperationExecutor(
            gh<_i65.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i114.WatchTrackUploadStatusUseCase>(() =>
        _i114.WatchTrackUploadStatusUseCase(
            gh<_i104.PendingOperationsManager>()));
    gh.lazySingleton<_i115.WatchUserProfilesUseCase>(() =>
        _i115.WatchUserProfilesUseCase(gh<_i110.UserProfileCacheRepository>()));
    gh.factory<_i116.WaveformOperationExecutor>(() =>
        _i116.WaveformOperationExecutor(gh<_i70.WaveformRemoteDataSource>()));
    gh.factory<_i117.AudioCommentOperationExecutor>(() =>
        _i117.AudioCommentOperationExecutor(
            gh<_i73.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i118.AudioDownloadRepository>(
        () => _i119.AudioDownloadRepositoryImpl(
              remoteDataSource: gh<_i77.CacheStorageRemoteDataSource>(),
              localDataSource: gh<_i76.CacheStorageLocalDataSource>(),
            ));
    gh.lazySingleton<_i120.AudioStorageRepository>(() =>
        _i121.AudioStorageRepositoryImpl(
            localDataSource: gh<_i76.CacheStorageLocalDataSource>()));
    gh.factory<_i122.AudioTrackOperationExecutor>(
        () => _i122.AudioTrackOperationExecutor(
              gh<_i75.AudioTrackRemoteDataSource>(),
              gh<_i74.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i123.AuthRemoteDataSource>(
        () => _i123.AuthRemoteDataSourceImpl(
              gh<_i14.FirebaseAuth>(),
              gh<_i84.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i124.AuthRepository>(() => _i125.AuthRepositoryImpl(
          remote: gh<_i123.AuthRemoteDataSource>(),
          sessionStorage: gh<_i107.SessionStorage>(),
          networkStateManager: gh<_i30.NetworkStateManager>(),
          googleAuthService: gh<_i84.GoogleAuthService>(),
          appleAuthService: gh<_i71.AppleAuthService>(),
        ));
    gh.lazySingleton<_i126.BackgroundSyncCoordinator>(
        () => _i126.BackgroundSyncCoordinator(
              gh<_i30.NetworkStateManager>(),
              gh<_i58.SyncCoordinator>(),
              gh<_i104.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i127.CacheManagementLocalDataSource>(() =>
        _i127.CacheManagementLocalDataSourceImpl(
            local: gh<_i76.CacheStorageLocalDataSource>()));
    gh.factory<_i128.CacheTrackUseCase>(() => _i128.CacheTrackUseCase(
          gh<_i118.AudioDownloadRepository>(),
          gh<_i120.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i129.CancelInvitationUseCase>(
        () => _i129.CancelInvitationUseCase(gh<_i97.InvitationRepository>()));
    gh.factory<_i130.CheckAuthenticationStatusUseCase>(() =>
        _i130.CheckAuthenticationStatusUseCase(gh<_i124.AuthRepository>()));
    gh.factory<_i131.CurrentUserService>(
        () => _i131.CurrentUserService(gh<_i107.SessionStorage>()));
    gh.factory<_i132.DeleteCachedAudioUseCase>(() =>
        _i132.DeleteCachedAudioUseCase(gh<_i120.AudioStorageRepository>()));
    gh.lazySingleton<_i133.GenerateMagicLinkUseCase>(
        () => _i133.GenerateMagicLinkUseCase(
              gh<_i27.MagicLinkRepository>(),
              gh<_i124.AuthRepository>(),
            ));
    gh.lazySingleton<_i134.GetAuthStateUseCase>(
        () => _i134.GetAuthStateUseCase(gh<_i124.AuthRepository>()));
    gh.factory<_i135.GetCachedTrackPathUseCase>(() =>
        _i135.GetCachedTrackPathUseCase(gh<_i120.AudioStorageRepository>()));
    gh.factory<_i136.GetCurrentUserUseCase>(
        () => _i136.GetCurrentUserUseCase(gh<_i124.AuthRepository>()));
    gh.lazySingleton<_i137.GetPendingInvitationsCountUseCase>(() =>
        _i137.GetPendingInvitationsCountUseCase(
            gh<_i97.InvitationRepository>()));
    gh.factory<_i138.MarkAllNotificationsAsReadUseCase>(
        () => _i138.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i131.CurrentUserService>(),
            ));
    gh.factory<_i139.NotificationActorBloc>(() => _i139.NotificationActorBloc(
          createNotificationUseCase: gh<_i79.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i100.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i99.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i138.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i81.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i140.NotificationWatcherBloc>(
        () => _i140.NotificationWatcherBloc(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i131.CurrentUserService>(),
            ));
    gh.lazySingleton<_i141.OnboardingRepository>(() =>
        _i142.OnboardingRepositoryImpl(
            gh<_i103.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i143.OnboardingUseCase>(
        () => _i143.OnboardingUseCase(gh<_i141.OnboardingRepository>()));
    gh.lazySingleton<_i144.PlaylistRepository>(
        () => _i145.PlaylistRepositoryImpl(
              localDataSource: gh<_i44.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i126.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
            ));
    gh.factory<_i146.ProjectInvitationWatcherBloc>(
        () => _i146.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i97.InvitationRepository>(),
              currentUserService: gh<_i131.CurrentUserService>(),
            ));
    gh.lazySingleton<_i147.ProjectsRepository>(
        () => _i148.ProjectsRepositoryImpl(
              localDataSource: gh<_i47.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i126.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i149.RemoveCollaboratorUseCase>(
        () => _i149.RemoveCollaboratorUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.factory<_i150.RemoveTrackCacheUseCase>(() =>
        _i150.RemoveTrackCacheUseCase(gh<_i120.AudioStorageRepository>()));
    gh.lazySingleton<_i151.SignOutUseCase>(
        () => _i151.SignOutUseCase(gh<_i124.AuthRepository>()));
    gh.lazySingleton<_i152.SignUpUseCase>(
        () => _i152.SignUpUseCase(gh<_i124.AuthRepository>()));
    gh.factory<_i153.TrackUploadStatusCubit>(() => _i153.TrackUploadStatusCubit(
        gh<_i114.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i154.TrackVersionRepository>(
        () => _i155.TrackVersionRepositoryImpl(
              gh<_i62.TrackVersionLocalDataSource>(),
              gh<_i126.BackgroundSyncCoordinator>(),
              gh<_i104.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i156.TriggerUpstreamSyncUseCase>(() =>
        _i156.TriggerUpstreamSyncUseCase(
            gh<_i126.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i157.UpdateCollaboratorRoleUseCase>(
        () => _i157.UpdateCollaboratorRoleUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i158.UpdateProjectUseCase>(
        () => _i158.UpdateProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.UserProfileRepository>(
        () => _i160.UserProfileRepositoryImpl(
              localDataSource: gh<_i64.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i65.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i126.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
              firestore: gh<_i15.FirebaseFirestore>(),
              sessionStorage: gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i161.WatchAllProjectsUseCase>(
        () => _i161.WatchAllProjectsUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.factory<_i162.WatchCachedAudiosUseCase>(() =>
        _i162.WatchCachedAudiosUseCase(gh<_i120.AudioStorageRepository>()));
    gh.lazySingleton<_i163.WatchCollaboratorsBundleUseCase>(
        () => _i163.WatchCollaboratorsBundleUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i115.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i164.WatchStorageUsageUseCase>(() =>
        _i164.WatchStorageUsageUseCase(gh<_i120.AudioStorageRepository>()));
    gh.factory<_i165.WatchTrackCacheStatusUseCase>(() =>
        _i165.WatchTrackCacheStatusUseCase(gh<_i120.AudioStorageRepository>()));
    gh.lazySingleton<_i166.WatchTrackVersionsUseCase>(() =>
        _i166.WatchTrackVersionsUseCase(gh<_i154.TrackVersionRepository>()));
    gh.lazySingleton<_i167.WatchUserProfileUseCase>(
        () => _i167.WatchUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.factory<_i168.WaveformRepository>(() => _i169.WaveformRepositoryImpl(
          localDataSource: gh<_i69.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i70.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i126.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i170.AcceptInvitationUseCase>(
        () => _i170.AcceptInvitationUseCase(
              invitationRepository: gh<_i97.InvitationRepository>(),
              projectRepository: gh<_i147.ProjectsRepository>(),
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i171.AddCollaboratorToProjectUseCase>(
        () => _i171.AddCollaboratorToProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.AppleSignInUseCase>(
        () => _i172.AppleSignInUseCase(gh<_i124.AuthRepository>()));
    gh.lazySingleton<_i173.AudioCommentRepository>(
        () => _i174.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i73.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i72.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i126.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i104.PendingOperationsManager>(),
              trackVersionRepository: gh<_i154.TrackVersionRepository>(),
            ));
    gh.factory<_i175.AudioSourceResolver>(() => _i176.AudioSourceResolverImpl(
          gh<_i120.AudioStorageRepository>(),
          gh<_i118.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i177.AudioTrackRepository>(
        () => _i178.AudioTrackRepositoryImpl(
              gh<_i74.AudioTrackLocalDataSource>(),
              gh<_i126.BackgroundSyncCoordinator>(),
              gh<_i104.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i179.CacheMaintenanceService>(() =>
        _i180.CacheMaintenanceServiceImpl(
            gh<_i127.CacheManagementLocalDataSource>()));
    gh.factory<_i181.CheckProfileCompletenessUseCase>(() =>
        _i181.CheckProfileCompletenessUseCase(
            gh<_i159.UserProfileRepository>()));
    gh.factory<_i182.CleanupCacheUseCase>(
        () => _i182.CleanupCacheUseCase(gh<_i179.CacheMaintenanceService>()));
    gh.lazySingleton<_i183.CreateProjectUseCase>(
        () => _i183.CreateProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.factory<_i184.CreateUserProfileUseCase>(
        () => _i184.CreateUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i185.DeclineInvitationUseCase>(
        () => _i185.DeclineInvitationUseCase(
              invitationRepository: gh<_i97.InvitationRepository>(),
              projectRepository: gh<_i147.ProjectsRepository>(),
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i186.DeleteTrackVersionUseCase>(
        () => _i186.DeleteTrackVersionUseCase(
              gh<_i154.TrackVersionRepository>(),
              gh<_i168.WaveformRepository>(),
              gh<_i173.AudioCommentRepository>(),
              gh<_i120.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i187.FindUserByEmailUseCase>(
        () => _i187.FindUserByEmailUseCase(gh<_i159.UserProfileRepository>()));
    gh.factory<_i188.GenerateAndStoreWaveform>(
        () => _i188.GenerateAndStoreWaveform(
              gh<_i168.WaveformRepository>(),
              gh<_i67.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i189.GetActiveVersionUseCase>(() =>
        _i189.GetActiveVersionUseCase(gh<_i154.TrackVersionRepository>()));
    gh.factory<_i190.GetCacheStorageStatsUseCase>(() =>
        _i190.GetCacheStorageStatsUseCase(gh<_i179.CacheMaintenanceService>()));
    gh.lazySingleton<_i191.GetProjectByIdUseCase>(
        () => _i191.GetProjectByIdUseCase(gh<_i147.ProjectsRepository>()));
    gh.lazySingleton<_i192.GetVersionByIdUseCase>(
        () => _i192.GetVersionByIdUseCase(gh<_i154.TrackVersionRepository>()));
    gh.factory<_i193.GetWaveformByVersion>(
        () => _i193.GetWaveformByVersion(gh<_i168.WaveformRepository>()));
    gh.lazySingleton<_i194.GoogleSignInUseCase>(() => _i194.GoogleSignInUseCase(
          gh<_i124.AuthRepository>(),
          gh<_i159.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i195.JoinProjectWithIdUseCase>(
        () => _i195.JoinProjectWithIdUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i196.LeaveProjectUseCase>(() => _i196.LeaveProjectUseCase(
          gh<_i147.ProjectsRepository>(),
          gh<_i107.SessionStorage>(),
        ));
    gh.factory<_i197.LoadTrackContextUseCase>(
        () => _i197.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i177.AudioTrackRepository>(),
              trackVersionRepository: gh<_i154.TrackVersionRepository>(),
              userProfileRepository: gh<_i159.UserProfileRepository>(),
              projectsRepository: gh<_i147.ProjectsRepository>(),
            ));
    gh.factory<_i198.MagicLinkBloc>(() => _i198.MagicLinkBloc(
          generateMagicLink: gh<_i133.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i66.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i78.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i48.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i82.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i195.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i124.AuthRepository>(),
        ));
    gh.factory<_i199.OnboardingBloc>(() => _i199.OnboardingBloc(
          onboardingUseCase: gh<_i143.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i136.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i200.PlayPlaylistUseCase>(() => _i200.PlayPlaylistUseCase(
          playlistRepository: gh<_i144.PlaylistRepository>(),
          audioTrackRepository: gh<_i177.AudioTrackRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i120.AudioStorageRepository>(),
        ));
    gh.factory<_i201.PlayVersionUseCase>(() => _i201.PlayVersionUseCase(
          audioTrackRepository: gh<_i177.AudioTrackRepository>(),
          audioStorageRepository: gh<_i120.AudioStorageRepository>(),
          trackVersionRepository: gh<_i154.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i202.ProjectCommentService>(
        () => _i202.ProjectCommentService(gh<_i173.AudioCommentRepository>()));
    gh.lazySingleton<_i203.ProjectTrackService>(
        () => _i203.ProjectTrackService(gh<_i177.AudioTrackRepository>()));
    gh.lazySingleton<_i204.RenameTrackVersionUseCase>(() =>
        _i204.RenameTrackVersionUseCase(gh<_i154.TrackVersionRepository>()));
    gh.factory<_i205.RestorePlaybackStateUseCase>(
        () => _i205.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i42.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i177.AudioTrackRepository>(),
              audioStorageRepository: gh<_i120.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i206.SendInvitationUseCase>(
        () => _i206.SendInvitationUseCase(
              invitationRepository: gh<_i97.InvitationRepository>(),
              notificationService: gh<_i35.NotificationService>(),
              findUserByEmail: gh<_i187.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i27.MagicLinkRepository>(),
              currentUserService: gh<_i131.CurrentUserService>(),
            ));
    gh.factory<_i207.SessionCleanupService>(() => _i207.SessionCleanupService(
          userProfileRepository: gh<_i159.UserProfileRepository>(),
          projectsRepository: gh<_i147.ProjectsRepository>(),
          audioTrackRepository: gh<_i177.AudioTrackRepository>(),
          audioCommentRepository: gh<_i173.AudioCommentRepository>(),
          invitationRepository: gh<_i97.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i42.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i107.SessionStorage>(),
          pendingOperationsRepository: gh<_i40.PendingOperationsRepository>(),
          waveformRepository: gh<_i168.WaveformRepository>(),
          trackVersionRepository: gh<_i154.TrackVersionRepository>(),
          syncCoordinator: gh<_i58.SyncCoordinator>(),
        ));
    gh.factory<_i208.SessionService>(() => _i208.SessionService(
          checkAuthUseCase: gh<_i130.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i136.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i143.OnboardingUseCase>(),
          profileUseCase: gh<_i181.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i209.SetActiveTrackVersionUseCase>(() =>
        _i209.SetActiveTrackVersionUseCase(gh<_i177.AudioTrackRepository>()));
    gh.lazySingleton<_i210.SignInUseCase>(() => _i210.SignInUseCase(
          gh<_i124.AuthRepository>(),
          gh<_i159.UserProfileRepository>(),
        ));
    gh.factory<_i211.SyncStatusCubit>(() => _i211.SyncStatusCubit(
          gh<_i108.SyncStatusProvider>(),
          gh<_i104.PendingOperationsManager>(),
          gh<_i156.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i212.TrackCacheBloc>(() => _i212.TrackCacheBloc(
          cacheTrackUseCase: gh<_i128.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i165.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i150.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i135.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i213.TriggerForegroundSyncUseCase>(
        () => _i213.TriggerForegroundSyncUseCase(
              gh<_i126.BackgroundSyncCoordinator>(),
              gh<_i208.SessionService>(),
            ));
    gh.factory<_i214.UpdateUserProfileUseCase>(
        () => _i214.UpdateUserProfileUseCase(
              gh<_i159.UserProfileRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.factory<_i215.UserProfileBloc>(() => _i215.UserProfileBloc(
          updateUserProfileUseCase: gh<_i214.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i184.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i167.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i181.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i136.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i216.WatchAudioCommentsBundleUseCase>(
        () => _i216.WatchAudioCommentsBundleUseCase(
              gh<_i177.AudioTrackRepository>(),
              gh<_i173.AudioCommentRepository>(),
              gh<_i110.UserProfileCacheRepository>(),
            ));
    gh.factory<_i217.WatchCachedTrackBundlesUseCase>(
        () => _i217.WatchCachedTrackBundlesUseCase(
              gh<_i179.CacheMaintenanceService>(),
              gh<_i177.AudioTrackRepository>(),
              gh<_i159.UserProfileRepository>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i154.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i218.WatchProjectDetailUseCase>(
        () => _i218.WatchProjectDetailUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i177.AudioTrackRepository>(),
              gh<_i110.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i219.WatchProjectPlaylistUseCase>(
        () => _i219.WatchProjectPlaylistUseCase(
              gh<_i177.AudioTrackRepository>(),
              gh<_i154.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i220.WatchTrackVersionsBundleUseCase>(
        () => _i220.WatchTrackVersionsBundleUseCase(
              gh<_i177.AudioTrackRepository>(),
              gh<_i154.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i221.WatchTracksByProjectIdUseCase>(() =>
        _i221.WatchTracksByProjectIdUseCase(gh<_i177.AudioTrackRepository>()));
    gh.factory<_i222.WaveformBloc>(() => _i222.WaveformBloc(
          waveformRepository: gh<_i168.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i223.AddAudioCommentUseCase>(
        () => _i223.AddAudioCommentUseCase(
              gh<_i202.ProjectCommentService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i224.AddCollaboratorByEmailUseCase>(
        () => _i224.AddCollaboratorByEmailUseCase(
              gh<_i187.FindUserByEmailUseCase>(),
              gh<_i171.AddCollaboratorToProjectUseCase>(),
              gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i225.AddTrackVersionUseCase>(
        () => _i225.AddTrackVersionUseCase(
              gh<_i107.SessionStorage>(),
              gh<_i154.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i120.AudioStorageRepository>(),
              gh<_i188.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i226.AppBootstrap>(() => _i226.AppBootstrap(
          sessionService: gh<_i208.SessionService>(),
          performanceCollector: gh<_i41.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i12.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i80.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i227.AppFlowBloc>(() => _i227.AppFlowBloc(
          appBootstrap: gh<_i226.AppBootstrap>(),
          syncTrigger: gh<_i126.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i134.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i207.SessionCleanupService>(),
        ));
    gh.factory<_i228.AudioContextBloc>(() => _i228.AudioContextBloc(
        loadTrackContextUseCase: gh<_i197.LoadTrackContextUseCase>()));
    gh.factory<_i229.AudioPlayerService>(() => _i229.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i21.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i201.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i200.PlayPlaylistUseCase>(),
          audioTrackRepository: gh<_i177.AudioTrackRepository>(),
          pauseAudioUseCase: gh<_i38.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i49.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i57.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i55.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i56.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i51.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i60.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i59.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i53.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i52.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i50.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i205.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i230.AuthBloc>(() => _i230.AuthBloc(
          signIn: gh<_i210.SignInUseCase>(),
          signUp: gh<_i152.SignUpUseCase>(),
          googleSignIn: gh<_i194.GoogleSignInUseCase>(),
          appleSignIn: gh<_i172.AppleSignInUseCase>(),
          signOut: gh<_i151.SignOutUseCase>(),
        ));
    gh.factory<_i231.CacheManagementBloc>(() => _i231.CacheManagementBloc(
          deleteOne: gh<_i132.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i164.WatchStorageUsageUseCase>(),
          getStats: gh<_i190.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i182.CleanupCacheUseCase>(),
          watchBundles: gh<_i217.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i232.DeleteAudioCommentUseCase>(
        () => _i232.DeleteAudioCommentUseCase(
              gh<_i202.ProjectCommentService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
            ));
    gh.lazySingleton<_i233.DeleteAudioTrack>(() => _i233.DeleteAudioTrack(
          gh<_i107.SessionStorage>(),
          gh<_i147.ProjectsRepository>(),
          gh<_i203.ProjectTrackService>(),
          gh<_i154.TrackVersionRepository>(),
          gh<_i168.WaveformRepository>(),
          gh<_i120.AudioStorageRepository>(),
          gh<_i173.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i234.DeleteProjectUseCase>(
        () => _i234.DeleteProjectUseCase(
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
              gh<_i203.ProjectTrackService>(),
              gh<_i233.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i235.EditAudioTrackUseCase>(
        () => _i235.EditAudioTrackUseCase(
              gh<_i203.ProjectTrackService>(),
              gh<_i147.ProjectsRepository>(),
            ));
    gh.factory<_i236.ManageCollaboratorsBloc>(
        () => _i236.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i149.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i157.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i196.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i187.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i224.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i163.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i237.PlaylistBloc>(
        () => _i237.PlaylistBloc(gh<_i219.WatchProjectPlaylistUseCase>()));
    gh.factory<_i238.ProjectDetailBloc>(() => _i238.ProjectDetailBloc(
        watchProjectDetail: gh<_i218.WatchProjectDetailUseCase>()));
    gh.factory<_i239.ProjectInvitationActorBloc>(
        () => _i239.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i206.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i170.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i185.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i129.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i187.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i240.ProjectsBloc>(() => _i240.ProjectsBloc(
          createProject: gh<_i183.CreateProjectUseCase>(),
          updateProject: gh<_i158.UpdateProjectUseCase>(),
          deleteProject: gh<_i234.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i161.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i241.TrackVersionsBloc>(() => _i241.TrackVersionsBloc(
          gh<_i220.WatchTrackVersionsBundleUseCase>(),
          gh<_i209.SetActiveTrackVersionUseCase>(),
          gh<_i225.AddTrackVersionUseCase>(),
          gh<_i204.RenameTrackVersionUseCase>(),
          gh<_i186.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i242.UploadAudioTrackUseCase>(
        () => _i242.UploadAudioTrackUseCase(
              gh<_i203.ProjectTrackService>(),
              gh<_i147.ProjectsRepository>(),
              gh<_i107.SessionStorage>(),
              gh<_i225.AddTrackVersionUseCase>(),
              gh<_i177.AudioTrackRepository>(),
            ));
    gh.factory<_i243.AudioCommentBloc>(() => _i243.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i223.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i232.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i216.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i244.AudioPlayerBloc>(() => _i244.AudioPlayerBloc(
        audioPlayerService: gh<_i229.AudioPlayerService>()));
    gh.factory<_i245.AudioTrackBloc>(() => _i245.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i221.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i233.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i242.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i235.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i246.AppModule {}
