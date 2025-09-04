// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i15;

import 'package:cloud_firestore/cloud_firestore.dart' as _i19;
import 'package:connectivity_plus/connectivity_plus.dart' as _i13;
import 'package:firebase_auth/firebase_auth.dart' as _i18;
import 'package:firebase_storage/firebase_storage.dart' as _i20;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i22;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i25;
import 'package:isar/isar.dart' as _i27;
import 'package:shared_preferences/shared_preferences.dart' as _i57;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i101;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i17;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i214;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i9;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i201;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i202;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i127;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i132;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i134;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i215;
import 'package:trackflow/core/di/app_module.dart' as _i234;
import 'package:trackflow/core/media/avatar_cache_manager.dart' as _i8;
import 'package:trackflow/core/network/network_state_manager.dart' as _i33;
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart'
    as _i34;
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart'
    as _i35;
import 'package:trackflow/core/notifications/data/repositories/notification_repository_impl.dart'
    as _i37;
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart'
    as _i36;
import 'package:trackflow/core/notifications/domain/services/notification_service.dart'
    as _i38;
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i83;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i86;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i137;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i92;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i93;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i39;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i138;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i139;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i82;
import 'package:trackflow/core/services/deep_link_service.dart' as _i14;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i16;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i23;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i44;
import 'package:trackflow/core/session/current_user_service.dart' as _i128;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i42;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i43;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i117;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i98;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i100;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i108;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i162;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i97;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i159;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i61;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i160;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i102;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i148;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i103;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i104;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i149;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i105;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i168;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i204;
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i129;
// import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_multiple_cached_audios_usecase.dart'
//     as _i130;
import 'package:trackflow/features/audio_cache/management/domain/usecases/get_cached_track_bundles_usecase.dart'
    as _i188;
import 'package:trackflow/features/audio_cache/management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i209;
import 'package:trackflow/features/audio_cache/management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i152;
import 'package:trackflow/features/audio_cache/management/presentation/bloc/cache_management_bloc.dart'
    as _i220;
// Playlist cache feature removed
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i78;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i79;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i115;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i124;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i11;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i114;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i123;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i10;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i12;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/watch_cached_audios_usecase.dart'
    as _i151;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i125;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i133;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i145;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i153;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i161;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i179;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i178;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i197;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i212;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i221;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i208;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i230;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i216;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i225;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i217;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i231;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i218;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i156;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i24;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i194;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i195;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i52;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i53;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i54;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i55;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i56;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i58;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i59;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i60;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i62;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i63;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i46;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i6;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i157;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i232;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i76;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i77;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i181;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i116;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i180;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i198;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i222;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i224;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i206;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i211;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i109;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i233;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i150;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i118;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i120;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i73;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i87;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i119;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i155;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i190;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i203;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i146;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i147;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i219;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i89;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i26;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i91;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i90;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i176;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i126;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i186;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i135;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i94;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i95;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i200;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i228;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i143;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i28;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i29;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i31;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i30;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i80;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i131;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i84;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i51;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i193;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i213;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i177;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i187;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i191;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i192;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i167;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i174;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i226;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i32;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i96;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i141;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i142;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i140;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i158;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i47;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i48;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i164;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i163;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i210;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i227;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i50;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i49;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i166;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i99;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i165;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i184;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i223;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i189;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i170;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i173;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i229;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i107;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i172;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i171;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i106;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i183;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i185;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i205;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i175;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i110;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i207;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i69;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i70;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i72;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i68;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i71;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i67;
import 'package:trackflow/features/waveform/domain/usecases/get_or_generate_waveform.dart'
    as _i85;
