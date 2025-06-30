// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i6;

import 'package:cloud_firestore/cloud_firestore.dart' as _i9;
import 'package:connectivity_plus/connectivity_plus.dart' as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i8;
import 'package:firebase_storage/firebase_storage.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i11;
import 'package:injectable/injectable.dart' as _i2;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i13;
import 'package:isar/isar.dart' as _i14;
import 'package:shared_preferences/shared_preferences.dart' as _i37;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i126;
import 'package:trackflow/core/di/app_module.dart' as _i143;
import 'package:trackflow/core/network/network_info.dart' as _i20;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i7;
import 'package:trackflow/core/session/session_storage.dart' as _i79;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i100;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i111;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i121;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i136;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_metadata_local_data_source.dart'
    as _i59;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i62;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i63;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_metadata_repository_impl.dart'
    as _i61;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_storage_repository_impl.dart'
    as _i65;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_metadata_repository.dart'
    as _i60;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart'
    as _i64;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart'
    as _i98;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_download_management_service.dart'
    as _i67;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_storage_management_service.dart'
    as _i69;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i102;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i110;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/cache_orchestration_service_impl.dart'
    as _i99;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_download_management_service_impl.dart'
    as _i68;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_storage_management_service_impl.dart'
    as _i70;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i101;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart'
    as _i112;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i127;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i49;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i50;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i52;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i51;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i77;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i94;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i104;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i80;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i90;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i130;
import 'package:trackflow/features/audio_player/domain/repositories/audio_content_repository.dart'
    as _i137;
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart'
    as _i22;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/domain/usecases/initialize_audio_player_usecase.dart'
    as _i12;
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart'
    as _i21;
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart'
    as _i139;
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart'
    as _i140;
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart'
    as _i141;
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart'
    as _i32;
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart'
    as _i33;
import 'package:trackflow/features/audio_player/domain/usecases/seek_audio_usecase.dart'
    as _i34;
import 'package:trackflow/features/audio_player/domain/usecases/set_playback_speed_usecase.dart'
    as _i35;
import 'package:trackflow/features/audio_player/domain/usecases/set_volume_usecase.dart'
    as _i36;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart'
    as _i38;
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart'
    as _i39;
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart'
    as _i40;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart'
    as _i41;
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart'
    as _i42;
import 'package:trackflow/features/audio_player/infrastructure/repositories/audio_content_repository_impl.dart'
    as _i138;
