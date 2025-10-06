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
import 'package:shared_preferences/shared_preferences.dart' as _i53;
import 'package:trackflow/core/app/services/audio_background_initializer.dart'
    as _i3;
import 'package:trackflow/core/app_flow/data/session_storage.dart' as _i105;
import 'package:trackflow/core/app_flow/docs/bloc_cleanup_examples.dart'
    as _i13;
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart'
    as _i8;
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart'
    as _i205;
import 'package:trackflow/core/app_flow/domain/services/session_service.dart'
    as _i206;
import 'package:trackflow/core/app_flow/domain/usecases/check_authentication_status_usecase.dart'
    as _i128;
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart'
    as _i132;
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart'
    as _i134;
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart'
    as _i224;
import 'package:trackflow/core/di/app_module.dart' as _i243;
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
    as _i78;
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i79;
import 'package:trackflow/core/notifications/domain/usecases/get_unread_notifications_count_usecase.dart'
    as _i81;
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i136;
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart'
    as _i97;
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i98;
import 'package:trackflow/core/notifications/domain/usecases/observe_notifications_usecase.dart'
    as _i36;
import 'package:trackflow/core/notifications/presentation/blocs/actor/notification_actor_bloc.dart'
    as _i137;
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart'
    as _i138;
import 'package:trackflow/core/services/deep_link_service.dart' as _i10;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i12;
import 'package:trackflow/core/session/current_user_service.dart' as _i129;
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart'
    as _i39;
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart'
    as _i40;
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart'
    as _i115;
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart'
    as _i120;
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart'
    as _i37;
import 'package:trackflow/core/sync/domain/executors/playlist_operation_executor.dart'
    as _i103;
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart'
    as _i104;
import 'package:trackflow/core/sync/domain/executors/track_version_operation_executor.dart'
    as _i107;
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart'
    as _i111;
import 'package:trackflow/core/sync/domain/executors/waveform_operation_executor.dart'
    as _i114;
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart'
    as _i124;
import 'package:trackflow/core/sync/domain/services/conflict_resolution_service.dart'
    as _i7;
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart'
    as _i18;
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart'
    as _i102;
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart'
    as _i57;
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart'
    as _i106;
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart'
    as _i211;
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart'
    as _i154;
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart'
    as _i209;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as _i75;
import 'package:trackflow/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart'
    as _i76;
import 'package:trackflow/features/audio_cache/data/repositories/audio_download_repository_impl.dart'
    as _i117;
import 'package:trackflow/features/audio_cache/data/repositories/audio_storage_repository_impl.dart'
    as _i119;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart'
    as _i116;
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart'
    as _i118;
import 'package:trackflow/features/audio_cache/domain/usecases/cache_track_usecase.dart'
    as _i126;
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_track_path_usecase.dart'
    as _i133;
import 'package:trackflow/features/audio_cache/domain/usecases/remove_track_cache_usecase.dart'
    as _i148;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cache_status.dart'
    as _i163;
import 'package:trackflow/features/audio_cache/domain/usecases/watch_cached_audios_usecase.dart'
    as _i160;
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart'
    as _i210;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i71;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i72;
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart'
    as _i83;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i172;
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart'
    as _i84;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i171;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i200;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i221;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i229;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart'
    as _i214;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i240;
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart'
    as _i195;
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart'
    as _i225;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i5;
import 'package:trackflow/features/audio_player/domain/services/audio_player_service.dart'
    as _i226;
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart'
    as _i173;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i198;
import 'package:trackflow/features/audio_player/domain/usecases/play_version_usecase.dart'
    as _i199;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i203;
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
    as _i174;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i241;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart'
    as _i92;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i176;
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart'
    as _i93;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i175;
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart'
    as _i4;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i201;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i230;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i232;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i239;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i219;
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart'
    as _i112;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i242;
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart'
    as _i151;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i121;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i123;
import 'package:trackflow/features/auth/data/services/apple_auth_service.dart'
    as _i70;
import 'package:trackflow/features/auth/data/services/google_auth_service.dart'
    as _i82;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i122;
import 'package:trackflow/features/auth/domain/usecases/apple_sign_in_usecase.dart'
    as _i170;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i192;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i208;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i149;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i150;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i227;
import 'package:trackflow/features/cache_management/data/datasources/cache_management_local_data_source.dart'
    as _i125;
import 'package:trackflow/features/cache_management/data/services/cache_maintenance_service_impl.dart'
    as _i178;
import 'package:trackflow/features/cache_management/domain/services/cache_maintenance_service.dart'
    as _i177;
import 'package:trackflow/features/cache_management/domain/usecases/cleanup_cache_usecase.dart'
    as _i180;
import 'package:trackflow/features/cache_management/domain/usecases/delete_cached_audio_usecase.dart'
    as _i130;
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i188;
import 'package:trackflow/features/cache_management/domain/usecases/watch_cached_track_bundles_usecase.dart'
    as _i215;
import 'package:trackflow/features/cache_management/domain/usecases/watch_storage_usage_usecase.dart'
    as _i162;
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart'
    as _i228;
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart'
    as _i94;
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart'
    as _i23;
import 'package:trackflow/features/invitations/data/repositories/invitation_repository_impl.dart'
    as _i96;
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart'
    as _i95;
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart'
    as _i168;
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart'
    as _i127;
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart'
    as _i183;
import 'package:trackflow/features/invitations/domain/usecases/get_pending_invitations_count_usecase.dart'
    as _i135;
import 'package:trackflow/features/invitations/domain/usecases/observe_pending_invitations_usecase.dart'
    as _i99;