import 'package:trackflow/features/waveform/domain/usecases/invalidate_waveform.dart'
    as _i88;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i154;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i3.AudioBackgroundInitializer>(
      () => const _i3.AudioBackgroundInitializer(),
    );
    gh.lazySingleton<_i4.AudioMetadataService>(
      () => const _i4.AudioMetadataService(),
    );
    gh.lazySingleton<_i5.AudioPlaybackService>(
      () => _i6.AudioPlaybackServiceImpl(),
    );
    gh.lazySingleton<_i7.AudioTrackConflictResolutionService>(
      () => _i7.AudioTrackConflictResolutionService(),
    );
    gh.lazySingleton<_i8.AvatarCacheManager>(
      () => _i8.AvatarCacheManagerImpl(),
    );
    gh.singleton<_i9.BlocStateCleanupService>(
      () => _i9.BlocStateCleanupService(),
    );
    gh.lazySingleton<_i10.CacheMaintenanceService>(
      () => _i11.CacheMaintenanceServiceImpl(),
    );
    gh.factory<_i12.CleanupCacheUseCase>(
      () => _i12.CleanupCacheUseCase(gh<_i10.CacheMaintenanceService>()),
    );
    gh.lazySingleton<_i7.ConflictResolutionServiceImpl<dynamic>>(
      () => _i7.ConflictResolutionServiceImpl<dynamic>(),
    );
    gh.lazySingleton<_i13.Connectivity>(() => appModule.connectivity);
    gh.singleton<_i14.DeepLinkService>(() => _i14.DeepLinkService());
    await gh.factoryAsync<_i15.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i16.DynamicLinkService>(() => _i16.DynamicLinkService());
    gh.factory<_i17.ExampleComplexBloc>(() => _i17.ExampleComplexBloc());
    gh.factory<_i17.ExampleConditionalBloc>(
      () => _i17.ExampleConditionalBloc(),
    );
    gh.factory<_i17.ExampleNavigationCubit>(
      () => _i17.ExampleNavigationCubit(),
    );
    gh.factory<_i17.ExampleSimpleBloc>(() => _i17.ExampleSimpleBloc());
    gh.factory<_i17.ExampleUserProfileBloc>(
      () => _i17.ExampleUserProfileBloc(),
    );
    gh.lazySingleton<_i18.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i19.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i20.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.factory<_i21.GetCacheStorageStatsUseCase>(
      () =>
          _i21.GetCacheStorageStatsUseCase(gh<_i10.CacheMaintenanceService>()),
    );
    gh.lazySingleton<_i22.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i23.ImageMaintenanceService>(
      () => _i23.ImageMaintenanceService(),
    );
    gh.factory<_i24.InitializeAudioPlayerUseCase>(
      () => _i24.InitializeAudioPlayerUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i25.InternetConnectionChecker>(
      () => appModule.internetConnectionChecker,
    );
    gh.lazySingleton<_i26.InvitationRemoteDataSource>(
      () => _i26.FirestoreInvitationRemoteDataSource(
        gh<_i19.FirebaseFirestore>(),
      ),
    );
    await gh.factoryAsync<_i27.Isar>(() => appModule.isar, preResolve: true);
    gh.lazySingleton<_i28.MagicLinkLocalDataSource>(
      () => _i28.MagicLinkLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i29.MagicLinkRemoteDataSource>(
      () => _i29.MagicLinkRemoteDataSourceImpl(
        firestore: gh<_i19.FirebaseFirestore>(),
        deepLinkService: gh<_i14.DeepLinkService>(),
      ),
    );
    gh.factory<_i30.MagicLinkRepository>(
      () => _i31.MagicLinkRepositoryImp(gh<_i29.MagicLinkRemoteDataSource>()),
    );
    gh.factory<_i32.NavigationCubit>(() => _i32.NavigationCubit());
    gh.lazySingleton<_i33.NetworkStateManager>(
      () => _i33.NetworkStateManager(
        gh<_i25.InternetConnectionChecker>(),
        gh<_i13.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i34.NotificationLocalDataSource>(
      () => _i34.IsarNotificationLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i35.NotificationRemoteDataSource>(
      () => _i35.FirestoreNotificationRemoteDataSource(
        gh<_i19.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i36.NotificationRepository>(
      () => _i37.NotificationRepositoryImpl(
        localDataSource: gh<_i34.NotificationLocalDataSource>(),
        remoteDataSource: gh<_i35.NotificationRemoteDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
      ),
    );
    gh.lazySingleton<_i38.NotificationService>(
      () => _i38.NotificationService(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i39.ObserveNotificationsUseCase>(
      () => _i39.ObserveNotificationsUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.factory<_i40.OperationExecutorFactory>(
      () => _i40.OperationExecutorFactory(),
    );
    gh.factory<_i41.PauseAudioUseCase>(
      () => _i41.PauseAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i42.PendingOperationsLocalDataSource>(
      () => _i42.IsarPendingOperationsLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i43.PendingOperationsRepository>(
      () => _i43.PendingOperationsRepositoryImpl(
        gh<_i42.PendingOperationsLocalDataSource>(),
      ),
    );
    gh.factory<_i44.PerformanceMetricsCollector>(
      () => _i44.PerformanceMetricsCollector(),
    );
    gh.lazySingleton<_i45.PlaybackPersistenceRepository>(
      () => _i46.PlaybackPersistenceRepositoryImpl(),
    );
    gh.lazySingleton<_i47.PlaylistLocalDataSource>(
      () => _i47.PlaylistLocalDataSourceImpl(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i48.PlaylistRemoteDataSource>(
      () => _i48.PlaylistRemoteDataSourceImpl(gh<_i19.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i7.ProjectConflictResolutionService>(
      () => _i7.ProjectConflictResolutionService(),
    );
    gh.lazySingleton<_i49.ProjectRemoteDataSource>(
      () => _i49.ProjectsRemoteDatasSourceImpl(
        firestore: gh<_i19.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i50.ProjectsLocalDataSource>(
      () => _i50.ProjectsLocalDataSourceImpl(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i51.ResendMagicLinkUseCase>(
      () => _i51.ResendMagicLinkUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.factory<_i52.ResumeAudioUseCase>(
      () => _i52.ResumeAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i53.SavePlaybackStateUseCase>(
      () => _i53.SavePlaybackStateUseCase(
        persistenceRepository: gh<_i45.PlaybackPersistenceRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i54.SeekAudioUseCase>(
      () => _i54.SeekAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i55.SetPlaybackSpeedUseCase>(
      () => _i55.SetPlaybackSpeedUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i56.SetVolumeUseCase>(
      () => _i56.SetVolumeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    await gh.factoryAsync<_i57.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i58.SkipToNextUseCase>(
      () => _i58.SkipToNextUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i59.SkipToPreviousUseCase>(
      () => _i59.SkipToPreviousUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i60.StopAudioUseCase>(
      () => _i60.StopAudioUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i61.SyncMetadataManager>(
      () => _i61.SyncMetadataManager(),
    );
    gh.factory<_i62.ToggleRepeatModeUseCase>(
      () => _i62.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i63.ToggleShuffleUseCase>(
      () => _i63.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i64.UserProfileLocalDataSource>(
      () => _i64.IsarUserProfileLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i65.UserProfileRemoteDataSource>(
      () => _i65.UserProfileRemoteDataSourceImpl(
        gh<_i19.FirebaseFirestore>(),
        gh<_i20.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i66.ValidateMagicLinkUseCase>(
      () => _i66.ValidateMagicLinkUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.factory<_i67.WaveformGeneratorService>(
      () => _i68.JustWaveformGeneratorService(cacheDir: gh<_i15.Directory>()),
    );
    gh.factory<_i69.WaveformLocalDataSource>(
      () => _i69.WaveformLocalDataSourceImpl(isar: gh<_i27.Isar>()),
    );
    gh.factory<_i70.WaveformRemoteDataSource>(
      () => _i70.FirebaseStorageWaveformRemoteDataSource(
        storage: gh<_i20.FirebaseStorage>(),
      ),
    );
    gh.factory<_i71.WaveformRepository>(
      () => _i72.WaveformRepositoryImpl(
        localDataSource: gh<_i69.WaveformLocalDataSource>(),
        remoteDataSource: gh<_i70.WaveformRemoteDataSource>(),
        generatorService: gh<_i67.WaveformGeneratorService>(),
      ),
    );
    gh.lazySingleton<_i73.AppleAuthService>(
      () => _i73.AppleAuthService(gh<_i18.FirebaseAuth>()),
    );
    gh.lazySingleton<_i74.AudioCommentLocalDataSource>(
      () => _i74.IsarAudioCommentLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i75.AudioCommentRemoteDataSource>(
      () => _i75.FirebaseAudioCommentRemoteDataSource(
        gh<_i19.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i76.AudioTrackLocalDataSource>(
      () => _i76.IsarAudioTrackLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i77.AudioTrackRemoteDataSource>(
      () => _i77.AudioTrackRemoteDataSourceImpl(
        gh<_i19.FirebaseFirestore>(),
        gh<_i20.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i78.CacheStorageLocalDataSource>(
      () => _i78.CacheStorageLocalDataSourceImpl(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i79.CacheStorageRemoteDataSource>(
      () => _i79.CacheStorageRemoteDataSourceImpl(gh<_i20.FirebaseStorage>()),
    );
    gh.lazySingleton<_i80.ConsumeMagicLinkUseCase>(
      () => _i80.ConsumeMagicLinkUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.factory<_i81.CreateNotificationUseCase>(
      () => _i81.CreateNotificationUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.factory<_i82.DatabaseHealthMonitor>(
      () => _i82.DatabaseHealthMonitor(gh<_i27.Isar>()),
    );
    gh.factory<_i83.DeleteNotificationUseCase>(
      () => _i83.DeleteNotificationUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i84.GetMagicLinkStatusUseCase>(
      () => _i84.GetMagicLinkStatusUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.factory<_i85.GetOrGenerateWaveform>(
      () => _i85.GetOrGenerateWaveform(gh<_i71.WaveformRepository>()),
    );
    gh.lazySingleton<_i86.GetUnreadNotificationsCountUseCase>(
      () => _i86.GetUnreadNotificationsCountUseCase(
        gh<_i36.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i87.GoogleAuthService>(
      () => _i87.GoogleAuthService(
        gh<_i22.GoogleSignIn>(),
        gh<_i18.FirebaseAuth>(),
      ),
    );
    gh.factory<_i88.InvalidateWaveform>(
      () => _i88.InvalidateWaveform(gh<_i71.WaveformRepository>()),
    );
    gh.lazySingleton<_i89.InvitationLocalDataSource>(
      () => _i89.IsarInvitationLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i90.InvitationRepository>(
      () => _i91.InvitationRepositoryImpl(
        localDataSource: gh<_i89.InvitationLocalDataSource>(),
        remoteDataSource: gh<_i26.InvitationRemoteDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
      ),
    );
    gh.factory<_i92.MarkAsUnreadUseCase>(
      () => _i92.MarkAsUnreadUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i93.MarkNotificationAsReadUseCase>(
      () =>
          _i93.MarkNotificationAsReadUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i94.ObservePendingInvitationsUseCase>(
      () => _i94.ObservePendingInvitationsUseCase(
        gh<_i90.InvitationRepository>(),
      ),
    );
    gh.lazySingleton<_i95.ObserveSentInvitationsUseCase>(
      () => _i95.ObserveSentInvitationsUseCase(gh<_i90.InvitationRepository>()),
    );
    gh.lazySingleton<_i96.OnboardingStateLocalDataSource>(
      () =>
          _i96.OnboardingStateLocalDataSourceImpl(gh<_i57.SharedPreferences>()),
    );
    gh.lazySingleton<_i97.PendingOperationsManager>(
      () => _i97.PendingOperationsManager(
        gh<_i43.PendingOperationsRepository>(),
        gh<_i33.NetworkStateManager>(),
        gh<_i40.OperationExecutorFactory>(),
      ),
    );
    gh.factory<_i98.PlaylistOperationExecutor>(
      () => _i98.PlaylistOperationExecutor(gh<_i48.PlaylistRemoteDataSource>()),
    );
    gh.lazySingleton<_i99.ProjectIncrementalSyncService>(
      () => _i99.ProjectIncrementalSyncService(
        gh<_i49.ProjectRemoteDataSource>(),
        gh<_i50.ProjectsLocalDataSource>(),
      ),
    );
    gh.factory<_i100.ProjectOperationExecutor>(
      () => _i100.ProjectOperationExecutor(gh<_i49.ProjectRemoteDataSource>()),
    );
    gh.lazySingleton<_i101.SessionStorage>(
      () => _i101.SessionStorageImpl(prefs: gh<_i57.SharedPreferences>()),
    );
    gh.lazySingleton<_i102.SyncAudioCommentsUseCase>(
      () => _i102.SyncAudioCommentsUseCase(
        gh<_i75.AudioCommentRemoteDataSource>(),
        gh<_i74.AudioCommentLocalDataSource>(),
        gh<_i49.ProjectRemoteDataSource>(),
        gh<_i101.SessionStorage>(),
        gh<_i77.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i103.SyncNotificationsUseCase>(
      () => _i103.SyncNotificationsUseCase(
        gh<_i36.NotificationRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i104.SyncProjectsUsingSimpleServiceUseCase>(
      () => _i104.SyncProjectsUsingSimpleServiceUseCase(
        gh<_i99.ProjectIncrementalSyncService>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i105.SyncUserProfileUseCase>(
      () => _i105.SyncUserProfileUseCase(
        gh<_i65.UserProfileRemoteDataSource>(),
        gh<_i64.UserProfileLocalDataSource>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i106.UserProfileCacheRepository>(
      () => _i107.UserProfileCacheRepositoryImpl(
        gh<_i65.UserProfileRemoteDataSource>(),
        gh<_i64.UserProfileLocalDataSource>(),
        gh<_i33.NetworkStateManager>(),
      ),
    );
    gh.factory<_i108.UserProfileOperationExecutor>(
      () => _i108.UserProfileOperationExecutor(
        gh<_i65.UserProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i109.WatchTrackUploadStatusUseCase>(
      () => _i109.WatchTrackUploadStatusUseCase(
        gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i110.WatchUserProfilesUseCase>(
      () => _i110.WatchUserProfilesUseCase(
        gh<_i106.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i111.AudioCommentOperationExecutor>(
      () => _i111.AudioCommentOperationExecutor(
        gh<_i75.AudioCommentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i112.AudioDownloadRepository>(
      () => _i113.AudioDownloadRepositoryImpl(
        remoteDataSource: gh<_i79.CacheStorageRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i114.AudioStorageRepository>(
      () => _i115.AudioStorageRepositoryImpl(
        localDataSource: gh<_i78.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i116.AudioTrackIncrementalSyncService>(
      () => _i116.AudioTrackIncrementalSyncService(
        gh<_i77.AudioTrackRemoteDataSource>(),
        gh<_i76.AudioTrackLocalDataSource>(),
        gh<_i49.ProjectRemoteDataSource>(),
      ),
    );
    gh.factory<_i117.AudioTrackOperationExecutor>(
      () => _i117.AudioTrackOperationExecutor(
        gh<_i77.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i118.AuthRemoteDataSource>(
      () => _i118.AuthRemoteDataSourceImpl(
        gh<_i18.FirebaseAuth>(),
        gh<_i87.GoogleAuthService>(),
      ),
    );
    gh.lazySingleton<_i119.AuthRepository>(
      () => _i120.AuthRepositoryImpl(
        remote: gh<_i118.AuthRemoteDataSource>(),
        sessionStorage: gh<_i101.SessionStorage>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        googleAuthService: gh<_i87.GoogleAuthService>(),
        appleAuthService: gh<_i73.AppleAuthService>(),
      ),
    );
    gh.lazySingleton<_i121.CacheKeyRepository>(
      () => _i122.CacheKeyRepositoryImpl(
        localDataSource: gh<_i78.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i123.CacheMaintenanceRepository>(
      () => _i124.CacheMaintenanceRepositoryImpl(
        localDataSource: gh<_i78.CacheStorageLocalDataSource>(),
      ),
    );
    gh.factory<_i125.CacheTrackUseCase>(
      () => _i125.CacheTrackUseCase(
        gh<_i112.AudioDownloadRepository>(),
        gh<_i114.AudioStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i126.CancelInvitationUseCase>(
      () => _i126.CancelInvitationUseCase(gh<_i90.InvitationRepository>()),
    );
    gh.factory<_i127.CheckAuthenticationStatusUseCase>(
      () => _i127.CheckAuthenticationStatusUseCase(gh<_i119.AuthRepository>()),
    );
    gh.factory<_i128.CurrentUserService>(
      () => _i128.CurrentUserService(gh<_i101.SessionStorage>()),
    );
    gh.factory<_i129.DeleteCachedAudioUseCase>(
      () => _i129.DeleteCachedAudioUseCase(gh<_i114.AudioStorageRepository>()),
    );
    // Removed DeleteMultipleCachedAudiosUseCase binding
    gh.lazySingleton<_i131.GenerateMagicLinkUseCase>(
      () => _i131.GenerateMagicLinkUseCase(
        gh<_i30.MagicLinkRepository>(),
        gh<_i119.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i132.GetAuthStateUseCase>(
      () => _i132.GetAuthStateUseCase(gh<_i119.AuthRepository>()),
    );
    gh.factory<_i133.GetCachedTrackPathUseCase>(
      () => _i133.GetCachedTrackPathUseCase(gh<_i114.AudioStorageRepository>()),
    );
    gh.factory<_i134.GetCurrentUserUseCase>(
      () => _i134.GetCurrentUserUseCase(gh<_i119.AuthRepository>()),
    );
    gh.lazySingleton<_i135.GetPendingInvitationsCountUseCase>(
      () => _i135.GetPendingInvitationsCountUseCase(
        gh<_i90.InvitationRepository>(),
      ),
    );
    // Removed GetPlaylistCacheStatusUseCase binding
    gh.factory<_i137.MarkAllNotificationsAsReadUseCase>(
      () => _i137.MarkAllNotificationsAsReadUseCase(
        notificationRepository: gh<_i36.NotificationRepository>(),
        currentUserService: gh<_i128.CurrentUserService>(),
      ),
    );
    gh.factory<_i138.NotificationActorBloc>(
      () => _i138.NotificationActorBloc(
        createNotificationUseCase: gh<_i81.CreateNotificationUseCase>(),
        markAsReadUseCase: gh<_i93.MarkNotificationAsReadUseCase>(),
        markAsUnreadUseCase: gh<_i92.MarkAsUnreadUseCase>(),
        markAllAsReadUseCase: gh<_i137.MarkAllNotificationsAsReadUseCase>(),
        deleteNotificationUseCase: gh<_i83.DeleteNotificationUseCase>(),
      ),
    );
    gh.factory<_i139.NotificationWatcherBloc>(
      () => _i139.NotificationWatcherBloc(
        notificationRepository: gh<_i36.NotificationRepository>(),
        currentUserService: gh<_i128.CurrentUserService>(),
      ),
    );
    gh.lazySingleton<_i140.OnboardingRepository>(
      () => _i141.OnboardingRepositoryImpl(
        gh<_i96.OnboardingStateLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i142.OnboardingUseCase>(
      () => _i142.OnboardingUseCase(gh<_i140.OnboardingRepository>()),
    );
    gh.factory<_i143.ProjectInvitationWatcherBloc>(
      () => _i143.ProjectInvitationWatcherBloc(
        invitationRepository: gh<_i90.InvitationRepository>(),
        currentUserService: gh<_i128.CurrentUserService>(),
      ),
    );
    // Removed RemovePlaylistCacheUseCase binding
    gh.factory<_i145.RemoveTrackCacheUseCase>(
      () => _i145.RemoveTrackCacheUseCase(gh<_i114.AudioStorageRepository>()),
    );
    gh.lazySingleton<_i146.SignOutUseCase>(
      () => _i146.SignOutUseCase(gh<_i119.AuthRepository>()),
    );
    gh.lazySingleton<_i147.SignUpUseCase>(
      () => _i147.SignUpUseCase(gh<_i119.AuthRepository>()),
    );
    gh.lazySingleton<_i148.SyncAudioTracksUsingSimpleServiceUseCase>(
      () => _i148.SyncAudioTracksUsingSimpleServiceUseCase(
        gh<_i116.AudioTrackIncrementalSyncService>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i149.SyncUserProfileCollaboratorsUseCase>(
      () => _i149.SyncUserProfileCollaboratorsUseCase(
        gh<_i50.ProjectsLocalDataSource>(),
        gh<_i106.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i150.TrackUploadStatusCubit>(
      () => _i150.TrackUploadStatusCubit(
        gh<_i109.WatchTrackUploadStatusUseCase>(),
      ),
    );
    gh.factory<_i151.WatchCachedAudiosUseCase>(
      () => _i151.WatchCachedAudiosUseCase(gh<_i114.AudioStorageRepository>()),
    );
    gh.factory<_i152.WatchStorageUsageUseCase>(
      () => _i152.WatchStorageUsageUseCase(gh<_i114.AudioStorageRepository>()),
    );
    gh.factory<_i153.WatchTrackCacheStatusUseCase>(
      () => _i153.WatchTrackCacheStatusUseCase(
        gh<_i114.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i154.WaveformBloc>(
      () => _i154.WaveformBloc(
        waveformRepository: gh<_i71.WaveformRepository>(),
        audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        getOrGenerate: gh<_i85.GetOrGenerateWaveform>(),
        getCachedTrackPathUseCase: gh<_i133.GetCachedTrackPathUseCase>(),
      ),
    );
    gh.lazySingleton<_i155.AppleSignInUseCase>(
      () => _i155.AppleSignInUseCase(gh<_i119.AuthRepository>()),
    );
    gh.factory<_i156.AudioSourceResolver>(
      () => _i157.AudioSourceResolverImpl(
        gh<_i114.AudioStorageRepository>(),
        gh<_i112.AudioDownloadRepository>(),
      ),
    );
    gh.factory<_i158.OnboardingBloc>(
      () => _i158.OnboardingBloc(
        onboardingUseCase: gh<_i142.OnboardingUseCase>(),
        getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
      ),
    );
    gh.factory<_i159.SyncDataManager>(
      () => _i159.SyncDataManager(
        syncProjects: gh<_i104.SyncProjectsUsingSimpleServiceUseCase>(),
        syncAudioTracks: gh<_i148.SyncAudioTracksUsingSimpleServiceUseCase>(),
        syncAudioComments: gh<_i102.SyncAudioCommentsUseCase>(),
        syncUserProfile: gh<_i105.SyncUserProfileUseCase>(),
        syncUserProfileCollaborators:
            gh<_i149.SyncUserProfileCollaboratorsUseCase>(),
        syncNotifications: gh<_i103.SyncNotificationsUseCase>(),
      ),
    );
    gh.factory<_i160.SyncStatusProvider>(
      () => _i160.SyncStatusProvider(
        syncDataManager: gh<_i159.SyncDataManager>(),
        pendingOperationsManager: gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.factory<_i161.TrackCacheBloc>(
      () => _i161.TrackCacheBloc(
        cacheTrackUseCase: gh<_i125.CacheTrackUseCase>(),
        watchTrackCacheStatusUseCase: gh<_i153.WatchTrackCacheStatusUseCase>(),
        removeTrackCacheUseCase: gh<_i145.RemoveTrackCacheUseCase>(),
        getCachedTrackPathUseCase: gh<_i133.GetCachedTrackPathUseCase>(),
      ),
    );
    gh.lazySingleton<_i162.BackgroundSyncCoordinator>(
      () => _i162.BackgroundSyncCoordinator(
        gh<_i33.NetworkStateManager>(),
        gh<_i159.SyncDataManager>(),
        gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i163.PlaylistRepository>(
      () => _i164.PlaylistRepositoryImpl(
        localDataSource: gh<_i47.PlaylistLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i162.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i165.ProjectsRepository>(
      () => _i166.ProjectsRepositoryImpl(
        localDataSource: gh<_i50.ProjectsLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i162.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i167.RemoveCollaboratorUseCase>(
      () => _i167.RemoveCollaboratorUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i168.TriggerUpstreamSyncUseCase>(
      () => _i168.TriggerUpstreamSyncUseCase(
        gh<_i162.BackgroundSyncCoordinator>(),
      ),
    );
    gh.lazySingleton<_i169.UpdateCollaboratorRoleUseCase>(
      () => _i169.UpdateCollaboratorRoleUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i170.UpdateProjectUseCase>(
      () => _i170.UpdateProjectUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i171.UserProfileRepository>(
      () => _i172.UserProfileRepositoryImpl(
        localDataSource: gh<_i64.UserProfileLocalDataSource>(),
        remoteDataSource: gh<_i65.UserProfileRemoteDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i162.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i97.PendingOperationsManager>(),
        firestore: gh<_i19.FirebaseFirestore>(),
        sessionStorage: gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i173.WatchAllProjectsUseCase>(
      () => _i173.WatchAllProjectsUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i174.WatchCollaboratorsBundleUseCase>(
      () => _i174.WatchCollaboratorsBundleUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i110.WatchUserProfilesUseCase>(),
      ),
    );
    gh.lazySingleton<_i175.WatchUserProfileUseCase>(
      () => _i175.WatchUserProfileUseCase(
        gh<_i171.UserProfileRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i176.AcceptInvitationUseCase>(
      () => _i176.AcceptInvitationUseCase(
        invitationRepository: gh<_i90.InvitationRepository>(),
        projectRepository: gh<_i165.ProjectsRepository>(),
        userProfileRepository: gh<_i171.UserProfileRepository>(),
        notificationService: gh<_i38.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i177.AddCollaboratorToProjectUseCase>(
      () => _i177.AddCollaboratorToProjectUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i178.AudioCommentRepository>(
      () => _i179.AudioCommentRepositoryImpl(
        remoteDataSource: gh<_i75.AudioCommentRemoteDataSource>(),
        localDataSource: gh<_i74.AudioCommentLocalDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i162.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i97.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i180.AudioTrackRepository>(
      () => _i181.AudioTrackRepositoryImpl(
        gh<_i76.AudioTrackLocalDataSource>(),
        gh<_i162.BackgroundSyncCoordinator>(),
        gh<_i97.PendingOperationsManager>(),
      ),
    );
    // Removed CachePlaylistUseCase binding
    gh.factory<_i183.CheckProfileCompletenessUseCase>(
      () => _i183.CheckProfileCompletenessUseCase(
        gh<_i171.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i184.CreateProjectUseCase>(
      () => _i184.CreateProjectUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.factory<_i185.CreateUserProfileUseCase>(
      () => _i185.CreateUserProfileUseCase(
        gh<_i171.UserProfileRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i186.DeclineInvitationUseCase>(
      () => _i186.DeclineInvitationUseCase(
        invitationRepository: gh<_i90.InvitationRepository>(),
        projectRepository: gh<_i165.ProjectsRepository>(),
        userProfileRepository: gh<_i171.UserProfileRepository>(),
        notificationService: gh<_i38.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i187.FindUserByEmailUseCase>(
      () => _i187.FindUserByEmailUseCase(gh<_i171.UserProfileRepository>()),
    );
    gh.factory<_i188.GetCachedTrackBundlesUseCase>(
      () => _i188.GetCachedTrackBundlesUseCase(
        gh<_i10.CacheMaintenanceService>(),
        gh<_i114.AudioStorageRepository>(),
        gh<_i180.AudioTrackRepository>(),
        gh<_i171.UserProfileRepository>(),
        gh<_i165.ProjectsRepository>(),
        gh<_i112.AudioDownloadRepository>(),
      ),
    );
    gh.lazySingleton<_i189.GetProjectByIdUseCase>(
      () => _i189.GetProjectByIdUseCase(gh<_i165.ProjectsRepository>()),
    );
    gh.lazySingleton<_i190.GoogleSignInUseCase>(
      () => _i190.GoogleSignInUseCase(
        gh<_i119.AuthRepository>(),
        gh<_i171.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i191.JoinProjectWithIdUseCase>(
      () => _i191.JoinProjectWithIdUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i192.LeaveProjectUseCase>(
      () => _i192.LeaveProjectUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.factory<_i193.MagicLinkBloc>(
      () => _i193.MagicLinkBloc(
        generateMagicLink: gh<_i131.GenerateMagicLinkUseCase>(),
        validateMagicLink: gh<_i66.ValidateMagicLinkUseCase>(),
        consumeMagicLink: gh<_i80.ConsumeMagicLinkUseCase>(),
        resendMagicLink: gh<_i51.ResendMagicLinkUseCase>(),
        getMagicLinkStatus: gh<_i84.GetMagicLinkStatusUseCase>(),
        joinProjectWithId: gh<_i191.JoinProjectWithIdUseCase>(),
        authRepository: gh<_i119.AuthRepository>(),
      ),
    );
    gh.factory<_i194.PlayAudioUseCase>(
      () => _i194.PlayAudioUseCase(
        audioTrackRepository: gh<_i180.AudioTrackRepository>(),
        audioStorageRepository: gh<_i114.AudioStorageRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i195.PlayPlaylistUseCase>(
      () => _i195.PlayPlaylistUseCase(
        playlistRepository: gh<_i163.PlaylistRepository>(),
        audioTrackRepository: gh<_i180.AudioTrackRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
        audioStorageRepository: gh<_i114.AudioStorageRepository>(),
      ),
    );
    // Removed PlaylistCacheBloc binding
    gh.lazySingleton<_i197.ProjectCommentService>(
      () => _i197.ProjectCommentService(gh<_i178.AudioCommentRepository>()),
    );
    gh.lazySingleton<_i198.ProjectTrackService>(
      () => _i198.ProjectTrackService(
        gh<_i180.AudioTrackRepository>(),
        gh<_i114.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i199.RestorePlaybackStateUseCase>(
      () => _i199.RestorePlaybackStateUseCase(
        persistenceRepository: gh<_i45.PlaybackPersistenceRepository>(),
        audioTrackRepository: gh<_i180.AudioTrackRepository>(),
        audioStorageRepository: gh<_i114.AudioStorageRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i200.SendInvitationUseCase>(
      () => _i200.SendInvitationUseCase(
        invitationRepository: gh<_i90.InvitationRepository>(),
        notificationService: gh<_i38.NotificationService>(),
        findUserByEmail: gh<_i187.FindUserByEmailUseCase>(),
        magicLinkRepository: gh<_i30.MagicLinkRepository>(),
        currentUserService: gh<_i128.CurrentUserService>(),
      ),
    );
    gh.factory<_i201.SessionCleanupService>(
      () => _i201.SessionCleanupService(
        userProfileRepository: gh<_i171.UserProfileRepository>(),
        projectsRepository: gh<_i165.ProjectsRepository>(),
        audioTrackRepository: gh<_i180.AudioTrackRepository>(),
        audioCommentRepository: gh<_i178.AudioCommentRepository>(),
        invitationRepository: gh<_i90.InvitationRepository>(),
        playbackPersistenceRepository: gh<_i45.PlaybackPersistenceRepository>(),
        blocStateCleanupService: gh<_i9.BlocStateCleanupService>(),
        sessionStorage: gh<_i101.SessionStorage>(),
      ),
    );
    gh.factory<_i202.SessionService>(
      () => _i202.SessionService(
        checkAuthUseCase: gh<_i127.CheckAuthenticationStatusUseCase>(),
        getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
        onboardingUseCase: gh<_i142.OnboardingUseCase>(),
        profileUseCase: gh<_i183.CheckProfileCompletenessUseCase>(),
      ),
    );
    gh.lazySingleton<_i203.SignInUseCase>(
      () => _i203.SignInUseCase(
        gh<_i119.AuthRepository>(),
        gh<_i171.UserProfileRepository>(),
      ),
    );
    gh.factory<_i204.SyncStatusCubit>(
      () => _i204.SyncStatusCubit(
        gh<_i160.SyncStatusProvider>(),
        gh<_i97.PendingOperationsManager>(),
        gh<_i168.TriggerUpstreamSyncUseCase>(),
      ),
    );
    gh.factory<_i205.UpdateUserProfileUseCase>(
      () => _i205.UpdateUserProfileUseCase(
        gh<_i171.UserProfileRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i206.UploadAudioTrackUseCase>(
      () => _i206.UploadAudioTrackUseCase(
        gh<_i198.ProjectTrackService>(),
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
        gh<_i4.AudioMetadataService>(),
        gh<_i85.GetOrGenerateWaveform>(),
      ),
    );
    gh.factory<_i207.UserProfileBloc>(
      () => _i207.UserProfileBloc(
        updateUserProfileUseCase: gh<_i205.UpdateUserProfileUseCase>(),
        createUserProfileUseCase: gh<_i185.CreateUserProfileUseCase>(),
        watchUserProfileUseCase: gh<_i175.WatchUserProfileUseCase>(),
        checkProfileCompletenessUseCase:
            gh<_i183.CheckProfileCompletenessUseCase>(),
        getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i208.WatchAudioCommentsBundleUseCase>(
      () => _i208.WatchAudioCommentsBundleUseCase(
        gh<_i180.AudioTrackRepository>(),
        gh<_i178.AudioCommentRepository>(),
        gh<_i106.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i209.WatchCachedTrackBundlesUseCase>(
      () => _i209.WatchCachedTrackBundlesUseCase(
        gh<_i151.WatchCachedAudiosUseCase>(),
        gh<_i112.AudioDownloadRepository>(),
        gh<_i180.AudioTrackRepository>(),
        gh<_i171.UserProfileRepository>(),
        gh<_i165.ProjectsRepository>(),
      ),
    );
    gh.lazySingleton<_i210.WatchProjectDetailUseCase>(
      () => _i210.WatchProjectDetailUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i180.AudioTrackRepository>(),
        gh<_i106.UserProfileCacheRepository>(),
      ),
    );
    gh.lazySingleton<_i211.WatchTracksByProjectIdUseCase>(
      () =>
          _i211.WatchTracksByProjectIdUseCase(gh<_i180.AudioTrackRepository>()),
    );
    gh.lazySingleton<_i212.AddAudioCommentUseCase>(
      () => _i212.AddAudioCommentUseCase(
        gh<_i197.ProjectCommentService>(),
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i213.AddCollaboratorByEmailUseCase>(
      () => _i213.AddCollaboratorByEmailUseCase(
        gh<_i187.FindUserByEmailUseCase>(),
        gh<_i177.AddCollaboratorToProjectUseCase>(),
        gh<_i38.NotificationService>(),
      ),
    );
    gh.factory<_i214.AppBootstrap>(
      () => _i214.AppBootstrap(
        sessionService: gh<_i202.SessionService>(),
        performanceCollector: gh<_i44.PerformanceMetricsCollector>(),
        dynamicLinkService: gh<_i16.DynamicLinkService>(),
        databaseHealthMonitor: gh<_i82.DatabaseHealthMonitor>(),
      ),
    );
    gh.factory<_i215.AppFlowBloc>(
      () => _i215.AppFlowBloc(
        appBootstrap: gh<_i214.AppBootstrap>(),
        backgroundSyncCoordinator: gh<_i162.BackgroundSyncCoordinator>(),
        getAuthStateUseCase: gh<_i132.GetAuthStateUseCase>(),
        sessionCleanupService: gh<_i201.SessionCleanupService>(),
      ),
    );
    gh.lazySingleton<_i216.AudioContextService>(
      () => _i217.AudioContextServiceImpl(
        userProfileRepository: gh<_i171.UserProfileRepository>(),
        audioTrackRepository: gh<_i180.AudioTrackRepository>(),
        projectsRepository: gh<_i165.ProjectsRepository>(),
      ),
    );
    gh.factory<_i218.AudioPlayerService>(
      () => _i218.AudioPlayerService(
        initializeAudioPlayerUseCase: gh<_i24.InitializeAudioPlayerUseCase>(),
        playAudioUseCase: gh<_i194.PlayAudioUseCase>(),
        playPlaylistUseCase: gh<_i195.PlayPlaylistUseCase>(),
        pauseAudioUseCase: gh<_i41.PauseAudioUseCase>(),
        resumeAudioUseCase: gh<_i52.ResumeAudioUseCase>(),
        stopAudioUseCase: gh<_i60.StopAudioUseCase>(),
        skipToNextUseCase: gh<_i58.SkipToNextUseCase>(),
        skipToPreviousUseCase: gh<_i59.SkipToPreviousUseCase>(),
        seekAudioUseCase: gh<_i54.SeekAudioUseCase>(),
        toggleShuffleUseCase: gh<_i63.ToggleShuffleUseCase>(),
        toggleRepeatModeUseCase: gh<_i62.ToggleRepeatModeUseCase>(),
        setVolumeUseCase: gh<_i56.SetVolumeUseCase>(),
        setPlaybackSpeedUseCase: gh<_i55.SetPlaybackSpeedUseCase>(),
        savePlaybackStateUseCase: gh<_i53.SavePlaybackStateUseCase>(),
        restorePlaybackStateUseCase: gh<_i199.RestorePlaybackStateUseCase>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i219.AuthBloc>(
      () => _i219.AuthBloc(
        signIn: gh<_i203.SignInUseCase>(),
        signUp: gh<_i147.SignUpUseCase>(),
        googleSignIn: gh<_i190.GoogleSignInUseCase>(),
        appleSignIn: gh<_i155.AppleSignInUseCase>(),
        signOut: gh<_i146.SignOutUseCase>(),
      ),
    );
    gh.factory<_i220.CacheManagementBloc>(
      () => _i220.CacheManagementBloc(
        getBundles: gh<_i188.GetCachedTrackBundlesUseCase>(),
        deleteOne: gh<_i129.DeleteCachedAudioUseCase>(),
        // deleteMany: gh<_i130.DeleteMultipleCachedAudiosUseCase>(),
        watchUsage: gh<_i152.WatchStorageUsageUseCase>(),
        getStats: gh<_i21.GetCacheStorageStatsUseCase>(),
        cleanup: gh<_i12.CleanupCacheUseCase>(),
        watchBundles: gh<_i209.WatchCachedTrackBundlesUseCase>(),
      ),
    );
    gh.lazySingleton<_i221.DeleteAudioCommentUseCase>(
      () => _i221.DeleteAudioCommentUseCase(
        gh<_i197.ProjectCommentService>(),
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i222.DeleteAudioTrack>(
      () => _i222.DeleteAudioTrack(
        gh<_i101.SessionStorage>(),
        gh<_i165.ProjectsRepository>(),
        gh<_i198.ProjectTrackService>(),
      ),
    );
    gh.lazySingleton<_i223.DeleteProjectUseCase>(
      () => _i223.DeleteProjectUseCase(
        gh<_i165.ProjectsRepository>(),
        gh<_i101.SessionStorage>(),
        gh<_i198.ProjectTrackService>(),
      ),
    );
    gh.lazySingleton<_i224.EditAudioTrackUseCase>(
      () => _i224.EditAudioTrackUseCase(
        gh<_i198.ProjectTrackService>(),
        gh<_i165.ProjectsRepository>(),
      ),
    );
    gh.factory<_i225.LoadTrackContextUseCase>(
      () => _i225.LoadTrackContextUseCase(gh<_i216.AudioContextService>()),
    );
    gh.factory<_i226.ManageCollaboratorsBloc>(
      () => _i226.ManageCollaboratorsBloc(
        removeCollaboratorUseCase: gh<_i167.RemoveCollaboratorUseCase>(),
        updateCollaboratorRoleUseCase:
            gh<_i169.UpdateCollaboratorRoleUseCase>(),
        leaveProjectUseCase: gh<_i192.LeaveProjectUseCase>(),
        findUserByEmailUseCase: gh<_i187.FindUserByEmailUseCase>(),
        addCollaboratorByEmailUseCase:
            gh<_i213.AddCollaboratorByEmailUseCase>(),
        watchCollaboratorsBundleUseCase:
            gh<_i174.WatchCollaboratorsBundleUseCase>(),
      ),
    );
    gh.factory<_i227.ProjectDetailBloc>(
      () => _i227.ProjectDetailBloc(
        watchProjectDetail: gh<_i210.WatchProjectDetailUseCase>(),
      ),
    );
    gh.factory<_i228.ProjectInvitationActorBloc>(
      () => _i228.ProjectInvitationActorBloc(
        sendInvitationUseCase: gh<_i200.SendInvitationUseCase>(),
        acceptInvitationUseCase: gh<_i176.AcceptInvitationUseCase>(),
        declineInvitationUseCase: gh<_i186.DeclineInvitationUseCase>(),
        cancelInvitationUseCase: gh<_i126.CancelInvitationUseCase>(),
        findUserByEmailUseCase: gh<_i187.FindUserByEmailUseCase>(),
      ),
    );
    gh.factory<_i229.ProjectsBloc>(
      () => _i229.ProjectsBloc(
        createProject: gh<_i184.CreateProjectUseCase>(),
        updateProject: gh<_i170.UpdateProjectUseCase>(),
        deleteProject: gh<_i223.DeleteProjectUseCase>(),
        watchAllProjects: gh<_i173.WatchAllProjectsUseCase>(),
      ),
    );
    gh.factory<_i230.AudioCommentBloc>(
      () => _i230.AudioCommentBloc(
        addAudioCommentUseCase: gh<_i212.AddAudioCommentUseCase>(),
        deleteAudioCommentUseCase: gh<_i221.DeleteAudioCommentUseCase>(),
        watchAudioCommentsBundleUseCase:
            gh<_i208.WatchAudioCommentsBundleUseCase>(),
      ),
    );
    gh.factory<_i231.AudioContextBloc>(
      () => _i231.AudioContextBloc(
        loadTrackContextUseCase: gh<_i225.LoadTrackContextUseCase>(),
      ),
    );
    gh.factory<_i232.AudioPlayerBloc>(
      () => _i232.AudioPlayerBloc(
        audioPlayerService: gh<_i218.AudioPlayerService>(),
      ),
    );
    gh.factory<_i233.AudioTrackBloc>(
      () => _i233.AudioTrackBloc(
        watchAudioTracksByProject: gh<_i211.WatchTracksByProjectIdUseCase>(),
        deleteAudioTrack: gh<_i222.DeleteAudioTrack>(),
        uploadAudioTrackUseCase: gh<_i206.UploadAudioTrackUseCase>(),
        editAudioTrackUseCase: gh<_i224.EditAudioTrackUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i234.AppModule {}
