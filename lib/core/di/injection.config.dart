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
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i99;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i17;
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart'
    as _i213;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i9;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i201;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i202;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i126;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i131;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i133;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i214;
import 'package:trackflow/core/di/app_module.dart' as _i231;
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
    as _i80;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i82;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i85;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i136;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i90;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i91;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i39;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i137;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i138;
import 'package:trackflow/core/services/database_health_monitor.dart' as _i81;
import 'package:trackflow/core/services/deep_link_service.dart' as _i14;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i16;
import 'package:trackflow/core/services/image_maintenance_service.dart' as _i23;
import 'package:trackflow/core/services/performance_metrics_collector.dart'
    as _i44;
import 'package:trackflow/core/session/current_user_service.dart' as _i127;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i42;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i43;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i110;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i116;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i96;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i98;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i160;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i95;
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart'
    as _i157;
import 'package:trackflow/core/sync/domain/services/sync_metadata_manager.dart'
    as _i61;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i158;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart'
    as _i100;
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart'
    as _i147;
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart'
    as _i101;
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart'
    as _i102;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart'
    as _i148;
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart'
    as _i103;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i166;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i204;
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i128;
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_multiple_cached_audios_usecase.dart'
    as _i129;
import 'package:trackflow/features/audio_cache/management/domain/usecases/get_cached_track_bundles_usecase.dart'
    as _i187;
import 'package:trackflow/features/audio_cache/management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i150;
import 'package:trackflow/features/audio_cache/management/presentation/bloc/cache_management_bloc.dart'
    as _i219;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i180;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i135;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i143;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i195;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i77;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i78;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_download_repository_impl.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/shared/data/repositories/audio_storage_repository_impl.dart'
    as _i114;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_key_repository_impl.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_maintenance_repository_impl.dart'
    as _i123;
import 'package:trackflow/features/audio_cache/shared/data/services/cache_maintenance_service_impl.dart'
    as _i11;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart'
    as _i113;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_key_repository.dart'
    as _i120;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart'
    as _i10;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i12;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i124;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart'
    as _i132;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i144;
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart'
    as _i151;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i159;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i177;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i176;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i196;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i211;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i220;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i208;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i227;
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart'
    as _i215;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i223;
import 'package:trackflow/features/audio_context/infrastructure/service/audio_context_service_impl.dart'
    as _i216;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i228;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i45;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i217;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i153;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i24;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i193;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i194;
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
    as _i154;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i229;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i75;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i76;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i179;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i115;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i178;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i197;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i221;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i222;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i206;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i210;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i107;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i230;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i149;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i117;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i72;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i86;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i118;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i152;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i189;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i203;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i145;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i146;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i218;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i87;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i26;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i89;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i88;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i174;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i125;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i184;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i134;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i92;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i93;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i200;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i226;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i142;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i28;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i29;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i31;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i30;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i79;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i130;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i84;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i51;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i192;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i212;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i175;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i186;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i190;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i191;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i165;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i167;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i172;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i224;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i32;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i94;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i140;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i141;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i139;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i156;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i47;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i48;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i162;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i161;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i209;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i225;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i50;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i49;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i164;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i97;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i163;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i182;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i185;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i188;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i168;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i171;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i198;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i65;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i105;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i170;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i169;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i104;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i181;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i183;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i205;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i173;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i108;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i207;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i69;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i71;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i68;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i70;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i67;