import 'package:trackflow/features/invitations/domain/usecases/observe_sent_invitations_usecase.dart'
    as _i100;
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart'
    as _i204;
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart'
    as _i236;
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart'
    as _i144;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i25;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i26;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i28;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i77;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i131;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i80;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i47;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i65;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i196;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart'
    as _i222;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i169;
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart'
    as _i185;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i193;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i194;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i147;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i155;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_collaborators_bundle_usecase.dart'
    as _i161;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i233;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i29;
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart'
    as _i20;
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart'
    as _i101;
import 'package:trackflow/features/onboarding/data/repository/onboarding_repository_impl.dart'
    as _i140;
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart'
    as _i141;
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart'
    as _i139;
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i197;
import 'package:trackflow/features/playlist/data/datasources/playlist_local_data_source.dart'
    as _i43;
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart'
    as _i44;
import 'package:trackflow/features/playlist/data/repositories/playlist_repository_impl.dart'
    as _i143;
import 'package:trackflow/features/playlist/domain/repositories/playlist_repository.dart'
    as _i142;
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart'
    as _i217;
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart'
    as _i234;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart'
    as _i216;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i235;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i46;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i45;
import 'package:trackflow/features/projects/data/models/project_dto.dart'
    as _i88;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i146;
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i145;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i181;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i231;
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart'
    as _i189;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i156;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i159;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i237;
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart'
    as _i61;
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart'
    as _i62;
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart'
    as _i86;
import 'package:trackflow/features/track_version/data/repositories/track_version_repository_impl.dart'
    as _i153;
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart'
    as _i87;
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart'
    as _i152;
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart'
    as _i223;
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart'
    as _i184;
import 'package:trackflow/features/track_version/domain/usecases/get_active_version_usecase.dart'
    as _i187;
import 'package:trackflow/features/track_version/domain/usecases/get_version_by_id_usecase.dart'
    as _i190;
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart'
    as _i202;
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart'
    as _i207;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart'
    as _i218;
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart'
    as _i164;
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart'
    as _i238;
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart'
    as _i60;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i63;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i64;
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart'
    as _i90;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_cache_repository_impl.dart'
    as _i109;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i158;
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart'
    as _i110;
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart'
    as _i91;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i157;
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart'
    as _i108;
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart'
    as _i179;
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart'
    as _i182;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i212;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i165;
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart'
    as _i113;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i213;
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart'
    as _i68;
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart'
    as _i69;
import 'package:trackflow/features/waveform/data/repositories/waveform_repository_impl.dart'
    as _i167;
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart'
    as _i67;
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart'
    as _i85;
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart'
    as _i166;
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart'
    as _i66;