import 'package:trackflow/features/audio_player/infrastructure/repositories/playback_persistence_repository_impl.dart'
    as _i23;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver.dart'
    as _i131;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i132;
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart'
    as _i142;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i53;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i54;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i56;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i55;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i78;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i105;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i107;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i81;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i88;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i92;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i133;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i57;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i58;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i97;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i96;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i109;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i113;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i117;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i123;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i124;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i125;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i134;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i15;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i16;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i18;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i17;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i66;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i108;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i71;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i31;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i47;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i116;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i73;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i74;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i76;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i75;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i129;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i95;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i114;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i115;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i120;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i85;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i48;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i135;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i19;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i24;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i26;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i25;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i72;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i91;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i118;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i28;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i27;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i30;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i29;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i103;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i106;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i82;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i86;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i89;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i119;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i43;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i44;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i46;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i45;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i83;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i84;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i87;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i93;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i128;

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
    gh.lazySingleton<_i3.AudioPlaybackService>(
        () => _i4.AudioPlaybackServiceImpl());
    gh.lazySingleton<_i5.Connectivity>(() => appModule.connectivity);
    await gh.factoryAsync<_i6.Directory>(
      () => appModule.cacheDir,
      preResolve: true,
    );
    gh.singleton<_i7.DynamicLinkService>(() => _i7.DynamicLinkService());
    gh.lazySingleton<_i8.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i9.FirebaseFirestore>(() => appModule.firebaseFirestore);
    gh.lazySingleton<_i10.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i11.GoogleSignIn>(() => appModule.googleSignIn);
    gh.factory<_i12.InitializeAudioPlayerUseCase>(() =>
        _i12.InitializeAudioPlayerUseCase(
            playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i13.InternetConnectionChecker>(
        () => appModule.internetConnectionChecker);
    await gh.factoryAsync<_i14.Isar>(
      () => appModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i15.MagicLinkLocalDataSource>(
        () => _i15.MagicLinkLocalDataSourceImpl());
    gh.lazySingleton<_i16.MagicLinkRemoteDataSource>(() =>
        _i16.MagicLinkRemoteDataSourceImpl(
            firestore: gh<_i9.FirebaseFirestore>()));
    gh.factory<_i17.MagicLinkRepository>(() =>
        _i18.MagicLinkRepositoryImp(gh<_i16.MagicLinkRemoteDataSource>()));
    gh.factory<_i19.NavigationCubit>(() => _i19.NavigationCubit());
    gh.lazySingleton<_i20.NetworkInfo>(
        () => _i20.NetworkInfoImpl(gh<_i13.InternetConnectionChecker>()));
    gh.factory<_i21.PauseAudioUseCase>(() => _i21.PauseAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i22.PlaybackPersistenceRepository>(
        () => _i23.PlaybackPersistenceRepositoryImpl());
    gh.lazySingleton<_i24.ProjectDetailRemoteDataSource>(() =>
        _i24.ProjectDetailRemoteDatasourceImpl(
            firestore: gh<_i9.FirebaseFirestore>()));
    gh.lazySingleton<_i25.ProjectDetailRepository>(
        () => _i26.ProjectDetailRepositoryImpl(
              remoteDataSource: gh<_i24.ProjectDetailRemoteDataSource>(),
              networkInfo: gh<_i20.NetworkInfo>(),
            ));
    gh.lazySingleton<_i27.ProjectRemoteDataSource>(() =>
        _i27.ProjectsRemoteDatasSourceImpl(
            firestore: gh<_i9.FirebaseFirestore>()));
    gh.lazySingleton<_i28.ProjectsLocalDataSource>(
        () => _i28.ProjectsLocalDataSourceImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i29.ProjectsRepository>(() => _i30.ProjectsRepositoryImpl(
          remoteDataSource: gh<_i27.ProjectRemoteDataSource>(),
          localDataSource: gh<_i28.ProjectsLocalDataSource>(),
          networkInfo: gh<_i20.NetworkInfo>(),
        ));
    gh.lazySingleton<_i31.ResendMagicLinkUseCase>(
        () => _i31.ResendMagicLinkUseCase(gh<_i17.MagicLinkRepository>()));
    gh.factory<_i32.ResumeAudioUseCase>(() => _i32.ResumeAudioUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i33.SavePlaybackStateUseCase>(
        () => _i33.SavePlaybackStateUseCase(
              persistenceRepository: gh<_i22.PlaybackPersistenceRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i34.SeekAudioUseCase>(() =>
        _i34.SeekAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i35.SetPlaybackSpeedUseCase>(() => _i35.SetPlaybackSpeedUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i36.SetVolumeUseCase>(() =>
        _i36.SetVolumeUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    await gh.factoryAsync<_i37.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i38.SkipToNextUseCase>(() => _i38.SkipToNextUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i39.SkipToPreviousUseCase>(() => _i39.SkipToPreviousUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i40.StopAudioUseCase>(() =>
        _i40.StopAudioUseCase(playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i41.ToggleRepeatModeUseCase>(() => _i41.ToggleRepeatModeUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.factory<_i42.ToggleShuffleUseCase>(() => _i42.ToggleShuffleUseCase(
        playbackService: gh<_i3.AudioPlaybackService>()));
    gh.lazySingleton<_i43.UserProfileLocalDataSource>(
        () => _i43.IsarUserProfileLocalDataSource(gh<_i14.Isar>()));
    gh.lazySingleton<_i44.UserProfileRemoteDataSource>(
        () => _i44.UserProfileRemoteDataSourceImpl(
              gh<_i9.FirebaseFirestore>(),
              gh<_i10.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i45.UserProfileRepository>(
        () => _i46.UserProfileRepositoryImpl(
              gh<_i44.UserProfileRemoteDataSource>(),
              gh<_i43.UserProfileLocalDataSource>(),
              gh<_i20.NetworkInfo>(),
            ));
    gh.lazySingleton<_i47.ValidateMagicLinkUseCase>(
        () => _i47.ValidateMagicLinkUseCase(gh<_i17.MagicLinkRepository>()));
    gh.lazySingleton<_i48.WatchUserProfilesUseCase>(
        () => _i48.WatchUserProfilesUseCase(gh<_i45.UserProfileRepository>()));
    gh.lazySingleton<_i49.AudioCommentLocalDataSource>(
        () => _i49.IsarAudioCommentLocalDataSource(gh<_i14.Isar>()));
    gh.lazySingleton<_i50.AudioCommentRemoteDataSource>(() =>
        _i50.FirebaseAudioCommentRemoteDataSource(gh<_i9.FirebaseFirestore>()));
    gh.lazySingleton<_i51.AudioCommentRepository>(
        () => _i52.AudioCommentRepositoryImpl(
              remoteDataSource: gh<_i50.AudioCommentRemoteDataSource>(),
              localDataSource: gh<_i49.AudioCommentLocalDataSource>(),
              networkInfo: gh<_i20.NetworkInfo>(),
            ));
    gh.lazySingleton<_i53.AudioTrackLocalDataSource>(
        () => _i53.IsarAudioTrackLocalDataSource(gh<_i14.Isar>()));
    gh.lazySingleton<_i54.AudioTrackRemoteDataSource>(
        () => _i54.AudioTrackRemoteDataSourceImpl(
              gh<_i9.FirebaseFirestore>(),
              gh<_i10.FirebaseStorage>(),
            ));
    gh.lazySingleton<_i55.AudioTrackRepository>(
        () => _i56.AudioTrackRepositoryImpl(
              gh<_i54.AudioTrackRemoteDataSource>(),
              gh<_i53.AudioTrackLocalDataSource>(),
              gh<_i20.NetworkInfo>(),
            ));
    gh.lazySingleton<_i57.AuthLocalDataSource>(
        () => _i57.AuthLocalDataSourceImpl(gh<_i37.SharedPreferences>()));
    gh.lazySingleton<_i58.AuthRemoteDataSource>(
        () => _i58.AuthRemoteDataSourceImpl(
              gh<_i8.FirebaseAuth>(),
              gh<_i11.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i59.CacheMetadataLocalDataSource>(
        () => _i59.CacheMetadataLocalDataSourceImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i60.CacheMetadataRepository>(() =>
        _i61.CacheMetadataRepositoryImpl(
            localDataSource: gh<_i59.CacheMetadataLocalDataSource>()));
    gh.lazySingleton<_i62.CacheStorageLocalDataSource>(
        () => _i62.CacheStorageLocalDataSourceImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i63.CacheStorageRemoteDataSource>(() =>
        _i63.CacheStorageRemoteDataSourceImpl(gh<_i10.FirebaseStorage>()));
    gh.lazySingleton<_i64.CacheStorageRepository>(
        () => _i65.CacheStorageRepositoryImpl(
              localDataSource: gh<_i62.CacheStorageLocalDataSource>(),
              remoteDataSource: gh<_i63.CacheStorageRemoteDataSource>(),
            ));
    gh.lazySingleton<_i66.ConsumeMagicLinkUseCase>(
        () => _i66.ConsumeMagicLinkUseCase(gh<_i17.MagicLinkRepository>()));
    gh.lazySingleton<_i67.EnhancedDownloadManagementService>(() =>
        _i68.EnhancedDownloadManagementServiceImpl(
            storageRepository: gh<_i64.CacheStorageRepository>()));
    gh.lazySingleton<_i69.EnhancedStorageManagementService>(
        () => _i70.EnhancedStorageManagementServiceImpl(
              storageRepository: gh<_i64.CacheStorageRepository>(),
              metadataRepository: gh<_i60.CacheMetadataRepository>(),
            ));
    gh.lazySingleton<_i71.GetMagicLinkStatusUseCase>(
        () => _i71.GetMagicLinkStatusUseCase(gh<_i17.MagicLinkRepository>()));
    gh.lazySingleton<_i72.GetProjectByIdUseCase>(
        () => _i72.GetProjectByIdUseCase(gh<_i25.ProjectDetailRepository>()));
    gh.lazySingleton<_i73.ManageCollaboratorsLocalDataSource>(() =>
        _i73.ManageCollaboratorsLocalDataSourceImpl(
            gh<_i28.ProjectsLocalDataSource>()));
    gh.lazySingleton<_i74.ManageCollaboratorsRemoteDataSource>(() =>
        _i74.ManageCollaboratorsRemoteDataSourceImpl(
          userProfileRemoteDataSource: gh<_i44.UserProfileRemoteDataSource>(),
          firestore: gh<_i9.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i75.ManageCollaboratorsRepository>(
        () => _i76.ManageCollaboratorsRepositoryImpl(
              remoteDataSourceManageCollaborators:
                  gh<_i74.ManageCollaboratorsRemoteDataSource>(),
              localDataSourceManageCollaborators:
                  gh<_i73.ManageCollaboratorsLocalDataSource>(),
              networkInfo: gh<_i20.NetworkInfo>(),
            ));
    gh.lazySingleton<_i77.ProjectCommentService>(
        () => _i77.ProjectCommentService(gh<_i51.AudioCommentRepository>()));
    gh.lazySingleton<_i78.ProjectTrackService>(
        () => _i78.ProjectTrackService(gh<_i55.AudioTrackRepository>()));
    gh.lazySingleton<_i79.SessionStorage>(
        () => _i79.SessionStorage(prefs: gh<_i37.SharedPreferences>()));
    gh.lazySingleton<_i80.SyncAudioCommentsUseCase>(
        () => _i80.SyncAudioCommentsUseCase(
              gh<_i50.AudioCommentRemoteDataSource>(),
              gh<_i49.AudioCommentLocalDataSource>(),
              gh<_i27.ProjectRemoteDataSource>(),
              gh<_i79.SessionStorage>(),
              gh<_i54.AudioTrackRemoteDataSource>(),
            ));
    gh.lazySingleton<_i81.SyncAudioTracksUseCase>(
        () => _i81.SyncAudioTracksUseCase(
              gh<_i54.AudioTrackRemoteDataSource>(),
              gh<_i53.AudioTrackLocalDataSource>(),
              gh<_i27.ProjectRemoteDataSource>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i82.SyncProjectsUseCase>(() => _i82.SyncProjectsUseCase(
          gh<_i27.ProjectRemoteDataSource>(),
          gh<_i28.ProjectsLocalDataSource>(),
          gh<_i79.SessionStorage>(),
        ));
    gh.lazySingleton<_i83.SyncUserProfileCollaboratorsUseCase>(
        () => _i83.SyncUserProfileCollaboratorsUseCase(
              gh<_i28.ProjectsLocalDataSource>(),
              gh<_i45.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i84.SyncUserProfileUseCase>(
        () => _i84.SyncUserProfileUseCase(
              gh<_i44.UserProfileRemoteDataSource>(),
              gh<_i43.UserProfileLocalDataSource>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i85.UpdateCollaboratorRoleUseCase>(
        () => _i85.UpdateCollaboratorRoleUseCase(
              gh<_i25.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i86.UpdateProjectUseCase>(() => _i86.UpdateProjectUseCase(
          gh<_i29.ProjectsRepository>(),
          gh<_i79.SessionStorage>(),
        ));
    gh.factory<_i87.UpdateUserProfileUseCase>(
        () => _i87.UpdateUserProfileUseCase(
              gh<_i45.UserProfileRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i88.UploadAudioTrackUseCase>(
        () => _i88.UploadAudioTrackUseCase(
              gh<_i78.ProjectTrackService>(),
              gh<_i25.ProjectDetailRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i89.WatchAllProjectsUseCase>(
        () => _i89.WatchAllProjectsUseCase(
              gh<_i29.ProjectsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i90.WatchCommentsByTrackUseCase>(() =>
        _i90.WatchCommentsByTrackUseCase(gh<_i77.ProjectCommentService>()));
    gh.lazySingleton<_i91.WatchProjectDetailUseCase>(
        () => _i91.WatchProjectDetailUseCase(
              gh<_i53.AudioTrackLocalDataSource>(),
              gh<_i43.UserProfileLocalDataSource>(),
              gh<_i49.AudioCommentLocalDataSource>(),
            ));
    gh.lazySingleton<_i92.WatchTracksByProjectIdUseCase>(() =>
        _i92.WatchTracksByProjectIdUseCase(gh<_i55.AudioTrackRepository>()));
    gh.lazySingleton<_i93.WatchUserProfileUseCase>(
        () => _i93.WatchUserProfileUseCase(
              gh<_i45.UserProfileRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i94.AddAudioCommentUseCase>(
        () => _i94.AddAudioCommentUseCase(
              gh<_i77.ProjectCommentService>(),
              gh<_i25.ProjectDetailRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i95.AddCollaboratorToProjectUseCase>(
        () => _i95.AddCollaboratorToProjectUseCase(
              gh<_i25.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i96.AuthRepository>(() => _i97.AuthRepositoryImpl(
          remote: gh<_i58.AuthRemoteDataSource>(),
          local: gh<_i57.AuthLocalDataSource>(),
          networkInfo: gh<_i20.NetworkInfo>(),
          firestore: gh<_i9.FirebaseFirestore>(),
          userProfileLocalDataSource: gh<_i43.UserProfileLocalDataSource>(),
          projectLocalDataSource: gh<_i28.ProjectsLocalDataSource>(),
          audioTrackLocalDataSource: gh<_i53.AudioTrackLocalDataSource>(),
          audioCommentLocalDataSource: gh<_i49.AudioCommentLocalDataSource>(),
          sessionStorage: gh<_i79.SessionStorage>(),
        ));
    gh.lazySingleton<_i98.CacheOrchestrationService>(
        () => _i99.CacheOrchestrationServiceImpl(
              metadataRepository: gh<_i60.CacheMetadataRepository>(),
              storageRepository: gh<_i64.CacheStorageRepository>(),
            ));
    gh.factory<_i100.CachePlaylistUseCase>(
        () => _i100.CachePlaylistUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i101.CacheTrackUseCase>(
        () => _i101.CacheTrackUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i102.CleanupCacheUseCase>(
        () => _i102.CleanupCacheUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.lazySingleton<_i103.CreateProjectUseCase>(
        () => _i103.CreateProjectUseCase(
              gh<_i29.ProjectsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i104.DeleteAudioCommentUseCase>(
        () => _i104.DeleteAudioCommentUseCase(
              gh<_i77.ProjectCommentService>(),
              gh<_i25.ProjectDetailRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i105.DeleteAudioTrack>(() => _i105.DeleteAudioTrack(
          gh<_i79.SessionStorage>(),
          gh<_i25.ProjectDetailRepository>(),
          gh<_i78.ProjectTrackService>(),
        ));
    gh.lazySingleton<_i106.DeleteProjectUseCase>(
        () => _i106.DeleteProjectUseCase(
              gh<_i29.ProjectsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i107.EditAudioTrackUseCase>(
        () => _i107.EditAudioTrackUseCase(
              gh<_i78.ProjectTrackService>(),
              gh<_i25.ProjectDetailRepository>(),
            ));
    gh.lazySingleton<_i108.GenerateMagicLinkUseCase>(
        () => _i108.GenerateMagicLinkUseCase(
              gh<_i17.MagicLinkRepository>(),
              gh<_i96.AuthRepository>(),
            ));
    gh.lazySingleton<_i109.GetAuthStateUseCase>(
        () => _i109.GetAuthStateUseCase(gh<_i96.AuthRepository>()));
    gh.factory<_i110.GetCacheStorageStatsUseCase>(() =>
        _i110.GetCacheStorageStatsUseCase(
            gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i111.GetPlaylistCacheStatusUseCase>(() =>
        _i111.GetPlaylistCacheStatusUseCase(
            gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i112.GetTrackCacheStatusUseCase>(() =>
        _i112.GetTrackCacheStatusUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.lazySingleton<_i113.GoogleSignInUseCase>(
        () => _i113.GoogleSignInUseCase(gh<_i96.AuthRepository>()));
    gh.lazySingleton<_i114.JoinProjectWithIdUseCase>(
        () => _i114.JoinProjectWithIdUseCase(
              gh<_i25.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.lazySingleton<_i115.LeaveProjectUseCase>(() => _i115.LeaveProjectUseCase(
          gh<_i75.ManageCollaboratorsRepository>(),
          gh<_i79.SessionStorage>(),
        ));
    gh.factory<_i116.MagicLinkBloc>(() => _i116.MagicLinkBloc(
          generateMagicLink: gh<_i108.GenerateMagicLinkUseCase>(),
          validateMagicLink: gh<_i47.ValidateMagicLinkUseCase>(),
          consumeMagicLink: gh<_i66.ConsumeMagicLinkUseCase>(),
          resendMagicLink: gh<_i31.ResendMagicLinkUseCase>(),
          getMagicLinkStatus: gh<_i71.GetMagicLinkStatusUseCase>(),
          joinProjectWithId: gh<_i114.JoinProjectWithIdUseCase>(),
          authRepository: gh<_i96.AuthRepository>(),
        ));
    gh.lazySingleton<_i117.OnboardingUseCase>(
        () => _i117.OnboardingUseCase(gh<_i96.AuthRepository>()));
    gh.factory<_i118.ProjectDetailBloc>(() => _i118.ProjectDetailBloc(
        watchProjectDetail: gh<_i91.WatchProjectDetailUseCase>()));
    gh.factory<_i119.ProjectsBloc>(() => _i119.ProjectsBloc(
          createProject: gh<_i103.CreateProjectUseCase>(),
          updateProject: gh<_i86.UpdateProjectUseCase>(),
          deleteProject: gh<_i106.DeleteProjectUseCase>(),
          watchAllProjects: gh<_i89.WatchAllProjectsUseCase>(),
        ));
    gh.lazySingleton<_i120.RemoveCollaboratorUseCase>(
        () => _i120.RemoveCollaboratorUseCase(
              gh<_i25.ProjectDetailRepository>(),
              gh<_i75.ManageCollaboratorsRepository>(),
              gh<_i79.SessionStorage>(),
            ));
    gh.factory<_i121.RemovePlaylistCacheUseCase>(() =>
        _i121.RemovePlaylistCacheUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i122.RemoveTrackCacheUseCase>(() =>
        _i122.RemoveTrackCacheUseCase(gh<_i98.CacheOrchestrationService>()));
    gh.lazySingleton<_i123.SignInUseCase>(
        () => _i123.SignInUseCase(gh<_i96.AuthRepository>()));
    gh.lazySingleton<_i124.SignOutUseCase>(
        () => _i124.SignOutUseCase(gh<_i96.AuthRepository>()));
    gh.lazySingleton<_i125.SignUpUseCase>(
        () => _i125.SignUpUseCase(gh<_i96.AuthRepository>()));
    gh.lazySingleton<_i126.StartupResourceManager>(
        () => _i126.StartupResourceManager(
              gh<_i80.SyncAudioCommentsUseCase>(),
              gh<_i81.SyncAudioTracksUseCase>(),
              gh<_i82.SyncProjectsUseCase>(),
              gh<_i84.SyncUserProfileUseCase>(),
              gh<_i83.SyncUserProfileCollaboratorsUseCase>(),
            ));
    gh.factory<_i127.TrackCacheBloc>(() => _i127.TrackCacheBloc(
          gh<_i101.CacheTrackUseCase>(),
          gh<_i112.GetTrackCacheStatusUseCase>(),
          gh<_i122.RemoveTrackCacheUseCase>(),
        ));
    gh.factory<_i128.UserProfileBloc>(() => _i128.UserProfileBloc(
          updateUserProfileUseCase: gh<_i87.UpdateUserProfileUseCase>(),
          watchUserProfileUseCase: gh<_i93.WatchUserProfileUseCase>(),
        ));
    gh.lazySingleton<_i129.AddCollaboratorAndSyncProfileService>(
        () => _i129.AddCollaboratorAndSyncProfileService(
              gh<_i95.AddCollaboratorToProjectUseCase>(),
              gh<_i45.UserProfileRepository>(),
            ));
    gh.factory<_i130.AudioCommentBloc>(() => _i130.AudioCommentBloc(
          watchCommentsByTrackUseCase: gh<_i90.WatchCommentsByTrackUseCase>(),
          addAudioCommentUseCase: gh<_i94.AddAudioCommentUseCase>(),
          deleteAudioCommentUseCase: gh<_i104.DeleteAudioCommentUseCase>(),
        ));
    gh.factory<_i131.AudioSourceResolver>(() =>
        _i132.AudioSourceResolverImpl(gh<_i98.CacheOrchestrationService>()));
    gh.factory<_i133.AudioTrackBloc>(() => _i133.AudioTrackBloc(
          watchAudioTracksByProject: gh<_i92.WatchTracksByProjectIdUseCase>(),
          deleteAudioTrack: gh<_i105.DeleteAudioTrack>(),
          uploadAudioTrackUseCase: gh<_i88.UploadAudioTrackUseCase>(),
          editAudioTrackUseCase: gh<_i107.EditAudioTrackUseCase>(),
        ));
    gh.factory<_i134.AuthBloc>(() => _i134.AuthBloc(
          signIn: gh<_i123.SignInUseCase>(),
          signUp: gh<_i125.SignUpUseCase>(),
          signOut: gh<_i124.SignOutUseCase>(),
          googleSignIn: gh<_i113.GoogleSignInUseCase>(),
          getAuthState: gh<_i109.GetAuthStateUseCase>(),
          onboarding: gh<_i117.OnboardingUseCase>(),
        ));
    gh.factory<_i135.ManageCollaboratorsBloc>(
        () => _i135.ManageCollaboratorsBloc(
              addCollaboratorAndSyncProfileService:
                  gh<_i129.AddCollaboratorAndSyncProfileService>(),
              removeCollaboratorUseCase: gh<_i120.RemoveCollaboratorUseCase>(),
              updateCollaboratorRoleUseCase:
                  gh<_i85.UpdateCollaboratorRoleUseCase>(),
              leaveProjectUseCase: gh<_i115.LeaveProjectUseCase>(),
              watchUserProfilesUseCase: gh<_i48.WatchUserProfilesUseCase>(),
            ));
    gh.factory<_i136.PlaylistCacheBloc>(() => _i136.PlaylistCacheBloc(
          gh<_i100.CachePlaylistUseCase>(),
          gh<_i111.GetPlaylistCacheStatusUseCase>(),
          gh<_i121.RemovePlaylistCacheUseCase>(),
        ));
    gh.lazySingleton<_i137.AudioContentRepository>(
        () => _i138.AudioContentRepositoryImpl(
              gh<_i55.AudioTrackRepository>(),
              gh<_i131.AudioSourceResolver>(),
            ));
    gh.factory<_i139.PlayAudioUseCase>(() => _i139.PlayAudioUseCase(
          audioContentRepository: gh<_i137.AudioContentRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i140.PlayPlaylistUseCase>(() => _i140.PlayPlaylistUseCase(
          audioContentRepository: gh<_i137.AudioContentRepository>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    gh.factory<_i141.RestorePlaybackStateUseCase>(
        () => _i141.RestorePlaybackStateUseCase(
              persistenceRepository: gh<_i22.PlaybackPersistenceRepository>(),
              audioContentRepository: gh<_i137.AudioContentRepository>(),
              playbackService: gh<_i3.AudioPlaybackService>(),
            ));
    gh.factory<_i142.AudioPlayerBloc>(() => _i142.AudioPlayerBloc(
          initializeAudioPlayerUseCase: gh<_i12.InitializeAudioPlayerUseCase>(),
          playAudioUseCase: gh<_i139.PlayAudioUseCase>(),
          playPlaylistUseCase: gh<_i140.PlayPlaylistUseCase>(),
          pauseAudioUseCase: gh<_i21.PauseAudioUseCase>(),
          resumeAudioUseCase: gh<_i32.ResumeAudioUseCase>(),
          stopAudioUseCase: gh<_i40.StopAudioUseCase>(),
          skipToNextUseCase: gh<_i38.SkipToNextUseCase>(),
          skipToPreviousUseCase: gh<_i39.SkipToPreviousUseCase>(),
          seekAudioUseCase: gh<_i34.SeekAudioUseCase>(),
          toggleShuffleUseCase: gh<_i42.ToggleShuffleUseCase>(),
          toggleRepeatModeUseCase: gh<_i41.ToggleRepeatModeUseCase>(),
          setVolumeUseCase: gh<_i36.SetVolumeUseCase>(),
          setPlaybackSpeedUseCase: gh<_i35.SetPlaybackSpeedUseCase>(),
          savePlaybackStateUseCase: gh<_i33.SavePlaybackStateUseCase>(),
          restorePlaybackStateUseCase: gh<_i141.RestorePlaybackStateUseCase>(),
          playbackService: gh<_i3.AudioPlaybackService>(),
        ));
    return this;
  }
}

class _$AppModule extends _i143.AppModule {}