import 'package:trackflow/features/waveform/domain/usecases/generate_waveform_usecase.dart'
    as _i83;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i109;

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
    gh.factory<_i70.WaveformRepository>(
      () => _i71.WaveformRepositoryImpl(
        localDataSource: gh<_i69.WaveformLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i72.AppleAuthService>(
      () => _i72.AppleAuthService(gh<_i18.FirebaseAuth>()),
    );
    gh.lazySingleton<_i73.AudioCommentLocalDataSource>(
      () => _i73.IsarAudioCommentLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i74.AudioCommentRemoteDataSource>(
      () => _i74.FirebaseAudioCommentRemoteDataSource(
        gh<_i19.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i75.AudioTrackLocalDataSource>(
      () => _i75.IsarAudioTrackLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i76.AudioTrackRemoteDataSource>(
      () => _i76.AudioTrackRemoteDataSourceImpl(
        gh<_i19.FirebaseFirestore>(),
        gh<_i20.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i77.CacheStorageLocalDataSource>(
      () => _i77.CacheStorageLocalDataSourceImpl(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i78.CacheStorageRemoteDataSource>(
      () => _i78.CacheStorageRemoteDataSourceImpl(gh<_i20.FirebaseStorage>()),
    );
    gh.lazySingleton<_i79.ConsumeMagicLinkUseCase>(
      () => _i79.ConsumeMagicLinkUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.factory<_i80.CreateNotificationUseCase>(
      () => _i80.CreateNotificationUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.factory<_i81.DatabaseHealthMonitor>(
      () => _i81.DatabaseHealthMonitor(gh<_i27.Isar>()),
    );
    gh.factory<_i82.DeleteNotificationUseCase>(
      () => _i82.DeleteNotificationUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.factory<_i83.GenerateWaveformUseCase>(
      () => _i83.GenerateWaveformUseCase(
        generatorService: gh<_i67.WaveformGeneratorService>(),
        repository: gh<_i70.WaveformRepository>(),
      ),
    );
    gh.lazySingleton<_i84.GetMagicLinkStatusUseCase>(
      () => _i84.GetMagicLinkStatusUseCase(gh<_i30.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i85.GetUnreadNotificationsCountUseCase>(
      () => _i85.GetUnreadNotificationsCountUseCase(
        gh<_i36.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i86.GoogleAuthService>(
      () => _i86.GoogleAuthService(
        gh<_i22.GoogleSignIn>(),
        gh<_i18.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i87.InvitationLocalDataSource>(
      () => _i87.IsarInvitationLocalDataSource(gh<_i27.Isar>()),
    );
    gh.lazySingleton<_i88.InvitationRepository>(
      () => _i89.InvitationRepositoryImpl(
        localDataSource: gh<_i87.InvitationLocalDataSource>(),
        remoteDataSource: gh<_i26.InvitationRemoteDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
      ),
    );
    gh.factory<_i90.MarkAsUnreadUseCase>(
      () => _i90.MarkAsUnreadUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i91.MarkNotificationAsReadUseCase>(
      () =>
          _i91.MarkNotificationAsReadUseCase(gh<_i36.NotificationRepository>()),
    );
    gh.lazySingleton<_i92.ObservePendingInvitationsUseCase>(
      () => _i92.ObservePendingInvitationsUseCase(
        gh<_i88.InvitationRepository>(),
      ),
    );
    gh.lazySingleton<_i93.ObserveSentInvitationsUseCase>(
      () => _i93.ObserveSentInvitationsUseCase(gh<_i88.InvitationRepository>()),
    );
    gh.lazySingleton<_i94.OnboardingStateLocalDataSource>(
      () =>
          _i94.OnboardingStateLocalDataSourceImpl(gh<_i57.SharedPreferences>()),
    );
    gh.lazySingleton<_i95.PendingOperationsManager>(
      () => _i95.PendingOperationsManager(
        gh<_i43.PendingOperationsRepository>(),
        gh<_i33.NetworkStateManager>(),
        gh<_i40.OperationExecutorFactory>(),
      ),
    );
    gh.factory<_i96.PlaylistOperationExecutor>(
      () => _i96.PlaylistOperationExecutor(gh<_i48.PlaylistRemoteDataSource>()),
    );
    gh.lazySingleton<_i97.ProjectIncrementalSyncService>(
      () => _i97.ProjectIncrementalSyncService(
        gh<_i49.ProjectRemoteDataSource>(),
        gh<_i50.ProjectsLocalDataSource>(),
      ),
    );
    gh.factory<_i98.ProjectOperationExecutor>(
      () => _i98.ProjectOperationExecutor(gh<_i49.ProjectRemoteDataSource>()),
    );
    gh.lazySingleton<_i99.SessionStorage>(
      () => _i99.SessionStorageImpl(prefs: gh<_i57.SharedPreferences>()),
    );
    gh.lazySingleton<_i100.SyncAudioCommentsUseCase>(
      () => _i100.SyncAudioCommentsUseCase(
        gh<_i74.AudioCommentRemoteDataSource>(),
        gh<_i73.AudioCommentLocalDataSource>(),
        gh<_i49.ProjectRemoteDataSource>(),
        gh<_i99.SessionStorage>(),
        gh<_i76.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i101.SyncNotificationsUseCase>(
      () => _i101.SyncNotificationsUseCase(
        gh<_i36.NotificationRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i102.SyncProjectsUsingSimpleServiceUseCase>(
      () => _i102.SyncProjectsUsingSimpleServiceUseCase(
        gh<_i97.ProjectIncrementalSyncService>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i103.SyncUserProfileUseCase>(
      () => _i103.SyncUserProfileUseCase(
        gh<_i65.UserProfileRemoteDataSource>(),
        gh<_i64.UserProfileLocalDataSource>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i104.UserProfileCacheRepository>(
      () => _i105.UserProfileCacheRepositoryImpl(
        gh<_i65.UserProfileRemoteDataSource>(),
        gh<_i64.UserProfileLocalDataSource>(),
        gh<_i33.NetworkStateManager>(),
      ),
    );
    gh.factory<_i106.UserProfileOperationExecutor>(
      () => _i106.UserProfileOperationExecutor(
        gh<_i65.UserProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i107.WatchTrackUploadStatusUseCase>(
      () => _i107.WatchTrackUploadStatusUseCase(
        gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i108.WatchUserProfilesUseCase>(
      () => _i108.WatchUserProfilesUseCase(
        gh<_i104.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i109.WaveformBloc>(
      () => _i109.WaveformBloc(
        waveformRepository: gh<_i70.WaveformRepository>(),
        audioPlaybackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i110.AudioCommentOperationExecutor>(
      () => _i110.AudioCommentOperationExecutor(
        gh<_i74.AudioCommentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i111.AudioDownloadRepository>(
      () => _i112.AudioDownloadRepositoryImpl(
        remoteDataSource: gh<_i78.CacheStorageRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i113.AudioStorageRepository>(
      () => _i114.AudioStorageRepositoryImpl(
        localDataSource: gh<_i77.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i115.AudioTrackIncrementalSyncService>(
      () => _i115.AudioTrackIncrementalSyncService(
        gh<_i76.AudioTrackRemoteDataSource>(),
        gh<_i75.AudioTrackLocalDataSource>(),
        gh<_i49.ProjectRemoteDataSource>(),
      ),
    );
    gh.factory<_i116.AudioTrackOperationExecutor>(
      () => _i116.AudioTrackOperationExecutor(
        gh<_i76.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i117.AuthRemoteDataSource>(
      () => _i117.AuthRemoteDataSourceImpl(
        gh<_i18.FirebaseAuth>(),
        gh<_i86.GoogleAuthService>(),
      ),
    );
    gh.lazySingleton<_i118.AuthRepository>(
      () => _i119.AuthRepositoryImpl(
        remote: gh<_i117.AuthRemoteDataSource>(),
        sessionStorage: gh<_i99.SessionStorage>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        googleAuthService: gh<_i86.GoogleAuthService>(),
        appleAuthService: gh<_i72.AppleAuthService>(),
      ),
    );
    gh.lazySingleton<_i120.CacheKeyRepository>(
      () => _i121.CacheKeyRepositoryImpl(
        localDataSource: gh<_i77.CacheStorageLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i122.CacheMaintenanceRepository>(
      () => _i123.CacheMaintenanceRepositoryImpl(
        localDataSource: gh<_i77.CacheStorageLocalDataSource>(),
      ),
    );
    gh.factory<_i124.CacheTrackUseCase>(
      () => _i124.CacheTrackUseCase(
        gh<_i111.AudioDownloadRepository>(),
        gh<_i113.AudioStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i125.CancelInvitationUseCase>(
      () => _i125.CancelInvitationUseCase(gh<_i88.InvitationRepository>()),
    );
    gh.factory<_i126.CheckAuthenticationStatusUseCase>(
      () => _i126.CheckAuthenticationStatusUseCase(gh<_i118.AuthRepository>()),
    );
    gh.factory<_i127.CurrentUserService>(
      () => _i127.CurrentUserService(gh<_i99.SessionStorage>()),
    );
    gh.factory<_i128.DeleteCachedAudioUseCase>(
      () => _i128.DeleteCachedAudioUseCase(gh<_i113.AudioStorageRepository>()),
    );
    gh.factory<_i129.DeleteMultipleCachedAudiosUseCase>(
      () => _i129.DeleteMultipleCachedAudiosUseCase(
        gh<_i113.AudioStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i130.GenerateMagicLinkUseCase>(
      () => _i130.GenerateMagicLinkUseCase(
        gh<_i30.MagicLinkRepository>(),
        gh<_i118.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i131.GetAuthStateUseCase>(
      () => _i131.GetAuthStateUseCase(gh<_i118.AuthRepository>()),
    );
    gh.factory<_i132.GetCachedTrackPathUseCase>(
      () => _i132.GetCachedTrackPathUseCase(gh<_i113.AudioStorageRepository>()),
    );
    gh.factory<_i133.GetCurrentUserUseCase>(
      () => _i133.GetCurrentUserUseCase(gh<_i118.AuthRepository>()),
    );
    gh.lazySingleton<_i134.GetPendingInvitationsCountUseCase>(
      () => _i134.GetPendingInvitationsCountUseCase(
        gh<_i88.InvitationRepository>(),
      ),
    );
    gh.factory<_i135.GetPlaylistCacheStatusUseCase>(
      () => _i135.GetPlaylistCacheStatusUseCase(
        gh<_i113.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i136.MarkAllNotificationsAsReadUseCase>(
      () => _i136.MarkAllNotificationsAsReadUseCase(
        notificationRepository: gh<_i36.NotificationRepository>(),
        currentUserService: gh<_i127.CurrentUserService>(),
      ),
    );
    gh.factory<_i137.NotificationActorBloc>(
      () => _i137.NotificationActorBloc(
        createNotificationUseCase: gh<_i80.CreateNotificationUseCase>(),
        markAsReadUseCase: gh<_i91.MarkNotificationAsReadUseCase>(),
        markAsUnreadUseCase: gh<_i90.MarkAsUnreadUseCase>(),
        markAllAsReadUseCase: gh<_i136.MarkAllNotificationsAsReadUseCase>(),
        deleteNotificationUseCase: gh<_i82.DeleteNotificationUseCase>(),
      ),
    );
    gh.factory<_i138.NotificationWatcherBloc>(
      () => _i138.NotificationWatcherBloc(
        notificationRepository: gh<_i36.NotificationRepository>(),
        currentUserService: gh<_i127.CurrentUserService>(),
      ),
    );
    gh.lazySingleton<_i139.OnboardingRepository>(
      () => _i140.OnboardingRepositoryImpl(
        gh<_i94.OnboardingStateLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i141.OnboardingUseCase>(
      () => _i141.OnboardingUseCase(gh<_i139.OnboardingRepository>()),
    );
    gh.factory<_i142.ProjectInvitationWatcherBloc>(
      () => _i142.ProjectInvitationWatcherBloc(
        invitationRepository: gh<_i88.InvitationRepository>(),
        currentUserService: gh<_i127.CurrentUserService>(),
      ),
    );
    gh.factory<_i143.RemovePlaylistCacheUseCase>(
      () =>
          _i143.RemovePlaylistCacheUseCase(gh<_i113.AudioStorageRepository>()),
    );
    gh.factory<_i144.RemoveTrackCacheUseCase>(
      () => _i144.RemoveTrackCacheUseCase(gh<_i113.AudioStorageRepository>()),
    );
    gh.lazySingleton<_i145.SignOutUseCase>(
      () => _i145.SignOutUseCase(gh<_i118.AuthRepository>()),
    );
    gh.lazySingleton<_i146.SignUpUseCase>(
      () => _i146.SignUpUseCase(gh<_i118.AuthRepository>()),
    );
    gh.lazySingleton<_i147.SyncAudioTracksUsingSimpleServiceUseCase>(
      () => _i147.SyncAudioTracksUsingSimpleServiceUseCase(
        gh<_i115.AudioTrackIncrementalSyncService>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i148.SyncUserProfileCollaboratorsUseCase>(
      () => _i148.SyncUserProfileCollaboratorsUseCase(
        gh<_i50.ProjectsLocalDataSource>(),
        gh<_i104.UserProfileCacheRepository>(),
      ),
    );
    gh.factory<_i149.TrackUploadStatusCubit>(
      () => _i149.TrackUploadStatusCubit(
        gh<_i107.WatchTrackUploadStatusUseCase>(),
      ),
    );
    gh.factory<_i150.WatchStorageUsageUseCase>(
      () => _i150.WatchStorageUsageUseCase(gh<_i113.AudioStorageRepository>()),
    );
    gh.factory<_i151.WatchTrackCacheStatusUseCase>(
      () => _i151.WatchTrackCacheStatusUseCase(
        gh<_i113.AudioStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i152.AppleSignInUseCase>(
      () => _i152.AppleSignInUseCase(gh<_i118.AuthRepository>()),
    );
    gh.factory<_i153.AudioSourceResolver>(
      () => _i154.AudioSourceResolverImpl(
        gh<_i113.AudioStorageRepository>(),
        gh<_i111.AudioDownloadRepository>(),
      ),
    );
    gh.factory<_i156.OnboardingBloc>(
      () => _i156.OnboardingBloc(
        onboardingUseCase: gh<_i141.OnboardingUseCase>(),
        getCurrentUserUseCase: gh<_i133.GetCurrentUserUseCase>(),
      ),
    );
    gh.factory<_i157.SyncDataManager>(
      () => _i157.SyncDataManager(
        syncProjects: gh<_i102.SyncProjectsUsingSimpleServiceUseCase>(),
        syncAudioTracks: gh<_i147.SyncAudioTracksUsingSimpleServiceUseCase>(),
        syncAudioComments: gh<_i100.SyncAudioCommentsUseCase>(),
        syncUserProfile: gh<_i103.SyncUserProfileUseCase>(),
        syncUserProfileCollaborators:
            gh<_i148.SyncUserProfileCollaboratorsUseCase>(),
        syncNotifications: gh<_i101.SyncNotificationsUseCase>(),
      ),
    );
    gh.factory<_i158.SyncStatusProvider>(
      () => _i158.SyncStatusProvider(
        syncDataManager: gh<_i157.SyncDataManager>(),
        pendingOperationsManager: gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.factory<_i159.TrackCacheBloc>(
      () => _i159.TrackCacheBloc(
        cacheTrackUseCase: gh<_i124.CacheTrackUseCase>(),
        watchTrackCacheStatusUseCase: gh<_i151.WatchTrackCacheStatusUseCase>(),
        removeTrackCacheUseCase: gh<_i144.RemoveTrackCacheUseCase>(),
        getCachedTrackPathUseCase: gh<_i132.GetCachedTrackPathUseCase>(),
      ),
    );
    gh.lazySingleton<_i160.BackgroundSyncCoordinator>(
      () => _i160.BackgroundSyncCoordinator(
        gh<_i33.NetworkStateManager>(),
        gh<_i157.SyncDataManager>(),
        gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i161.PlaylistRepository>(
      () => _i162.PlaylistRepositoryImpl(
        localDataSource: gh<_i47.PlaylistLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i160.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i163.ProjectsRepository>(
      () => _i164.ProjectsRepositoryImpl(
        localDataSource: gh<_i50.ProjectsLocalDataSource>(),
        backgroundSyncCoordinator: gh<_i160.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i165.RemoveCollaboratorUseCase>(
      () => _i165.RemoveCollaboratorUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i166.TriggerUpstreamSyncUseCase>(
      () => _i166.TriggerUpstreamSyncUseCase(
        gh<_i160.BackgroundSyncCoordinator>(),
      ),
    );
    gh.lazySingleton<_i167.UpdateCollaboratorRoleUseCase>(
      () => _i167.UpdateCollaboratorRoleUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i168.UpdateProjectUseCase>(
      () => _i168.UpdateProjectUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i169.UserProfileRepository>(
      () => _i170.UserProfileRepositoryImpl(
        localDataSource: gh<_i64.UserProfileLocalDataSource>(),
        remoteDataSource: gh<_i65.UserProfileRemoteDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i160.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i95.PendingOperationsManager>(),
        firestore: gh<_i19.FirebaseFirestore>(),
        sessionStorage: gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i171.WatchAllProjectsUseCase>(
      () => _i171.WatchAllProjectsUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i172.WatchCollaboratorsBundleUseCase>(
      () => _i172.WatchCollaboratorsBundleUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i108.WatchUserProfilesUseCase>(),
      ),
    );
    gh.lazySingleton<_i173.WatchUserProfileUseCase>(
      () => _i173.WatchUserProfileUseCase(
        gh<_i169.UserProfileRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i174.AcceptInvitationUseCase>(
      () => _i174.AcceptInvitationUseCase(
        invitationRepository: gh<_i88.InvitationRepository>(),
        projectRepository: gh<_i163.ProjectsRepository>(),
        userProfileRepository: gh<_i169.UserProfileRepository>(),
        notificationService: gh<_i38.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i175.AddCollaboratorToProjectUseCase>(
      () => _i175.AddCollaboratorToProjectUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i176.AudioCommentRepository>(
      () => _i177.AudioCommentRepositoryImpl(
        remoteDataSource: gh<_i74.AudioCommentRemoteDataSource>(),
        localDataSource: gh<_i73.AudioCommentLocalDataSource>(),
        networkStateManager: gh<_i33.NetworkStateManager>(),
        backgroundSyncCoordinator: gh<_i160.BackgroundSyncCoordinator>(),
        pendingOperationsManager: gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.lazySingleton<_i178.AudioTrackRepository>(
      () => _i179.AudioTrackRepositoryImpl(
        gh<_i75.AudioTrackLocalDataSource>(),
        gh<_i160.BackgroundSyncCoordinator>(),
        gh<_i95.PendingOperationsManager>(),
      ),
    );
    gh.factory<_i180.CachePlaylistUseCase>(
      () => _i180.CachePlaylistUseCase(
        gh<_i111.AudioDownloadRepository>(),
        gh<_i178.AudioTrackRepository>(),
      ),
    );
    gh.factory<_i181.CheckProfileCompletenessUseCase>(
      () => _i181.CheckProfileCompletenessUseCase(
        gh<_i169.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i182.CreateProjectUseCase>(
      () => _i182.CreateProjectUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.factory<_i183.CreateUserProfileUseCase>(
      () => _i183.CreateUserProfileUseCase(
        gh<_i169.UserProfileRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i184.DeclineInvitationUseCase>(
      () => _i184.DeclineInvitationUseCase(
        invitationRepository: gh<_i88.InvitationRepository>(),
        projectRepository: gh<_i163.ProjectsRepository>(),
        userProfileRepository: gh<_i169.UserProfileRepository>(),
        notificationService: gh<_i38.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i185.DeleteProjectUseCase>(
      () => _i185.DeleteProjectUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i186.FindUserByEmailUseCase>(
      () => _i186.FindUserByEmailUseCase(gh<_i169.UserProfileRepository>()),
    );
    gh.factory<_i187.GetCachedTrackBundlesUseCase>(
      () => _i187.GetCachedTrackBundlesUseCase(
        gh<_i10.CacheMaintenanceService>(),
        gh<_i178.AudioTrackRepository>(),
        gh<_i169.UserProfileRepository>(),
        gh<_i163.ProjectsRepository>(),
        gh<_i111.AudioDownloadRepository>(),
      ),
    );
    gh.lazySingleton<_i188.GetProjectByIdUseCase>(
      () => _i188.GetProjectByIdUseCase(gh<_i163.ProjectsRepository>()),
    );
    gh.lazySingleton<_i189.GoogleSignInUseCase>(
      () => _i189.GoogleSignInUseCase(
        gh<_i118.AuthRepository>(),
        gh<_i169.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i190.JoinProjectWithIdUseCase>(
      () => _i190.JoinProjectWithIdUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i191.LeaveProjectUseCase>(
      () => _i191.LeaveProjectUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.factory<_i192.MagicLinkBloc>(
      () => _i192.MagicLinkBloc(
        generateMagicLink: gh<_i130.GenerateMagicLinkUseCase>(),
        validateMagicLink: gh<_i66.ValidateMagicLinkUseCase>(),
        consumeMagicLink: gh<_i79.ConsumeMagicLinkUseCase>(),
        resendMagicLink: gh<_i51.ResendMagicLinkUseCase>(),
        getMagicLinkStatus: gh<_i84.GetMagicLinkStatusUseCase>(),
        joinProjectWithId: gh<_i190.JoinProjectWithIdUseCase>(),
        authRepository: gh<_i118.AuthRepository>(),
      ),
    );
    gh.factory<_i193.PlayAudioUseCase>(
      () => _i193.PlayAudioUseCase(
        audioTrackRepository: gh<_i178.AudioTrackRepository>(),
        audioStorageRepository: gh<_i113.AudioStorageRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.factory<_i194.PlayPlaylistUseCase>(
      () => _i194.PlayPlaylistUseCase(
        playlistRepository: gh<_i161.PlaylistRepository>(),
        audioTrackRepository: gh<_i178.AudioTrackRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
        audioStorageRepository: gh<_i113.AudioStorageRepository>(),
      ),
    );
    gh.factory<_i195.PlaylistCacheBloc>(
      () => _i195.PlaylistCacheBloc(
        cachePlaylistUseCase: gh<_i180.CachePlaylistUseCase>(),
        getPlaylistCacheStatusUseCase:
            gh<_i135.GetPlaylistCacheStatusUseCase>(),
        removePlaylistCacheUseCase: gh<_i143.RemovePlaylistCacheUseCase>(),
      ),
    );
    gh.lazySingleton<_i196.ProjectCommentService>(
      () => _i196.ProjectCommentService(gh<_i176.AudioCommentRepository>()),
    );
    gh.lazySingleton<_i197.ProjectTrackService>(
      () => _i197.ProjectTrackService(
        gh<_i178.AudioTrackRepository>(),
        gh<_i113.AudioStorageRepository>(),
        gh<_i83.GenerateWaveformUseCase>(),
      ),
    );
    gh.factory<_i198.ProjectsBloc>(
      () => _i198.ProjectsBloc(
        createProject: gh<_i182.CreateProjectUseCase>(),
        updateProject: gh<_i168.UpdateProjectUseCase>(),
        deleteProject: gh<_i185.DeleteProjectUseCase>(),
        watchAllProjects: gh<_i171.WatchAllProjectsUseCase>(),
      ),
    );
    gh.factory<_i199.RestorePlaybackStateUseCase>(
      () => _i199.RestorePlaybackStateUseCase(
        persistenceRepository: gh<_i45.PlaybackPersistenceRepository>(),
        audioTrackRepository: gh<_i178.AudioTrackRepository>(),
        audioStorageRepository: gh<_i113.AudioStorageRepository>(),
        playbackService: gh<_i5.AudioPlaybackService>(),
      ),
    );
    gh.lazySingleton<_i200.SendInvitationUseCase>(
      () => _i200.SendInvitationUseCase(
        invitationRepository: gh<_i88.InvitationRepository>(),
        notificationService: gh<_i38.NotificationService>(),
        findUserByEmail: gh<_i186.FindUserByEmailUseCase>(),
        magicLinkRepository: gh<_i30.MagicLinkRepository>(),
        currentUserService: gh<_i127.CurrentUserService>(),
      ),
    );
    gh.factory<_i201.SessionCleanupService>(
      () => _i201.SessionCleanupService(
        userProfileRepository: gh<_i169.UserProfileRepository>(),
        projectsRepository: gh<_i163.ProjectsRepository>(),
        audioTrackRepository: gh<_i178.AudioTrackRepository>(),
        audioCommentRepository: gh<_i176.AudioCommentRepository>(),
        invitationRepository: gh<_i88.InvitationRepository>(),
        playbackPersistenceRepository: gh<_i45.PlaybackPersistenceRepository>(),
        blocStateCleanupService: gh<_i9.BlocStateCleanupService>(),
        sessionStorage: gh<_i99.SessionStorage>(),
      ),
    );
    gh.factory<_i202.SessionService>(
      () => _i202.SessionService(
        checkAuthUseCase: gh<_i126.CheckAuthenticationStatusUseCase>(),
        getCurrentUserUseCase: gh<_i133.GetCurrentUserUseCase>(),
        onboardingUseCase: gh<_i141.OnboardingUseCase>(),
        profileUseCase: gh<_i181.CheckProfileCompletenessUseCase>(),
      ),
    );
    gh.lazySingleton<_i203.SignInUseCase>(
      () => _i203.SignInUseCase(
        gh<_i118.AuthRepository>(),
        gh<_i169.UserProfileRepository>(),
      ),
    );
    gh.factory<_i204.SyncStatusCubit>(
      () => _i204.SyncStatusCubit(
        gh<_i158.SyncStatusProvider>(),
        gh<_i95.PendingOperationsManager>(),
        gh<_i166.TriggerUpstreamSyncUseCase>(),
      ),
    );
    gh.factory<_i205.UpdateUserProfileUseCase>(
      () => _i205.UpdateUserProfileUseCase(
        gh<_i169.UserProfileRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i206.UploadAudioTrackUseCase>(
      () => _i206.UploadAudioTrackUseCase(
        gh<_i197.ProjectTrackService>(),
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
        gh<_i4.AudioMetadataService>(),
      ),
    );
    gh.factory<_i207.UserProfileBloc>(
      () => _i207.UserProfileBloc(
        updateUserProfileUseCase: gh<_i205.UpdateUserProfileUseCase>(),
        createUserProfileUseCase: gh<_i183.CreateUserProfileUseCase>(),
        watchUserProfileUseCase: gh<_i173.WatchUserProfileUseCase>(),
        checkProfileCompletenessUseCase:
            gh<_i181.CheckProfileCompletenessUseCase>(),
        getCurrentUserUseCase: gh<_i133.GetCurrentUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i208.WatchAudioCommentsBundleUseCase>(
      () => _i208.WatchAudioCommentsBundleUseCase(
        gh<_i178.AudioTrackRepository>(),
        gh<_i176.AudioCommentRepository>(),
        gh<_i104.UserProfileCacheRepository>(),
      ),
    );
    gh.lazySingleton<_i209.WatchProjectDetailUseCase>(
      () => _i209.WatchProjectDetailUseCase(
        gh<_i163.ProjectsRepository>(),
        gh<_i178.AudioTrackRepository>(),
        gh<_i104.UserProfileCacheRepository>(),
      ),
    );
    gh.lazySingleton<_i210.WatchTracksByProjectIdUseCase>(
      () =>
          _i210.WatchTracksByProjectIdUseCase(gh<_i178.AudioTrackRepository>()),
    );
    gh.lazySingleton<_i211.AddAudioCommentUseCase>(
      () => _i211.AddAudioCommentUseCase(
        gh<_i196.ProjectCommentService>(),
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i212.AddCollaboratorByEmailUseCase>(
      () => _i212.AddCollaboratorByEmailUseCase(
        gh<_i186.FindUserByEmailUseCase>(),
        gh<_i175.AddCollaboratorToProjectUseCase>(),
        gh<_i38.NotificationService>(),
      ),
    );
    gh.factory<_i213.AppBootstrap>(
      () => _i213.AppBootstrap(
        sessionService: gh<_i202.SessionService>(),
        performanceCollector: gh<_i44.PerformanceMetricsCollector>(),
        dynamicLinkService: gh<_i16.DynamicLinkService>(),
        databaseHealthMonitor: gh<_i81.DatabaseHealthMonitor>(),
      ),
    );
    gh.factory<_i214.AppFlowBloc>(
      () => _i214.AppFlowBloc(
        appBootstrap: gh<_i213.AppBootstrap>(),
        backgroundSyncCoordinator: gh<_i160.BackgroundSyncCoordinator>(),
        getAuthStateUseCase: gh<_i131.GetAuthStateUseCase>(),
        sessionCleanupService: gh<_i201.SessionCleanupService>(),
      ),
    );
    gh.lazySingleton<_i215.AudioContextService>(
      () => _i216.AudioContextServiceImpl(
        userProfileRepository: gh<_i169.UserProfileRepository>(),
        audioTrackRepository: gh<_i178.AudioTrackRepository>(),
        projectsRepository: gh<_i163.ProjectsRepository>(),
      ),
    );
    gh.factory<_i217.AudioPlayerService>(
      () => _i217.AudioPlayerService(
        initializeAudioPlayerUseCase: gh<_i24.InitializeAudioPlayerUseCase>(),
        playAudioUseCase: gh<_i193.PlayAudioUseCase>(),
        playPlaylistUseCase: gh<_i194.PlayPlaylistUseCase>(),
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
    gh.factory<_i218.AuthBloc>(
      () => _i218.AuthBloc(
        signIn: gh<_i203.SignInUseCase>(),
        signUp: gh<_i146.SignUpUseCase>(),
        googleSignIn: gh<_i189.GoogleSignInUseCase>(),
        appleSignIn: gh<_i152.AppleSignInUseCase>(),
        signOut: gh<_i145.SignOutUseCase>(),
      ),
    );
    gh.factory<_i219.CacheManagementBloc>(
      () => _i219.CacheManagementBloc(
        getBundles: gh<_i187.GetCachedTrackBundlesUseCase>(),
        deleteOne: gh<_i128.DeleteCachedAudioUseCase>(),
        deleteMany: gh<_i129.DeleteMultipleCachedAudiosUseCase>(),
        watchUsage: gh<_i150.WatchStorageUsageUseCase>(),
        getStats: gh<_i21.GetCacheStorageStatsUseCase>(),
        cleanup: gh<_i12.CleanupCacheUseCase>(),
      ),
    );
    gh.lazySingleton<_i220.DeleteAudioCommentUseCase>(
      () => _i220.DeleteAudioCommentUseCase(
        gh<_i196.ProjectCommentService>(),
        gh<_i163.ProjectsRepository>(),
        gh<_i99.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i221.DeleteAudioTrack>(
      () => _i221.DeleteAudioTrack(
        gh<_i99.SessionStorage>(),
        gh<_i163.ProjectsRepository>(),
        gh<_i197.ProjectTrackService>(),
      ),
    );
    gh.lazySingleton<_i222.EditAudioTrackUseCase>(
      () => _i222.EditAudioTrackUseCase(
        gh<_i197.ProjectTrackService>(),
        gh<_i163.ProjectsRepository>(),
      ),
    );
    gh.factory<_i223.LoadTrackContextUseCase>(
      () => _i223.LoadTrackContextUseCase(gh<_i215.AudioContextService>()),
    );
    gh.factory<_i224.ManageCollaboratorsBloc>(
      () => _i224.ManageCollaboratorsBloc(
        removeCollaboratorUseCase: gh<_i165.RemoveCollaboratorUseCase>(),
        updateCollaboratorRoleUseCase:
            gh<_i167.UpdateCollaboratorRoleUseCase>(),
        leaveProjectUseCase: gh<_i191.LeaveProjectUseCase>(),
        findUserByEmailUseCase: gh<_i186.FindUserByEmailUseCase>(),
        addCollaboratorByEmailUseCase:
            gh<_i212.AddCollaboratorByEmailUseCase>(),
        watchCollaboratorsBundleUseCase:
            gh<_i172.WatchCollaboratorsBundleUseCase>(),
      ),
    );
    gh.factory<_i225.ProjectDetailBloc>(
      () => _i225.ProjectDetailBloc(
        watchProjectDetail: gh<_i209.WatchProjectDetailUseCase>(),
      ),
    );
    gh.factory<_i226.ProjectInvitationActorBloc>(
      () => _i226.ProjectInvitationActorBloc(
        sendInvitationUseCase: gh<_i200.SendInvitationUseCase>(),
        acceptInvitationUseCase: gh<_i174.AcceptInvitationUseCase>(),
        declineInvitationUseCase: gh<_i184.DeclineInvitationUseCase>(),
        cancelInvitationUseCase: gh<_i125.CancelInvitationUseCase>(),
        findUserByEmailUseCase: gh<_i186.FindUserByEmailUseCase>(),
      ),
    );
    gh.factory<_i227.AudioCommentBloc>(
      () => _i227.AudioCommentBloc(
        addAudioCommentUseCase: gh<_i211.AddAudioCommentUseCase>(),
        deleteAudioCommentUseCase: gh<_i220.DeleteAudioCommentUseCase>(),
        watchAudioCommentsBundleUseCase:
            gh<_i208.WatchAudioCommentsBundleUseCase>(),
      ),
    );
    gh.factory<_i228.AudioContextBloc>(
      () => _i228.AudioContextBloc(
        loadTrackContextUseCase: gh<_i223.LoadTrackContextUseCase>(),
      ),
    );
    gh.factory<_i229.AudioPlayerBloc>(
      () => _i229.AudioPlayerBloc(
        audioPlayerService: gh<_i217.AudioPlayerService>(),
      ),
    );
    gh.factory<_i230.AudioTrackBloc>(
      () => _i230.AudioTrackBloc(
        watchAudioTracksByProject: gh<_i210.WatchTracksByProjectIdUseCase>(),
        deleteAudioTrack: gh<_i221.DeleteAudioTrack>(),
        uploadAudioTrackUseCase: gh<_i206.UploadAudioTrackUseCase>(),
        editAudioTrackUseCase: gh<_i222.EditAudioTrackUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i231.AppModule {}