import 'package:trackflow/features/waveform/domain/usecases/generate_and_store_waveform.dart'
    as _i186;
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart'
    as _i191;
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart'
    as _i220;

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
    gh.lazySingleton<_i47.ResendMagicLinkUseCase>(
        () => _i47.ResendMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
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
    gh.lazySingleton<_i57.SyncCoordinator>(
        () => _i57.SyncCoordinator(gh<_i53.SharedPreferences>()));
    gh.factory<_i58.ToggleRepeatModeUseCase>(() => _i58.ToggleRepeatModeUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i59.ToggleShuffleUseCase>(() => _i59.ToggleShuffleUseCase(
        playbackService: gh<_i5.AudioPlaybackService>()));
    gh.factory<_i60.TrackDetailCubit>(() => _i60.TrackDetailCubit());
    gh.lazySingleton<_i61.TrackVersionLocalDataSource>(
        () => _i61.IsarTrackVersionLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i62.TrackVersionRemoteDataSource>(
        () => _i62.TrackVersionRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i63.UserProfileLocalDataSource>(
        () => _i63.IsarUserProfileLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i64.UserProfileRemoteDataSource>(
        () => _i64.UserProfileRemoteDataSourceImpl(
              gh<_i15.FirebaseFirestore>(),
              gh<_i16.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i65.ValidateMagicLinkUseCase>(
        () => _i65.ValidateMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i66.WaveformGeneratorService>(() =>
        _i67.JustWaveformGeneratorService(cacheDir: gh<_i11.Directory>()));
    gh.factory<_i68.WaveformLocalDataSource>(
        () => _i68.WaveformLocalDataSourceImpl(isar: gh<_i24.Isar>()));
    gh.lazySingleton<_i69.WaveformRemoteDataSource>(() =>
        _i69.FirebaseStorageWaveformRemoteDataSource(
            gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i70.AppleAuthService>(
        () => _i70.AppleAuthService(gh<_i14.FirebaseAuth>()));
    gh.lazySingleton<_i71.AudioCommentLocalDataSource>(
        () => _i71.IsarAudioCommentLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i72.AudioCommentRemoteDataSource>(() =>
        _i72.FirebaseAudioCommentRemoteDataSource(
            gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i73.AudioTrackLocalDataSource>(
        () => _i73.IsarAudioTrackLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i74.AudioTrackRemoteDataSource>(() =>
        _i74.AudioTrackRemoteDataSourceImpl(gh<_i15.FirebaseFirestore>()));
    gh.lazySingleton<_i75.CacheStorageLocalDataSource>(
        () => _i75.CacheStorageLocalDataSourceImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i76.CacheStorageRemoteDataSource>(() =>
        _i76.CacheStorageRemoteDataSourceImpl(gh<_i16.FirebaseStorage>()));
    gh.lazySingleton<_i77.ConsumeMagicLinkUseCase>(
        () => _i77.ConsumeMagicLinkUseCase(gh<_i27.MagicLinkRepository>()));
    gh.factory<_i78.CreateNotificationUseCase>(() =>
        _i78.CreateNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.factory<_i79.DeleteNotificationUseCase>(() =>
        _i79.DeleteNotificationUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i80.GetMagicLinkStatusUseCase>(
        () => _i80.GetMagicLinkStatusUseCase(gh<_i27.MagicLinkRepository>()));
    gh.lazySingleton<_i81.GetUnreadNotificationsCountUseCase>(() =>
        _i81.GetUnreadNotificationsCountUseCase(
            gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i82.GoogleAuthService>(() => _i82.GoogleAuthService(
          gh<_i17.GoogleSignIn>(),
          gh<_i14.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i83.AudioCommentDTO>>(
        () => _i84.AudioCommentIncrementalSyncService(
              gh<_i72.AudioCommentRemoteDataSource>(),
              gh<_i71.AudioCommentLocalDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<dynamic>>(
        () => _i85.WaveformIncrementalSyncService(
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i68.WaveformLocalDataSource>(),
              gh<_i69.WaveformRemoteDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i86.TrackVersionDTO>>(
        () => _i87.TrackVersionIncrementalSyncService(
              gh<_i62.TrackVersionRemoteDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i73.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i88.ProjectDTO>>(
        () => _i89.ProjectIncrementalSyncService(
              gh<_i45.ProjectRemoteDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i90.UserProfileDTO>>(
        () => _i91.UserProfileIncrementalSyncService(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
            ));
    gh.lazySingleton<_i18.IncrementalSyncService<_i92.AudioTrackDTO>>(
        () => _i93.AudioTrackIncrementalSyncService(
              gh<_i74.AudioTrackRemoteDataSource>(),
              gh<_i73.AudioTrackLocalDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.lazySingleton<_i94.InvitationLocalDataSource>(
        () => _i94.IsarInvitationLocalDataSource(gh<_i24.Isar>()));
    gh.lazySingleton<_i95.InvitationRepository>(
        () => _i96.InvitationRepositoryImpl(
              localDataSource: gh<_i94.InvitationLocalDataSource>(),
              remoteDataSource: gh<_i23.InvitationRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
            ));
    gh.factory<_i97.MarkAsUnreadUseCase>(
        () => _i97.MarkAsUnreadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i98.MarkNotificationAsReadUseCase>(() =>
        _i98.MarkNotificationAsReadUseCase(gh<_i33.NotificationRepository>()));
    gh.lazySingleton<_i99.ObservePendingInvitationsUseCase>(() =>
        _i99.ObservePendingInvitationsUseCase(gh<_i95.InvitationRepository>()));
    gh.lazySingleton<_i100.ObserveSentInvitationsUseCase>(() =>
        _i100.ObserveSentInvitationsUseCase(gh<_i95.InvitationRepository>()));
    gh.lazySingleton<_i101.OnboardingStateLocalDataSource>(() =>
        _i101.OnboardingStateLocalDataSourceImpl(gh<_i53.SharedPreferences>()));
    gh.lazySingleton<_i102.PendingOperationsManager>(
        () => _i102.PendingOperationsManager(
              gh<_i40.PendingOperationsRepository>(),
              gh<_i30.NetworkStateManager>(),
              gh<_i37.OperationExecutorFactory>(),
            ));
    gh.factory<_i103.PlaylistOperationExecutor>(() =>
        _i103.PlaylistOperationExecutor(gh<_i44.PlaylistRemoteDataSource>()));
    gh.factory<_i104.ProjectOperationExecutor>(() =>
        _i104.ProjectOperationExecutor(gh<_i45.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i105.SessionStorage>(
        () => _i105.SessionStorageImpl(prefs: gh<_i53.SharedPreferences>()));
    gh.factory<_i106.SyncStatusProvider>(() => _i106.SyncStatusProvider(
          syncCoordinator: gh<_i57.SyncCoordinator>(),
          pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
        ));
    gh.factory<_i107.TrackVersionOperationExecutor>(
        () => _i107.TrackVersionOperationExecutor(
              gh<_i62.TrackVersionRemoteDataSource>(),
              gh<_i61.TrackVersionLocalDataSource>(),
            ));
    gh.lazySingleton<_i108.UserProfileCacheRepository>(
        () => _i109.UserProfileCacheRepositoryImpl(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i30.NetworkStateManager>(),
            ));
    gh.lazySingleton<_i110.UserProfileCollaboratorIncrementalSyncService>(
        () => _i110.UserProfileCollaboratorIncrementalSyncService(
              gh<_i64.UserProfileRemoteDataSource>(),
              gh<_i63.UserProfileLocalDataSource>(),
              gh<_i46.ProjectsLocalDataSource>(),
            ));
    gh.factory<_i111.UserProfileOperationExecutor>(() =>
        _i111.UserProfileOperationExecutor(
            gh<_i64.UserProfileRemoteDataSource>()));
    gh.lazySingleton<_i112.WatchTrackUploadStatusUseCase>(() =>
        _i112.WatchTrackUploadStatusUseCase(
            gh<_i102.PendingOperationsManager>()));
    gh.lazySingleton<_i113.WatchUserProfilesUseCase>(() =>
        _i113.WatchUserProfilesUseCase(gh<_i108.UserProfileCacheRepository>()));
    gh.factory<_i114.WaveformOperationExecutor>(() =>
        _i114.WaveformOperationExecutor(gh<_i69.WaveformRemoteDataSource>()));
    gh.factory<_i115.AudioCommentOperationExecutor>(() =>
        _i115.AudioCommentOperationExecutor(
            gh<_i72.AudioCommentRemoteDataSource>()));
    gh.lazySingleton<_i116.AudioDownloadRepository>(
        () => _i117.AudioDownloadRepositoryImpl(
              remoteDataSource: gh<_i76.CacheStorageRemoteDataSource>(),
              localDataSource: gh<_i75.CacheStorageLocalDataSource>(),
            ));
    gh.lazySingleton<_i118.AudioStorageRepository>(() =>
        _i119.AudioStorageRepositoryImpl(
            localDataSource: gh<_i75.CacheStorageLocalDataSource>()));
    gh.factory<_i120.AudioTrackOperationExecutor>(
        () => _i120.AudioTrackOperationExecutor(
              gh<_i74.AudioTrackRemoteDataSource>(),
              gh<_i73.AudioTrackLocalDataSource>(),
            ));
    gh.lazySingleton<_i121.AuthRemoteDataSource>(
        () => _i121.AuthRemoteDataSourceImpl(
              gh<_i14.FirebaseAuth>(),
              gh<_i82.GoogleAuthService>(),
            ));
    gh.lazySingleton<_i122.AuthRepository>(() => _i123.AuthRepositoryImpl(
          remote: gh<_i121.AuthRemoteDataSource>(),
          sessionStorage: gh<_i105.SessionStorage>(),
          networkStateManager: gh<_i30.NetworkStateManager>(),
          googleAuthService: gh<_i82.GoogleAuthService>(),
          appleAuthService: gh<_i70.AppleAuthService>(),
        ));
    gh.lazySingleton<_i124.BackgroundSyncCoordinator>(
        () => _i124.BackgroundSyncCoordinator(
              gh<_i30.NetworkStateManager>(),
              gh<_i57.SyncCoordinator>(),
              gh<_i102.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i125.CacheManagementLocalDataSource>(() =>
        _i125.CacheManagementLocalDataSourceImpl(
            local: gh<_i75.CacheStorageLocalDataSource>()));
    gh.factory<_i126.CacheTrackUseCase>(() => _i126.CacheTrackUseCase(
          gh<_i116.AudioDownloadRepository>(),
          gh<_i118.AudioStorageRepository>(),
        ));
    gh.lazySingleton<_i127.CancelInvitationUseCase>(
        () => _i127.CancelInvitationUseCase(gh<_i95.InvitationRepository>()));
    gh.factory<_i128.CheckAuthenticationStatusUseCase>(() =>
        _i128.CheckAuthenticationStatusUseCase(gh<_i122.AuthRepository>()));
    gh.factory<_i129.CurrentUserService>(
        () => _i129.CurrentUserService(gh<_i105.SessionStorage>()));
    gh.factory<_i130.DeleteCachedAudioUseCase>(() =>
        _i130.DeleteCachedAudioUseCase(gh<_i118.AudioStorageRepository>()));
    gh.lazySingleton<_i131.GenerateMagicLinkUseCase>(
        () => _i131.GenerateMagicLinkUseCase(
              gh<_i27.MagicLinkRepository>(),
              gh<_i122.AuthRepository>(),
            ));
    gh.lazySingleton<_i132.GetAuthStateUseCase>(
        () => _i132.GetAuthStateUseCase(gh<_i122.AuthRepository>()));
    gh.factory<_i133.GetCachedTrackPathUseCase>(() =>
        _i133.GetCachedTrackPathUseCase(gh<_i118.AudioStorageRepository>()));
    gh.factory<_i134.GetCurrentUserUseCase>(
        () => _i134.GetCurrentUserUseCase(gh<_i122.AuthRepository>()));
    gh.lazySingleton<_i135.GetPendingInvitationsCountUseCase>(() =>
        _i135.GetPendingInvitationsCountUseCase(
            gh<_i95.InvitationRepository>()));
    gh.factory<_i136.MarkAllNotificationsAsReadUseCase>(
        () => _i136.MarkAllNotificationsAsReadUseCase(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i129.CurrentUserService>(),
            ));
    gh.factory<_i137.NotificationActorBloc>(() => _i137.NotificationActorBloc(
          createNotificationUseCase: gh<_i78.CreateNotificationUseCase>(),
          markAsReadUseCase: gh<_i98.MarkNotificationAsReadUseCase>(),
          markAsUnreadUseCase: gh<_i97.MarkAsUnreadUseCase>(),
          markAllAsReadUseCase: gh<_i136.MarkAllNotificationsAsReadUseCase>(),
          deleteNotificationUseCase: gh<_i79.DeleteNotificationUseCase>(),
        ));
    gh.factory<_i138.NotificationWatcherBloc>(
        () => _i138.NotificationWatcherBloc(
              notificationRepository: gh<_i33.NotificationRepository>(),
              currentUserService: gh<_i129.CurrentUserService>(),
            ));
    gh.lazySingleton<_i139.OnboardingRepository>(() =>
        _i140.OnboardingRepositoryImpl(
            gh<_i101.OnboardingStateLocalDataSource>()));
    gh.lazySingleton<_i141.OnboardingUseCase>(
        () => _i141.OnboardingUseCase(gh<_i139.OnboardingRepository>()));
    gh.lazySingleton<_i142.PlaylistRepository>(
        () => _i143.PlaylistRepositoryImpl(
              localDataSource: gh<_i43.PlaylistLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i124.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
            ));
    gh.factory<_i144.ProjectInvitationWatcherBloc>(
        () => _i144.ProjectInvitationWatcherBloc(
              invitationRepository: gh<_i95.InvitationRepository>(),
              currentUserService: gh<_i129.CurrentUserService>(),
            ));
    gh.lazySingleton<_i145.ProjectsRepository>(
        () => _i146.ProjectsRepositoryImpl(
              localDataSource: gh<_i46.ProjectsLocalDataSource>(),
              backgroundSyncCoordinator: gh<_i124.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i147.RemoveCollaboratorUseCase>(
        () => _i147.RemoveCollaboratorUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.factory<_i148.RemoveTrackCacheUseCase>(() =>
        _i148.RemoveTrackCacheUseCase(gh<_i118.AudioStorageRepository>()));
    gh.lazySingleton<_i149.SignOutUseCase>(
        () => _i149.SignOutUseCase(gh<_i122.AuthRepository>()));
    gh.lazySingleton<_i150.SignUpUseCase>(
        () => _i150.SignUpUseCase(gh<_i122.AuthRepository>()));
    gh.factory<_i151.TrackUploadStatusCubit>(() => _i151.TrackUploadStatusCubit(
        gh<_i112.WatchTrackUploadStatusUseCase>()));
    gh.lazySingleton<_i152.TrackVersionRepository>(
        () => _i153.TrackVersionRepositoryImpl(
              gh<_i61.TrackVersionLocalDataSource>(),
              gh<_i124.BackgroundSyncCoordinator>(),
              gh<_i102.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i154.TriggerUpstreamSyncUseCase>(() =>
        _i154.TriggerUpstreamSyncUseCase(
            gh<_i124.BackgroundSyncCoordinator>()));
    gh.lazySingleton<_i155.UpdateCollaboratorRoleUseCase>(
        () => _i155.UpdateCollaboratorRoleUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i156.UpdateProjectUseCase>(
        () => _i156.UpdateProjectUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i157.UserProfileRepository>(
        () => _i158.UserProfileRepositoryImpl(
              localDataSource: gh<_i63.UserProfileLocalDataSource>(),
              remoteDataSource: gh<_i64.UserProfileRemoteDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i124.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
              firestore: gh<_i15.FirebaseFirestore>(),
              sessionStorage: gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i159.WatchAllProjectsUseCase>(
        () => _i159.WatchAllProjectsUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.factory<_i160.WatchCachedAudiosUseCase>(() =>
        _i160.WatchCachedAudiosUseCase(gh<_i118.AudioStorageRepository>()));
    gh.lazySingleton<_i161.WatchCollaboratorsBundleUseCase>(
        () => _i161.WatchCollaboratorsBundleUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i113.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i162.WatchStorageUsageUseCase>(() =>
        _i162.WatchStorageUsageUseCase(gh<_i118.AudioStorageRepository>()));
    gh.factory<_i163.WatchTrackCacheStatusUseCase>(() =>
        _i163.WatchTrackCacheStatusUseCase(gh<_i118.AudioStorageRepository>()));
    gh.lazySingleton<_i164.WatchTrackVersionsUseCase>(() =>
        _i164.WatchTrackVersionsUseCase(gh<_i152.TrackVersionRepository>()));
    gh.lazySingleton<_i165.WatchUserProfileUseCase>(
        () => _i165.WatchUserProfileUseCase(
              gh<_i157.UserProfileRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.factory<_i166.WaveformRepository>(() => _i167.WaveformRepositoryImpl(
          localDataSource: gh<_i68.WaveformLocalDataSource>(),
          remoteDataSource: gh<_i69.WaveformRemoteDataSource>(),
          backgroundSyncCoordinator: gh<_i124.BackgroundSyncCoordinator>(),
          pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
        ));
    gh.lazySingleton<_i168.AcceptInvitationUseCase>(
        () => _i168.AcceptInvitationUseCase(
              invitationRepository: gh<_i95.InvitationRepository>(),
              projectRepository: gh<_i145.ProjectsRepository>(),
              userProfileRepository: gh<_i157.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i169.AddCollaboratorToProjectUseCase>(
        () => _i169.AddCollaboratorToProjectUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i170.AppleSignInUseCase>(
        () => _i170.AppleSignInUseCase(gh<_i122.AuthRepository>()));
    gh.lazySingleton<_i171.AudioCommentRepository>(
        () => _i172.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i72.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i71.AudioCommentLocalDataSource>(),
              networkStateManager: gh<_i30.NetworkStateManager>(),
              backgroundSyncCoordinator: gh<_i124.BackgroundSyncCoordinator>(),
              pendingOperationsManager: gh<_i102.PendingOperationsManager>(),
              trackVersionRepository: gh<_i152.TrackVersionRepository>(),
            ));
    gh.factory<_i173.AudioSourceResolver>(() => _i174.AudioSourceResolverImpl(
          gh<_i118.AudioStorageRepository>(),
          gh<_i116.AudioDownloadRepository>(),
        ));
    gh.lazySingleton<_i175.AudioTrackRepository>(
        () => _i176.AudioTrackRepositoryImpl(
              gh<_i73.AudioTrackLocalDataSource>(),
              gh<_i124.BackgroundSyncCoordinator>(),
              gh<_i102.PendingOperationsManager>(),
            ));
    gh.lazySingleton<_i177.CacheMaintenanceService>(() =>
        _i178.CacheMaintenanceServiceImpl(
            gh<_i125.CacheManagementLocalDataSource>()));
    gh.factory<_i179.CheckProfileCompletenessUseCase>(() =>
        _i179.CheckProfileCompletenessUseCase(
            gh<_i157.UserProfileRepository>()));
    gh.factory<_i180.CleanupCacheUseCase>(
        () => _i180.CleanupCacheUseCase(gh<_i177.CacheMaintenanceService>()));
    gh.lazySingleton<_i181.CreateProjectUseCase>(
        () => _i181.CreateProjectUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.factory<_i182.CreateUserProfileUseCase>(
        () => _i182.CreateUserProfileUseCase(
              gh<_i157.UserProfileRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i183.DeclineInvitationUseCase>(
        () => _i183.DeclineInvitationUseCase(
              invitationRepository: gh<_i95.InvitationRepository>(),
              projectRepository: gh<_i145.ProjectsRepository>(),
              userProfileRepository: gh<_i157.UserProfileRepository>(),
              notificationService: gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i184.DeleteTrackVersionUseCase>(
        () => _i184.DeleteTrackVersionUseCase(
              gh<_i152.TrackVersionRepository>(),
              gh<_i166.WaveformRepository>(),
              gh<_i171.AudioCommentRepository>(),
              gh<_i118.AudioStorageRepository>(),
            ));
    gh.lazySingleton<_i185.FindUserByEmailUseCase>(
        () => _i185.FindUserByEmailUseCase(gh<_i157.UserProfileRepository>()));
    gh.factory<_i186.GenerateAndStoreWaveform>(
        () => _i186.GenerateAndStoreWaveform(
              gh<_i166.WaveformRepository>(),
              gh<_i66.WaveformGeneratorService>(),
            ));
    gh.lazySingleton<_i187.GetActiveVersionUseCase>(() =>
        _i187.GetActiveVersionUseCase(gh<_i152.TrackVersionRepository>()));
    gh.factory<_i188.GetCacheStorageStatsUseCase>(() =>
        _i188.GetCacheStorageStatsUseCase(gh<_i177.CacheMaintenanceService>()));
    gh.lazySingleton<_i189.GetProjectByIdUseCase>(
        () => _i189.GetProjectByIdUseCase(gh<_i145.ProjectsRepository>()));
    gh.lazySingleton<_i190.GetVersionByIdUseCase>(
        () => _i190.GetVersionByIdUseCase(gh<_i152.TrackVersionRepository>()));
    gh.factory<_i191.GetWaveformByVersion>(
        () => _i191.GetWaveformByVersion(gh<_i166.WaveformRepository>()));
    gh.lazySingleton<_i192.GoogleSignInUseCase>(() => _i192.GoogleSignInUseCase(
          gh<_i122.AuthRepository>(),
          gh<_i157.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i193.JoinProjectWithIdUseCase>(
        () => _i193.JoinProjectWithIdUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i194.LeaveProjectUseCase>(() => _i194.LeaveProjectUseCase(
          gh<_i145.ProjectsRepository>(),
          gh<_i105.SessionStorage>(),
        ));
    gh.factory<_i195.LoadTrackContextUseCase>(
        () => _i195.LoadTrackContextUseCase(
              audioTrackRepository: gh<_i175.AudioTrackRepository>(),
              trackVersionRepository: gh<_i152.TrackVersionRepository>(),
              userProfileRepository: gh<_i157.UserProfileRepository>(),
              projectsRepository: gh<_i145.ProjectsRepository>(),
            ));
    gh.factory<_i196.MagicLinkBloc>(() => _i196.MagicLinkBloc(
          generateMagicLink: gh<_i131.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i65.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i77.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i47.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i80.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i193.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i122.AuthRepository>(),
        ));
    gh.factory<_i197.OnboardingBloc>(() => _i197.OnboardingBloc(
          onboardingUseCase: gh<_i141.OnboardingUseCase>(),
          getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i198.PlayPlaylistUseCase>(() => _i198.PlayPlaylistUseCase(
          playlistRepository: gh<_i142.PlaylistRepository>(),
          audioTrackRepository: gh<_i175.AudioTrackRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
          audioStorageRepository: gh<_i118.AudioStorageRepository>(),
        ));
    gh.factory<_i199.PlayVersionUseCase>(() => _i199.PlayVersionUseCase(
          audioTrackRepository: gh<_i175.AudioTrackRepository>(),
          audioStorageRepository: gh<_i118.AudioStorageRepository>(),
          trackVersionRepository: gh<_i152.TrackVersionRepository>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i200.ProjectCommentService>(
        () => _i200.ProjectCommentService(gh<_i171.AudioCommentRepository>()));
    gh.lazySingleton<_i201.ProjectTrackService>(
        () => _i201.ProjectTrackService(gh<_i175.AudioTrackRepository>()));
    gh.lazySingleton<_i202.RenameTrackVersionUseCase>(() =>
        _i202.RenameTrackVersionUseCase(gh<_i152.TrackVersionRepository>()));
    gh.factory<_i203.RestorePlaybackStateUseCase>(
        () => _i203.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i41.PlaybackPersistenceRepository>(),
              audioTrackRepository: gh<_i175.AudioTrackRepository>(),
              audioStorageRepository: gh<_i118.AudioStorageRepository>(),
              playbackService: gh<_i5.AudioPlaybackService>(),
            ));
    gh.lazySingleton<_i204.SendInvitationUseCase>(
        () => _i204.SendInvitationUseCase(
              invitationRepository: gh<_i95.InvitationRepository>(),
              notificationService: gh<_i35.NotificationService>(),
              findUserByEmail: gh<_i185.FindUserByEmailUseCase>(),
              magicLinkRepository: gh<_i27.MagicLinkRepository>(),
              currentUserService: gh<_i129.CurrentUserService>(),
            ));
    gh.factory<_i205.SessionCleanupService>(() => _i205.SessionCleanupService(
          userProfileRepository: gh<_i157.UserProfileRepository>(),
          projectsRepository: gh<_i145.ProjectsRepository>(),
          audioTrackRepository: gh<_i175.AudioTrackRepository>(),
          audioCommentRepository: gh<_i171.AudioCommentRepository>(),
          invitationRepository: gh<_i95.InvitationRepository>(),
          playbackPersistenceRepository:
              gh<_i41.PlaybackPersistenceRepository>(),
          blocStateCleanupService: gh<_i8.BlocStateCleanupService>(),
          sessionStorage: gh<_i105.SessionStorage>(),
          pendingOperationsRepository: gh<_i40.PendingOperationsRepository>(),
          waveformRepository: gh<_i166.WaveformRepository>(),
          trackVersionRepository: gh<_i152.TrackVersionRepository>(),
          syncCoordinator: gh<_i57.SyncCoordinator>(),
        ));
    gh.factory<_i206.SessionService>(() => _i206.SessionService(
          checkAuthUseCase: gh<_i128.CheckAuthenticationStatusUseCase>(),
          getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
          onboardingUseCase: gh<_i141.OnboardingUseCase>(),
          profileUseCase: gh<_i179.CheckProfileCompletenessUseCase>(),
        ));
    gh.lazySingleton<_i207.SetActiveTrackVersionUseCase>(() =>
        _i207.SetActiveTrackVersionUseCase(gh<_i175.AudioTrackRepository>()));
    gh.lazySingleton<_i208.SignInUseCase>(() => _i208.SignInUseCase(
          gh<_i122.AuthRepository>(),
          gh<_i157.UserProfileRepository>(),
        ));
    gh.factory<_i209.SyncStatusCubit>(() => _i209.SyncStatusCubit(
          gh<_i106.SyncStatusProvider>(),
          gh<_i102.PendingOperationsManager>(),
          gh<_i154.TriggerUpstreamSyncUseCase>(),
        ));
    gh.factory<_i210.TrackCacheBloc>(() => _i210.TrackCacheBloc(
          cacheTrackUseCase: gh<_i126.CacheTrackUseCase>(),
          watchTrackCacheStatusUseCase:
              gh<_i163.WatchTrackCacheStatusUseCase>(),
          removeTrackCacheUseCase: gh<_i148.RemoveTrackCacheUseCase>(),
          getCachedTrackPathUseCase: gh<_i133.GetCachedTrackPathUseCase>(),
        ));
    gh.lazySingleton<_i211.TriggerForegroundSyncUseCase>(
        () => _i211.TriggerForegroundSyncUseCase(
              gh<_i124.BackgroundSyncCoordinator>(),
              gh<_i206.SessionService>(),
            ));
    gh.factory<_i212.UpdateUserProfileUseCase>(
        () => _i212.UpdateUserProfileUseCase(
              gh<_i157.UserProfileRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.factory<_i213.UserProfileBloc>(() => _i213.UserProfileBloc(
          updateUserProfileUseCase: gh<_i212.UpdateUserProfileUseCase>(),
          createUserProfileUseCase: gh<_i182.CreateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i165.WatchUserProfileUseCase>(),
          checkProfileCompletenessUseCase:
              gh<_i179.CheckProfileCompletenessUseCase>(),
          getCurrentUserUseCase: gh<_i134.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i214.WatchAudioCommentsBundleUseCase>(
        () => _i214.WatchAudioCommentsBundleUseCase(
              gh<_i175.AudioTrackRepository>(),
              gh<_i171.AudioCommentRepository>(),
              gh<_i108.UserProfileCacheRepository>(),
            ));
    gh.factory<_i215.WatchCachedTrackBundlesUseCase>(
        () => _i215.WatchCachedTrackBundlesUseCase(
              gh<_i177.CacheMaintenanceService>(),
              gh<_i175.AudioTrackRepository>(),
              gh<_i157.UserProfileRepository>(),
              gh<_i145.ProjectsRepository>(),
              gh<_i152.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i216.WatchProjectDetailUseCase>(
        () => _i216.WatchProjectDetailUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i175.AudioTrackRepository>(),
              gh<_i108.UserProfileCacheRepository>(),
            ));
    gh.lazySingleton<_i217.WatchProjectPlaylistUseCase>(
        () => _i217.WatchProjectPlaylistUseCase(
              gh<_i175.AudioTrackRepository>(),
              gh<_i152.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i218.WatchTrackVersionsBundleUseCase>(
        () => _i218.WatchTrackVersionsBundleUseCase(
              gh<_i175.AudioTrackRepository>(),
              gh<_i152.TrackVersionRepository>(),
            ));
    gh.lazySingleton<_i219.WatchTracksByProjectIdUseCase>(() =>
        _i219.WatchTracksByProjectIdUseCase(gh<_i175.AudioTrackRepository>()));
    gh.factory<_i220.WaveformBloc>(() => _i220.WaveformBloc(
          waveformRepository: gh<_i166.WaveformRepository>(),
          audioPlaybackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.lazySingleton<_i221.AddAudioCommentUseCase>(
        () => _i221.AddAudioCommentUseCase(
              gh<_i200.ProjectCommentService>(),
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i222.AddCollaboratorByEmailUseCase>(
        () => _i222.AddCollaboratorByEmailUseCase(
              gh<_i185.FindUserByEmailUseCase>(),
              gh<_i169.AddCollaboratorToProjectUseCase>(),
              gh<_i35.NotificationService>(),
            ));
    gh.lazySingleton<_i223.AddTrackVersionUseCase>(
        () => _i223.AddTrackVersionUseCase(
              gh<_i105.SessionStorage>(),
              gh<_i152.TrackVersionRepository>(),
              gh<_i4.AudioMetadataService>(),
              gh<_i118.AudioStorageRepository>(),
              gh<_i186.GenerateAndStoreWaveform>(),
            ));
    gh.factory<_i224.AppFlowBloc>(() => _i224.AppFlowBloc(
          sessionService: gh<_i206.SessionService>(),
          getAuthStateUseCase: gh<_i132.GetAuthStateUseCase>(),
          sessionCleanupService: gh<_i205.SessionCleanupService>(),
        ));
    gh.factory<_i225.AudioContextBloc>(() => _i225.AudioContextBloc(
        loadTrackContextUseCase: gh<_i195.LoadTrackContextUseCase>()));
    gh.factory<_i226.AudioPlayerService>(() => _i226.AudioPlayerService(
          initializeAudioPlayerUseCase: gh<_i21.InitializeAudioPlayerUseCase>(),
          playVersionUseCase: gh<_i199.PlayVersionUseCase>(),
          playPlaylistUseCase: gh<_i198.PlayPlaylistUseCase>(),
          audioTrackRepository: gh<_i175.AudioTrackRepository>(),
          pauseAudioUseCase: gh<_i38.PauseAudioUseCase>(),
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
          restorePlaybackStateUseCase: gh<_i203.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i5.AudioPlaybackService>(),
        ));
    gh.factory<_i227.AuthBloc>(() => _i227.AuthBloc(
          signIn: gh<_i208.SignInUseCase>(),
          signUp: gh<_i150.SignUpUseCase>(),
          googleSignIn: gh<_i192.GoogleSignInUseCase>(),
          appleSignIn: gh<_i170.AppleSignInUseCase>(),
          signOut: gh<_i149.SignOutUseCase>(),
        ));
    gh.factory<_i228.CacheManagementBloc>(() => _i228.CacheManagementBloc(
          deleteOne: gh<_i130.DeleteCachedAudioUseCase>(),
          watchUsage: gh<_i162.WatchStorageUsageUseCase>(),
          getStats: gh<_i188.GetCacheStorageStatsUseCase>(),
          cleanup: gh<_i180.CleanupCacheUseCase>(),
          watchBundles: gh<_i215.WatchCachedTrackBundlesUseCase>(),
        ));
    gh.lazySingleton<_i229.DeleteAudioCommentUseCase>(
        () => _i229.DeleteAudioCommentUseCase(
              gh<_i200.ProjectCommentService>(),
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
            ));
    gh.lazySingleton<_i230.DeleteAudioTrack>(() => _i230.DeleteAudioTrack(
          gh<_i105.SessionStorage>(),
          gh<_i145.ProjectsRepository>(),
          gh<_i201.ProjectTrackService>(),
          gh<_i152.TrackVersionRepository>(),
          gh<_i166.WaveformRepository>(),
          gh<_i118.AudioStorageRepository>(),
          gh<_i171.AudioCommentRepository>(),
        ));
    gh.lazySingleton<_i231.DeleteProjectUseCase>(
        () => _i231.DeleteProjectUseCase(
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
              gh<_i201.ProjectTrackService>(),
              gh<_i230.DeleteAudioTrack>(),
            ));
    gh.lazySingleton<_i232.EditAudioTrackUseCase>(
        () => _i232.EditAudioTrackUseCase(
              gh<_i201.ProjectTrackService>(),
              gh<_i145.ProjectsRepository>(),
            ));
    gh.factory<_i233.ManageCollaboratorsBloc>(
        () => _i233.ManageCollaboratorsBloc(
              removeCollaboratorUseCase: gh<_i147.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i155.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i194.LeaveProjectUseCase>(),
              findUserByEmailUseCase: gh<_i185.FindUserByEmailUseCase>(),
              addCollaboratorByEmailUseCase:
                  gh<_i222.AddCollaboratorByEmailUseCase>(),
              watchCollaboratorsBundleUseCase:
                  gh<_i161.WatchCollaboratorsBundleUseCase>(),
            ));
    gh.factory<_i234.PlaylistBloc>(
        () => _i234.PlaylistBloc(gh<_i217.WatchProjectPlaylistUseCase>()));
    gh.factory<_i235.ProjectDetailBloc>(() => _i235.ProjectDetailBloc(
        watchProjectDetail: gh<_i216.WatchProjectDetailUseCase>()));
    gh.factory<_i236.ProjectInvitationActorBloc>(
        () => _i236.ProjectInvitationActorBloc(
              sendInvitationUseCase: gh<_i204.SendInvitationUseCase>(),
              acceptInvitationUseCase: gh<_i168.AcceptInvitationUseCase>(),
              declineInvitationUseCase: gh<_i183.DeclineInvitationUseCase>(),
              cancelInvitationUseCase: gh<_i127.CancelInvitationUseCase>(),
              findUserByEmailUseCase: gh<_i185.FindUserByEmailUseCase>(),
            ));
    gh.factory<_i237.ProjectsBloc>(() => _i237.ProjectsBloc(
          createProject: gh<_i181.CreateProjectUseCase>(),
          updateProject: gh<_i156.UpdateProjectUseCase>(),
          deleteProject: gh<_i231.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i159.WatchAllProjectsUseCase>(),
        ));
    gh.factory<_i238.TrackVersionsBloc>(() => _i238.TrackVersionsBloc(
          gh<_i218.WatchTrackVersionsBundleUseCase>(),
          gh<_i207.SetActiveTrackVersionUseCase>(),
          gh<_i223.AddTrackVersionUseCase>(),
          gh<_i202.RenameTrackVersionUseCase>(),
          gh<_i184.DeleteTrackVersionUseCase>(),
        ));
    gh.lazySingleton<_i239.UploadAudioTrackUseCase>(
        () => _i239.UploadAudioTrackUseCase(
              gh<_i201.ProjectTrackService>(),
              gh<_i145.ProjectsRepository>(),
              gh<_i105.SessionStorage>(),
              gh<_i223.AddTrackVersionUseCase>(),
              gh<_i175.AudioTrackRepository>(),
            ));
    gh.factory<_i240.AudioCommentBloc>(() => _i240.AudioCommentBloc(
          addAudioCommentUseCase: gh<_i221.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i229.DeleteAudioCommentUseCase>(),
          watchAudioCommentsBundleUseCase:
              gh<_i214.WatchAudioCommentsBundleUseCase>(),
        ));
    gh.factory<_i241.AudioPlayerBloc>(() => _i241.AudioPlayerBloc(
        audioPlayerService: gh<_i226.AudioPlayerService>()));
    gh.factory<_i242.AudioTrackBloc>(() => _i242.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i219.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i230.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i239.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i232.EditAudioTrackUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i243.AppModule {}
