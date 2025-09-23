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
import 'package:shared_preferences/shared_preferences.dart' as _i53;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i96;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i14;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i223;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i9;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i206;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i207;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i123;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i127;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i129;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i224;
import 'package:trackflow/core/di/app_module.dart' as _i246;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i8;
import 'package:trackflow/core/network/network_state_manager.dart' as _i29;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i30;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i31;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i33;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i32;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i34;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i78;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i80;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i131;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i87;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i88;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i35;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i132;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i133;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i79;
import 'package:trackflow/core/services/deep_link_service.dart' as _i11;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i13;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i19;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i40;
import 'package:trackflow/core/session/current_user_service.dart' as _i124;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i38;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i39;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i36;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i93;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i95;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i103;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i109;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i159;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i92;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i156;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i57;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i157;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i97;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i141;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i98;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i99;
import 'package:trackflow/core/sync/domain/usecases/sync_track_versions_usecase.dart'
    as _i142;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i143;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i100;
import 'package:trackflow/core/sync/domain/usecases/sync_waveforms_usecase.dart'
    as _i101;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i167;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i210;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i75;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart'
    as _i76;
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
    as _i147;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i158;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i71;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i181;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i180;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i201;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i220;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i230;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i213;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i242;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i225;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i234;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i226;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i243;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i227;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i149;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i20;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i37;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i200;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i204;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i48;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i49;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i50;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i51;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i42;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i150;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i244;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i183;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i115;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i182;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i202;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i231;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i233;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i241;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i218;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i107;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i245;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i144;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i117;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i70;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i83;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i118;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i148;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i195;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i209;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i139;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i140;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i228;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i120;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i152;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i151;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i153;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i125;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i154;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i214;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i146;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i229;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i84;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i22;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i86;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i85;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i178;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i122;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i187;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i130;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i89;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i90;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i205;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i238;
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
    as _i77;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i126;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i81;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i47;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i65;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i198;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i221;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i179;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i189;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i196;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i197;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i164;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i168;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i173;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i235;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i28;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i91;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i135;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i136;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i134;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i155;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i43;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i161;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i160;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i216;
import 'package:trackflow/features/playlist/presentation/cubit/playlist_cubit.dart'
    as _i236;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i215;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i237;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i163;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i94;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i162;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i185;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i232;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i192;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i169;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i172;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i239;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i61;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i62;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i166;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i102;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i165;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i222;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i188;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i191;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i193;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i203;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i208;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i217;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i174;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i240;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i60;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i63;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i105;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i171;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i170;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i104;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i184;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i186;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i211;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i175;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i108;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i212;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i68;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i69;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i177;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i67;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i176;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i66;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i190;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i194;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i219;

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
    gh.lazySingleton<_i30.NotificationLocalDataSource>(
        () => _i30.IsarNotificationLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i31.NotificationRemoteDataSource>(() =>
        _i31.FirestoreNotificationRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i32.NotificationRepository>(
        () => _i33.NotificationRepositoryImpl(
              localDataSource: gh<_i30.NotificationLocalDataSource>(),
              remoteDataSource: gh<_i31.NotificationRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i34.NotificationService>(
        () => _i34.NotificationService(gh<_i32.NotificationRepository>()));
    gh.lazySingleton<_i35.ObserveNotificationsUseCase>(() =>
        _i35.ObserveNotificationsUseCase(gh<_i32.NotificationRepository>()));
    gh.factory<_i36.OperationExecutorFactory>(
        () => _i36.OperationExecutorFactory());
    gh.factory<_i37.PauseAudioUseCase>(() => _i37.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i38.PendingOperationsLocalDataSource>(
        () => _i38.IsarPendingOperationsLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i39.PendingOperationsRepository>(() =>
        _i39.PendingOperationsRepositoryImpl(
            gh<_i38.PendingOperationsLocalDataSource>()));
    gh.factory<_i40.PerformanceMetricsCollector>(
        () => _i40.PerformanceMetricsCollector());
    gh.lazySingleton<_i41.PlaybackPersistenceRepository>(
        () => _i42.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i43.PlaylistLocalDataSource>(
        () => _i43.PlaylistLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i44.PlaylistRemoteDataSource>(
        () => _i44.PlaylistRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
        () => _i7.ProjectConflictResolutionService());
    gh.lazySingleton<_i45.ProjectRemoteDataSource>(() =>
        _i45.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i46.ProjectsLocalDataSource>(
        () => _i46.ProjectsLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i47.ResendMagicLinkUseCase>(
        () => _i47.ResendMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i48.ResumeAudioUseCase>(() => _i48.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i49.SavePlaybackStateUseCase>(
        () => _i49.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i41.PlaybackPersistenceRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.factory<_i50.SeekAudioUseCase>(() =>
        _i50.SeekAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i51.SetPlaybackSpeedUseCase>(() => _i51.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i52.SetVolumeUseCase>(() =>
        _i52.SetVolumeUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    await gh.factoryAsync<_i53.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i54.SkipToNextUseCase>(() => _i54.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i55.SkipToPreviousUseCase>(() => _i55.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i56.StopAudioUseCase>(() =>
        _i56.StopAudioUseCase(playbackService: gh<_i5.AudioPlaybackService>()));
    gh.lazySingleton<_i57.SyncMetadataManager>(
        () => _i57.SyncMetadataManager());
    gh.factory<_i58.ToggleRepeatModeUseCase>(() => _i58.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.ToggleShuffleUseCase>(() => _i59.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.TrackDetailCubit>(() => _i60.TrackDetailCubit());
    gh.lazySingleton<_i61.TrackVersionLocalDataSource>(
        () => _i61.IsarTrackVersionLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i62.TrackVersionRemoteDataSource>(
        () => _i62.TrackVersionRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i63.UserProfileLocalDataSource>(
        () => _i63.IsarUserProfileLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i64.UserProfileRemoteDataSource>(
        () => _i64.UserProfileRemoteDataSourceImpl(
              gh<_i16.FirebaseFirestore>(),
              gh<_i17.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i65.ValidateMagicLinkUseCase>(
        () => _i65.ValidateMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i66.WaveformGeneratorService>(() =>
        _i67.JustWaveformGeneratorService(cacheDir: gh<_i12.Directory>()));
    gh.factory<_i68.WaveformLocalDataSource>(
        () => _i68.WaveformLocalDataSourceImpl(isar: gh<_i23.Isar>()));
    gh.lazySingleton<_i69.WaveformRemoteDataSource>(() =>
        _i69.FirebaseStorageWaveformRemoteDataSource(
            gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i70.AppleAuthService>(
        () => _i70.AppleAuthService(gh<_i15.FirebaseAuth>()));
    gh.lazySingleton<_i71.AudioCommentLocalDataSource>(
        () => _i71.IsarAudioCommentLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i72.AudioCommentRemoteDataSource>(() =>
        _i72.FirebaseAudioCommentRemoteDataSource(
            gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i73.AudioTrackLocalDataSource>(
        () => _i73.IsarAudioTrackLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i74.AudioTrackRemoteDataSource>(() =>
        _i74.AudioTrackRemoteDataSourceImpl(gh<_i16.FirebaseFirestore>()));
    gh.lazySingleton<_i75.CacheStorageLocalDataSource>(
        () => _i75.CacheStorageLocalDataSourceImpl(gh<_i23.Isar>()));
    gh.lazySingleton<_i76.CacheStorageRemoteDataSource>(() =>
        _i76.CacheStorageRemoteDataSourceImpl(gh<_i17.FirebaseStorage>()));
    gh.lazySingleton<_i77.ConsumeMagicLinkUseCase>(
        () => _i77.ConsumeMagicLinkUseCase(gh<_i26.MagicLinkRepository>()));
    gh.factory<_i78.CreateNotificationUseCase>(() =>
        _i78.CreateNotificationUseCase(gh<_i32.NotificationRepository>()));
    gh.factory<_i79.DatabaseHealthMonitor>(
        () => _i79.DatabaseHealthMonitor(gh<_i23.Isar>()));
    gh.factory<_i80.DeleteNotificationUseCase>(() =>
        _i80.DeleteNotificationUseCase(gh<_i32.NotificationRepository>()));
    gh.lazySingleton<_i81.GetMagicLinkStatusUseCase>(
        () => _i81.GetMagicLinkStatusUseCase(gh<_i26.MagicLinkRepository>()));
    gh.lazySingleton<_i82.GetUnreadNotificationsCountUseCase>(() =>
        _i82.GetUnreadNotificationsCountUseCase(
            gh<_i32.NotificationRepository>()));
    gh.lazySingleton<_i83.GoogleAuthService>(() => _i83.GoogleAuthService(
          gh<_i18.GoogleSignIn>(),
          gh<_i15.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i84.InvitationLocalDataSource>(
        () => _i84.IsarInvitationLocalDataSource(gh<_i23.Isar>()));
    gh.lazySingleton<_i85.InvitationRepository>(
        () => _i86.InvitationRepositoryImpl(
              localDataSource: gh<_i84.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i22.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
            ));
    gh.factory<_i87.MarkAsUnreadUseCase>(
        () => _i87.MarkAsUnreadUseCase(gh<_i32.NotificationRepository>()));
    gh.lazySingleton<_i88.MarkNotificationAsReadUseCase>(() =>
        _i88.MarkNotificationAsReadUseCase(gh<_i32.NotificationRepository>()));
    gh.lazySingleton<_i89.ObservePendingInvitationsUseCase>(() =>
        _i89.ObservePendingInvitationsUseCase(gh<_i85.InvitationRepository>()));
    gh.lazySingleton<_i90.ObserveSentInvitationsUseCase>(() =>
        _i90.ObserveSentInvitationsUseCase(gh<_i85.InvitationRepository>()));
    gh.lazySingleton<_i91.OnboardingStateLocalDataSource>(() =>
        _i91.OnboardingStateLocalDataSourceImpl(gh<_i53.SharedPreferences>()));
    gh.lazySingleton<_i92.PendingOperationsManager>(
        () => _i92.PendingOperationsManager(
              gh<_i39.PendingOperationsRepository>(),
              gh<_i29.NetworkStateManager>(),
              gh<_i36.OperationExecutorFactory>(),
            ));
    gh.factory<_i93.PlaylistOperationExecutor>(() =>
        _i93.PlaylistOperationExecutor(gh<_i44.PlaylistRemoteDataSource>()));
    gh.lazySingleton<_i94.ProjectIncrementalSyncService>(
        () => _i94.ProjectIncrementalSyncService(
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i95.ProjectOperationExecutor>(() =>
        _i95.ProjectOperationExecutor(gh<_i45.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i96.SessionStorage>(
        () => _i96.SessionStorageImpl(prefs: gh<_i53.SharedPreferences>()));
    gh.lazySingleton<_i97.SyncAudioCommentsUseCase>(
        () => _i97.SyncAudioCommentsUseCase(
              gh<_i72.AudioCommentRemoteDataSource>(),
              gh<_i71.AudioCommentLocalDataSource>(),
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i96.SessionStorage>(),
              gh<_i74.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i98.SyncNotificationsUseCase>(
        () => _i98.SyncNotificationsUseCase(
              gh<_i32.NotificationRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i99.SyncProjectsUsingSimpleServiceUseCase>(
        () => _i99.SyncProjectsUsingSimpleServiceUseCase(
              gh<_i94.ProjectIncrementalSyncService>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i100.SyncUserProfileUseCase>(
        () => _i100.SyncUserProfileUseCase(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i101.SyncWaveformsUseCase>(
        () => _i101.SyncWaveformsUseCase(
              gh<_i96.SessionStorage>(),
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i74.AudioTrackRemoteDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i68.WaveformLocalDataSource>(),
              gh<_i69.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i102.TrackVersionIncrementalSyncService>(
        () => _i102.TrackVersionIncrementalSyncService(
              gh<_i62.TrackVersionRemoteDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i74.AudioTrackRemoteDataSource>(),
            ));
    gh.factory<_i103.TrackVersionOperationExecutor>(
        () => _i103.TrackVersionOperationExecutor(
              gh<_i62.TrackVersionRemoteDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i104.UserProfileCacheRepository>(
        () => _i105.UserProfileCacheRepositoryImpl(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i29.NetworkStateManager>(),
            ));
    gh.factory<_i106.UserProfileOperationExecutor>(() =>
        _i106.UserProfileOperationExecutor(
            gh<_i64.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i107.WatchTrackUploadStatusUseCase>(() =>
        _i107.WatchTrackUploadStatusUseCase(
            gh<_i92.PendingOperationsManager>()));
    gh.lazySingleton<_i108.WatchUserProfilesUseCase>(() =>
        _i108.WatchUserProfilesUseCase(gh<_i104.UserProfileCacheRepository>()));
    gh.factory<_i109.WaveformOperationExecutor>(() =>
        _i109.WaveformOperationExecutor(gh<_i69.WaveformRemoteDataSource>()));
    gh.factory<_i110.AudioCommentOperationExecutor>(() =>
        _i110.AudioCommentOperationExecutor(
            gh<_i72.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i111.AudioDownloadRepository>(
        () => _i112.AudioDownloadRepositoryImpl(
              remoteDataSource: gh<_i76.CacheStorageRemoteDataSource>(),
              localDataSource: gh<_i75.CacheStorageLocalDataSource>(),
            ));
    gh.lazySingleton<_i113.AudioStorageRepository>(() =>
        _i114.AudioStorageRepositoryImpl(
            localDataSource: gh<_i75.CacheStorageLocalDataSource>()));
    gh.lazySingleton<_i115.AudioTrackIncrementalSyncService>(
        () => _i115.AudioTrackIncrementalSyncService(
              gh<_i74.AudioTrackRemoteDataSource>(),
              gh<_i73.AudioTrackLocalDataSource>(),
              gh<_i45.ProjectRemoteDataSource>(),
            ));
    gh.factory<_i116.AudioTrackOperationExecutor>(
        () => _i116.AudioTrackOperationExecutor(
              gh<_i74.AudioTrackRemoteDataSource>(),
              gh<_i73.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i117.AuthRemoteDataSource>(
        () => _i117.AuthRemoteDataSourceImpl(
              gh<_i15.FirebaseAuth>(),
              gh<_i83.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i118.AuthRepository>(() => _i119.AuthRepositoryImpl(
          remote: gh<_i117.AuthRemoteDataSource>(),
          sessionStorage: gh<_i96.SessionStorage>(),
          networkStateManager: gh<_i29.NetworkStateManager>(),
          googleAuthService: gh<_i83.GoogleAuthService>(),
          appleAuthService: gh<_i70.AppleAuthService>(),
        ));
    gh.lazySingleton<_i120.CacheManagementLocalDataSource>(() =>
        _i120.CacheManagementLocalDataSourceImpl(
            local: gh<_i75.CacheStorageLocalDataSource>()));
    gh.factory<_i121.CacheTrackUseCase>(() => _i121.CacheTrackUseCase(
          gh<_i111.AudioDownloadRepository>(),
          gh<_i113.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i122.CancelInvitationUseCase>(
        () => _i122.CancelInvitationUseCase(gh<_i85.InvitationRepository>()));
    gh.factory<_i123.CheckAuthenticationStatusUseCase>(() =>
        _i123.CheckAuthenticationStatusUseCase(gh<_i118.AuthRepository>()));
    gh.factory<_i124.CurrentUserService>(
        () => _i124.CurrentUserService(gh<_i96.SessionStorage>()));
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
            gh<_i85.InvitationRepository>()));
    gh.factory<_i131.MarkAllNotificationsAsReadUseCase>(
        () => _i131.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i32.NotificationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i132.NotificationActorBloc>(() => _i132.NotificationActorBloc(
          createNotificationUseCase: gh<_i78.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i88.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i87.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i131.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i80.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i133.NotificationWatcherBloc>(
        () => _i133.NotificationWatcherBloc(
              notificationRepository: gh<_i32.NotificationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.lazySingleton<_i134.OnboardingRepository>(() =>
        _i135.OnboardingRepositoryImpl(
            gh<_i91.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i136.OnboardingUseCase>(
        () => _i136.OnboardingUseCase(gh<_i134.OnboardingRepository>()));
    gh.factory<_i137.ProjectInvitationWatcherBloc>(
        () => _i137.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i85.InvitationRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i138.RemoveTrackCacheUseCase>(() =>
        _i138.RemoveTrackCacheUseCase(gh<_i113.AudioStorageRepository>()));
    gh.lazySingleton<_i139.SignOutUseCase>(
        () => _i139.SignOutUseCase(gh<_i118.AuthRepository>()));
    gh.lazySingleton<_i140.SignUpUseCase>(
        () => _i140.SignUpUseCase(gh<_i118.AuthRepository>()));
    gh.lazySingleton<_i141.SyncAudioTracksUsingSimpleServiceUseCase>(
        () => _i141.SyncAudioTracksUsingSimpleServiceUseCase(
              gh<_i115.AudioTrackIncrementalSyncService>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i142.SyncTrackVersionsUseCase>(
        () => _i142.SyncTrackVersionsUseCase(
              gh<_i102.TrackVersionIncrementalSyncService>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i143.SyncUserProfileCollaboratorsUseCase>(
        () => _i143.SyncUserProfileCollaboratorsUseCase(
              gh<_i46.ProjectsLocalDataSource>(),
              gh<_i104.UserProfileCacheRepository>(),
            ));
    gh.factory<_i144.TrackUploadStatusCubit>(() => _i144.TrackUploadStatusCubit(
        gh<_i107.WatchTrackUploadStatusUseCase>()));
    gh.factory<_i145.WatchCachedAudiosUseCase>(() =>
        _i145.WatchCachedAudiosUseCase(gh<_i113.AudioStorageRepository>()));
    gh.factory<_i146.WatchStorageUsageUseCase>(() =>
        _i146.WatchStorageUsageUseCase(gh<_i113.AudioStorageRepository>()));
    gh.factory<_i147.WatchTrackCacheStatusUseCase>(() =>
        _i147.WatchTrackCacheStatusUseCase(gh<_i113.AudioStorageRepository>()));
    gh.lazySingleton<_i148.AppleSignInUseCase>(
        () => _i148.AppleSignInUseCase(gh<_i118.AuthRepository>()));
    gh.factory<_i149.AudioSourceResolver>(() => _i150.AudioSourceResolverImpl(
          gh<_i113.AudioStorageRepository>(),
          gh<_i111.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i151.CacheMaintenanceService>(() =>
        _i152.CacheMaintenanceServiceImpl(
            gh<_i120.CacheManagementLocalDataSource>()));
    gh.factory<_i153.CleanupCacheUseCase>(
        () => _i153.CleanupCacheUseCase(gh<_i151.CacheMaintenanceService>()));
    gh.factory<_i154.GetCacheStorageStatsUseCase>(() =>
        _i154.GetCacheStorageStatsUseCase(gh<_i151.CacheMaintenanceService>()));
    gh.factory<_i155.OnboardingBloc>(() => _i155.OnboardingBloc(
          onboardingUseCase: gh<_i136.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i156.SyncDataManager>(() => _i156.SyncDataManager(
          syncProjects: gh<_i99.SyncProjectsUsingSimpleServiceUseCase>(),
          syncAudioTracks: gh<_i141.SyncAudioTracksUsingSimpleServiceUseCase>(),
          syncAudioComments: gh<_i97.SyncAudioCommentsUseCase>(),
          syncUserProfile: gh<_i100.SyncUserProfileUseCase>(),
          syncUserProfileCollaborators:
              gh<_i143.SyncUserProfileCollaboratorsUseCase>(),
          syncNotifications: gh<_i98.SyncNotificationsUseCase>(),
          syncTrackVersions: gh<_i142.SyncTrackVersionsUseCase>(),
          syncWaveforms: gh<_i101.SyncWaveformsUseCase>(),
        ));
    gh.factory<_i157.SyncStatusProvider>(() => _i157.SyncStatusProvider(
          syncDataManager: gh<_i156.SyncDataManager>(),
          pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
        ));
    gh.factory<_i158.TrackCacheBloc>(() => _i158.TrackCacheBloc(
          cacheTrackUseCase: gh<_i121.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i147.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i138.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i128.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i159.BackgroundSyncCoordinator>(
        () => _i159.BackgroundSyncCoordinator(
              gh<_i29.NetworkStateManager>(),
              gh<_i156.SyncDataManager>(),
              gh<_i92.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i160.PlaylistRepository>(
        () => _i161.PlaylistRepositoryImpl(
              localDataSource: gh<_i43.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i162.ProjectsRepository>(
        () => _i163.ProjectsRepositoryImpl(
              localDataSource: gh<_i46.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i164.RemoveCollaboratorUseCase>(
        () => _i164.RemoveCollaboratorUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i165.TrackVersionRepository>(
        () => _i166.TrackVersionRepositoryImpl(
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i159.BackgroundSyncCoordinator>(),
              gh<_i92.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i167.TriggerUpstreamSyncUseCase>(() =>
        _i167.TriggerUpstreamSyncUseCase(
            gh<_i159.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i168.UpdateCollaboratorRoleUseCase>(
        () => _i168.UpdateCollaboratorRoleUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i169.UpdateProjectUseCase>(
        () => _i169.UpdateProjectUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i170.UserProfileRepository>(
        () => _i171.UserProfileRepositoryImpl(
              localDataSource: gh<_i63.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i64.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
              firestore: gh<_i16.FirebaseFirestore>(),
              sessionStorage: gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i172.WatchAllProjectsUseCase>(
        () => _i172.WatchAllProjectsUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i173.WatchCollaboratorsBundleUseCase>(
        () => _i173.WatchCollaboratorsBundleUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i108.WatchUserProfilesUseCase>(),
            ));
    gh.lazySingleton<_i174.WatchTrackVersionsUseCase>(() =>
        _i174.WatchTrackVersionsUseCase(gh<_i165.TrackVersionRepository>()));
    gh.lazySingleton<_i175.WatchUserProfileUseCase>(
        () => _i175.WatchUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.factory<_i176.WaveformRepository>(() => _i177.WaveformRepositoryImpl(
          localDataSource: gh<_i68.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i69.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i178.AcceptInvitationUseCase>(
        () => _i178.AcceptInvitationUseCase(
              invitationRepository: gh<_i85.InvitationRepository>(),
              projectRepository: gh<_i162.ProjectsRepository>(),
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              notificationService: gh<_i34.NotificationService>(),
            ));
    gh.lazySingleton<_i179.AddCollaboratorToProjectUseCase>(
        () => _i179.AddCollaboratorToProjectUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i180.AudioCommentRepository>(
        () => _i181.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i72.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i71.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i29.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i92.PendingOperationsManager>(),
              trackVersionRepository: gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i182.AudioTrackRepository>(
        () => _i183.AudioTrackRepositoryImpl(
              gh<_i73.AudioTrackLocalDataSource>(),
              gh<_i159.BackgroundSyncCoordinator>(),
              gh<_i92.PendingOperationsManager>(),
            ));
    gh.factory<_i184.CheckProfileCompletenessUseCase>(() =>
        _i184.CheckProfileCompletenessUseCase(
            gh<_i170.UserProfileRepository>()));
    gh.lazySingleton<_i185.CreateProjectUseCase>(
        () => _i185.CreateProjectUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.factory<_i186.CreateUserProfileUseCase>(
        () => _i186.CreateUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i187.DeclineInvitationUseCase>(
        () => _i187.DeclineInvitationUseCase(
              invitationRepository: gh<_i85.InvitationRepository>(),
              projectRepository: gh<_i162.ProjectsRepository>(),
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              notificationService: gh<_i34.NotificationService>(),
            ));
    gh.lazySingleton<_i188.DeleteTrackVersionUseCase>(
        () => _i188.DeleteTrackVersionUseCase(
              gh<_i165.TrackVersionRepository>(),
              gh<_i176.WaveformRepository>(),
              gh<_i180.AudioCommentRepository>(),
              gh<_i113.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i189.FindUserByEmailUseCase>(
        () => _i189.FindUserByEmailUseCase(gh<_i170.UserProfileRepository>()));
    gh.factory<_i190.GenerateAndStoreWaveform>(
        () => _i190.GenerateAndStoreWaveform(
              gh<_i176.WaveformRepository>(),
              gh<_i66.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i191.GetActiveVersionUseCase>(() =>
        _i191.GetActiveVersionUseCase(gh<_i165.TrackVersionRepository>()));
    gh.lazySingleton<_i192.GetProjectByIdUseCase>(
        () => _i192.GetProjectByIdUseCase(gh<_i162.ProjectsRepository>()));
    gh.lazySingleton<_i193.GetVersionByIdUseCase>(
        () => _i193.GetVersionByIdUseCase(gh<_i165.TrackVersionRepository>()));
    gh.factory<_i194.GetWaveformByVersion>(
        () => _i194.GetWaveformByVersion(gh<_i176.WaveformRepository>()));
    gh.lazySingleton<_i195.GoogleSignInUseCase>(() => _i195.GoogleSignInUseCase(
          gh<_i118.AuthRepository>(),
          gh<_i170.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i196.JoinProjectWithIdUseCase>(
        () => _i196.JoinProjectWithIdUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i197.LeaveProjectUseCase>(() => _i197.LeaveProjectUseCase(
          gh<_i162.ProjectsRepository>(),
          gh<_i96.SessionStorage>(),
        ));
    gh.factory<_i198.MagicLinkBloc>(() => _i198.MagicLinkBloc(
          generateMagicLink: gh<_i126.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i65.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i77.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i47.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i81.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i196.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i118.AuthRepository>(),
        ));
    gh.factory<_i199.PlayPlaylistUseCase>(() => _i199.PlayPlaylistUseCase(
          playlistRepository: gh<_i160.PlaylistRepository>(),
          audioTrackRepository: gh<_i182.AudioTrackRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i113.AudioStorageRepository>(),
        ));
    gh.factory<_i200.PlayVersionUseCase>(() => _i200.PlayVersionUseCase(
          audioTrackRepository: gh<_i182.AudioTrackRepository>(),
          audioStorageRepository: gh<_i113.AudioStorageRepository>(),
          trackVersionRepository: gh<_i165.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i201.ProjectCommentService>(
        () => _i201.ProjectCommentService(gh<_i180.AudioCommentRepository>()));
    gh.lazySingleton<_i202.ProjectTrackService>(
        () => _i202.ProjectTrackService(gh<_i182.AudioTrackRepository>()));
    gh.lazySingleton<_i203.RenameTrackVersionUseCase>(() =>
        _i203.RenameTrackVersionUseCase(gh<_i165.TrackVersionRepository>()));
    gh.factory<_i204.RestorePlaybackStateUseCase>(
        () => _i204.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i41.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i182.AudioTrackRepository>(),
              audioStorageRepository: gh<_i113.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i205.SendInvitationUseCase>(
        () => _i205.SendInvitationUseCase(
              invitationRepository: gh<_i85.InvitationRepository>(),
              notificationService: gh<_i34.NotificationService>(),
              findUserByEmail: gh<_i189.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i26.MagicLinkRepository>(),
              currentUserService: gh<_i124.CurrentUserService>(),
            ));
    gh.factory<_i206.SessionCleanupService>(() => _i206.SessionCleanupService(
          userProfileRepository: gh<_i170.UserProfileRepository>(),
          projectsRepository: gh<_i162.ProjectsRepository>(),
          audioTrackRepository: gh<_i182.AudioTrackRepository>(),
          audioCommentRepository: gh<_i180.AudioCommentRepository>(),
          invitationRepository: gh<_i85.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i41.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i9.BlocStateCleanupService>(),
          sessionStorage: gh<_i96.SessionStorage>(),
          pendingOperationsRepository: gh<_i39.PendingOperationsRepository>(),
          waveformRepository: gh<_i176.WaveformRepository>(),
          trackVersionRepository: gh<_i165.TrackVersionRepository>(),
        ));
    gh.factory<_i207.SessionService>(() => _i207.SessionService(
          checkAuthUseCase: gh<_i123.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i136.OnboardingUseCase>(),
          profileUseCase: gh<_i184.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i208.SetActiveTrackVersionUseCase>(() =>
        _i208.SetActiveTrackVersionUseCase(gh<_i182.AudioTrackRepository>()));
    gh.lazySingleton<_i209.SignInUseCase>(() => _i209.SignInUseCase(
          gh<_i118.AuthRepository>(),
          gh<_i170.UserProfileRepository>(),
        ));
    gh.factory<_i210.SyncStatusCubit>(() => _i210.SyncStatusCubit(
          gh<_i157.SyncStatusProvider>(),
          gh<_i92.PendingOperationsManager>(),
          gh<_i167.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i211.UpdateUserProfileUseCase>(
        () => _i211.UpdateUserProfileUseCase(
              gh<_i170.UserProfileRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.factory<_i212.UserProfileBloc>(() => _i212.UserProfileBloc(
          updateUserProfileUseCase: gh<_i211.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i186.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i175.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i184.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i129.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i213.WatchAudioCommentsBundleUseCase>(
        () => _i213.WatchAudioCommentsBundleUseCase(
              gh<_i182.AudioTrackRepository>(),
              gh<_i180.AudioCommentRepository>(),
              gh<_i104.UserProfileCacheRepository>(),
            ));
    gh.factory<_i214.WatchCachedTrackBundlesUseCase>(
        () => _i214.WatchCachedTrackBundlesUseCase(
              gh<_i151.CacheMaintenanceService>(),
              gh<_i182.AudioTrackRepository>(),
              gh<_i170.UserProfileRepository>(),
              gh<_i162.ProjectsRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i215.WatchProjectDetailUseCase>(
        () => _i215.WatchProjectDetailUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i182.AudioTrackRepository>(),
              gh<_i104.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i216.WatchProjectPlaylistUseCase>(
        () => _i216.WatchProjectPlaylistUseCase(
              gh<_i182.AudioTrackRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i217.WatchTrackVersionsBundleUseCase>(
        () => _i217.WatchTrackVersionsBundleUseCase(
              gh<_i182.AudioTrackRepository>(),
              gh<_i165.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i218.WatchTracksByProjectIdUseCase>(() =>
        _i218.WatchTracksByProjectIdUseCase(gh<_i182.AudioTrackRepository>()));
    gh.factory<_i219.WaveformBloc>(() => _i219.WaveformBloc(
          waveformRepository: gh<_i176.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i220.AddAudioCommentUseCase>(
        () => _i220.AddAudioCommentUseCase(
              gh<_i201.ProjectCommentService>(),
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i221.AddCollaboratorByEmailUseCase>(
        () => _i221.AddCollaboratorByEmailUseCase(
              gh<_i189.FindUserByEmailUseCase>(),
              gh<_i179.AddCollaboratorToProjectUseCase>(),
              gh<_i34.NotificationService>(),
            ));
    gh.lazySingleton<_i222.AddTrackVersionUseCase>(
        () => _i222.AddTrackVersionUseCase(
              gh<_i96.SessionStorage>(),
              gh<_i165.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i113.AudioStorageRepository>(),
              gh<_i190.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i223.AppBootstrap>(() => _i223.AppBootstrap(
          sessionService: gh<_i207.SessionService>(),
          performanceCollector: gh<_i40.PerformanceMetricsCollector>(),
          dynamicLinkService: gh<_i13.DynamicLinkService>(),
          databaseHealthMonitor: gh<_i79.DatabaseHealthMonitor>(),
        ));
    gh.factory<_i224.AppFlowBloc>(() => _i224.AppFlowBloc(
          appBootstrap: gh<_i223.AppBootstrap>(),
          backgroundSyncCoordinator: gh<_i159.BackgroundSyncCoordinator>(),
          getAuthStateUseCase: gh<_i127.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i206.SessionCleanupService>(),
        ));
    gh.lazySingleton<_i225.AudioContextService>(
        () => _i226.AudioContextServiceImpl(
              userProfileRepository: gh<_i170.UserProfileRepository>(),
              audioTrackRepository: gh<_i182.AudioTrackRepository>(),
              projectsRepository: gh<_i162.ProjectsRepository>(),
            ));
    gh.factory<_i227.AudioPlayerService>(() => _i227.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i20.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i200.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i199.PlayPlaylistUseCase>(),
          audioTrackRepository: gh<_i182.AudioTrackRepository>(),
          pauseAudioUseCase: gh<_i37.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i48.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i56.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i54.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i55.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i50.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i59.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i58.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i52.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i51.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i49.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i204.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i228.AuthBloc>(() => _i228.AuthBloc(
          signIn: gh<_i209.SignInUseCase>(),
          signUp: gh<_i140.SignUpUseCase>(),
          googleSignIn: gh<_i195.GoogleSignInUseCase>(),
          appleSignIn: gh<_i148.AppleSignInUseCase>(),
          signOut: gh<_i139.SignOutUseCase>(),
        ));
    gh.factory<_i229.CacheManagementBloc>(() => _i229.CacheManagementBloc(
          deleteOne: gh<_i125.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i146.WatchStorageUsageUseCase>(),
          getStats: gh<_i154.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i153.CleanupCacheUseCase>(),
          watchBundles: gh<_i214.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i230.DeleteAudioCommentUseCase>(
        () => _i230.DeleteAudioCommentUseCase(
              gh<_i201.ProjectCommentService>(),
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
            ));
    gh.lazySingleton<_i231.DeleteAudioTrack>(() => _i231.DeleteAudioTrack(
          gh<_i96.SessionStorage>(),
          gh<_i162.ProjectsRepository>(),
          gh<_i202.ProjectTrackService>(),
          gh<_i165.TrackVersionRepository>(),
          gh<_i176.WaveformRepository>(),
          gh<_i113.AudioStorageRepository>(),
          gh<_i180.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i232.DeleteProjectUseCase>(
        () => _i232.DeleteProjectUseCase(
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
              gh<_i202.ProjectTrackService>(),
            ));
    gh.lazySingleton<_i233.EditAudioTrackUseCase>(
        () => _i233.EditAudioTrackUseCase(
              gh<_i202.ProjectTrackService>(),
              gh<_i162.ProjectsRepository>(),
            ));
    gh.factory<_i234.LoadTrackContextUseCase>(
        () => _i234.LoadTrackContextUseCase(gh<_i225.AudioContextService>()));
    gh.factory<_i235.ManageCollaboratorsBloc>(
        () => _i235.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i164.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i168.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i197.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i221.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i173.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i236.PlaylistCubit>(() => _i236.PlaylistCubit(
          gh<_i218.WatchTracksByProjectIdUseCase>(),
          gh<_i216.WatchProjectPlaylistUseCase>(),
        ));
    gh.factory<_i237.ProjectDetailBloc>(() => _i237.ProjectDetailBloc(
        watchProjectDetail: gh<_i215.WatchProjectDetailUseCase>()));
    gh.factory<_i238.ProjectInvitationActorBloc>(
        () => _i238.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i205.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i178.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i187.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i122.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i189.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i239.ProjectsBloc>(() => _i239.ProjectsBloc(
          createProject: gh<_i185.CreateProjectUseCase>(),
          updateProject: gh<_i169.UpdateProjectUseCase>(),
          deleteProject: gh<_i232.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i172.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i240.TrackVersionsBloc>(() => _i240.TrackVersionsBloc(
          gh<_i217.WatchTrackVersionsBundleUseCase>(),
          gh<_i208.SetActiveTrackVersionUseCase>(),
          gh<_i222.AddTrackVersionUseCase>(),
          gh<_i203.RenameTrackVersionUseCase>(),
          gh<_i188.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i241.UploadAudioTrackUseCase>(
        () => _i241.UploadAudioTrackUseCase(
              gh<_i202.ProjectTrackService>(),
              gh<_i162.ProjectsRepository>(),
              gh<_i96.SessionStorage>(),
              gh<_i222.AddTrackVersionUseCase>(),
              gh<_i182.AudioTrackRepository>(),
            ));
    gh.factory<_i242.AudioCommentBloc>(() => _i242.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i220.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i230.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i213.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i243.AudioContextBloc>(() => _i243.AudioContextBloc(
        loadTrackContextUseCase: gh<_i234.LoadTrackContextUseCase>()));
    gh.factory<_i244.AudioPlayerBloc>(() => _i244.AudioPlayerBloc(
        audioPlayerService: gh<_i227.AudioPlayerService>()));
    gh.factory<_i245.AudioTrackBloc>(() => _i245.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i218.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i231.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i241.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i233.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i246.AppModule {}
