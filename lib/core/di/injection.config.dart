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
    as _i12;
import 'package:isar/isar.dart' as _i13;
import 'package:shared_preferences/shared_preferences.dart' as _i28;
import 'package:trackflow/core/app/startup_resource_manager.dart' as _i112;
import 'package:trackflow/core/di/app_module.dart' as _i125;
import 'package:trackflow/core/network/network_info.dart' as _i19;
import 'package:trackflow/core/services/dynamic_link_service.dart' as _i7;
import 'package:trackflow/core/session/session_storage.dart' as _i65;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/cache_playlist_usecase.dart'
    as _i86;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart'
    as _i97;
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/remove_playlist_cache_usecase.dart'
    as _i107;
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart'
    as _i122;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_metadata_local_data_source.dart'
    as _i45;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart'
    as _i48;
import 'package:trackflow/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart'
    as _i49;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_metadata_repository_impl.dart'
    as _i47;
import 'package:trackflow/features/audio_cache/shared/data/repositories/cache_storage_repository_impl.dart'
    as _i51;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_metadata_repository.dart'
    as _i46;
import 'package:trackflow/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart'
    as _i50;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart'
    as _i84;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_download_management_service.dart'
    as _i53;
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_storage_management_service.dart'
    as _i55;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart'
    as _i88;
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart'
    as _i96;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/cache_orchestration_service_impl.dart'
    as _i85;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_download_management_service_impl.dart'
    as _i54;
import 'package:trackflow/features/audio_cache/shared/infrastructure/services/enhanced_storage_management_service_impl.dart'
    as _i56;
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart'
    as _i87;
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart'
    as _i98;
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart'
    as _i108;
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart'
    as _i113;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart'
    as _i35;
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart'
    as _i36;
import 'package:trackflow/features/audio_comment/data/repositories/audio_comment_repository_impl.dart'
    as _i38;
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart'
    as _i37;
import 'package:trackflow/features/audio_comment/domain/services/project_comment_service.dart'
    as _i63;
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart'
    as _i80;
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart'
    as _i90;
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart'
    as _i66;
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart'
    as _i76;
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart'
    as _i116;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart'
    as _i39;
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart'
    as _i40;
import 'package:trackflow/features/audio_track/data/repositories/audio_track_repository_impl.dart'
    as _i42;
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart'
    as _i41;
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart'
    as _i64;
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart'
    as _i91;
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart'
    as _i93;
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart'
    as _i67;
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart'
    as _i74;
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart'
    as _i78;
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart'
    as _i119;
import 'package:trackflow/features/auth/data/data_sources/auth_local_datasource.dart'
    as _i43;
import 'package:trackflow/features/auth/data/data_sources/auth_remote_datasource.dart'
    as _i44;
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i83;
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart'
    as _i82;
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart'
    as _i95;
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i99;
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart'
    as _i103;
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i109;
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i110;
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i111;
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i120;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_local_data_source.dart'
    as _i14;
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart'
    as _i15;
import 'package:trackflow/features/magic_link/data/repositories/magic_link_impl.dart'
    as _i17;
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart'
    as _i16;
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart'
    as _i52;
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart'
    as _i94;
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart'
    as _i57;
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart'
    as _i27;
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart'
    as _i33;
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart'
    as _i102;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart'
    as _i59;
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart'
    as _i60;
import 'package:trackflow/features/manage_collaborators/data/repositories/manage_collaborators_repository_impl.dart'
    as _i62;
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart'
    as _i61;
import 'package:trackflow/features/manage_collaborators/domain/services/add_collaborator_and_sync_profile_service.dart'
    as _i115;
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart'
    as _i81;
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart'
    as _i100;
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart'
    as _i101;
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart'
    as _i106;
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart'
    as _i71;
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart'
    as _i34;
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart'
    as _i121;
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart'
    as _i18;
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart'
    as _i20;
import 'package:trackflow/features/project_detail/data/repositories/project_detail_repository_impl.dart'
    as _i22;
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart'
    as _i21;
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart'
    as _i58;
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart'
    as _i77;
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart'
    as _i104;
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart'
    as _i24;
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart'
    as _i23;
import 'package:trackflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i26;
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart'
    as _i25;
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart'
    as _i89;
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart'
    as _i92;
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart'
    as _i68;
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart'
    as _i72;
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart'
    as _i75;
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart'
    as _i105;
import 'package:trackflow/features/audio_player/domain/repositories/audio_content_repository.dart'
    as _i123;
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart'
    as _i3;
import 'package:trackflow/features/audio_player/infrastructure/repositories/audio_content_repository_impl.dart'
    as _i124;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_playback_service_impl.dart'
    as _i4;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver.dart'
    as _i117;
import 'package:trackflow/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart'
    as _i118;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i29;
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart'
    as _i30;
import 'package:trackflow/features/user_profile/data/repositories/user_profile_repository_impl.dart'
    as _i32;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i31;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart'
    as _i69;
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart'
    as _i70;
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart'
    as _i73;
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart'
    as _i79;
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart'
    as _i114;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i3.AudioPlaybackService>(
      () => _i4.AudioPlaybackServiceImpl(),
    );
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
    gh.lazySingleton<_i12.InternetConnectionChecker>(
      () => appModule.internetConnectionChecker,
    );
    await gh.factoryAsync<_i13.Isar>(() => appModule.isar, preResolve: true);
    gh.lazySingleton<_i14.MagicLinkLocalDataSource>(
      () => _i14.MagicLinkLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i15.MagicLinkRemoteDataSource>(
      () => _i15.MagicLinkRemoteDataSourceImpl(
        firestore: gh<_i9.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i16.MagicLinkRepository>(
      () => _i17.MagicLinkRepositoryImp(gh<_i15.MagicLinkRemoteDataSource>()),
    );
    gh.factory<_i18.NavigationCubit>(() => _i18.NavigationCubit());
    gh.lazySingleton<_i19.NetworkInfo>(
      () => _i19.NetworkInfoImpl(gh<_i12.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i20.ProjectDetailRemoteDataSource>(
      () => _i20.ProjectDetailRemoteDatasourceImpl(
        firestore: gh<_i9.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i21.ProjectDetailRepository>(
      () => _i22.ProjectDetailRepositoryImpl(
        remoteDataSource: gh<_i20.ProjectDetailRemoteDataSource>(),
        networkInfo: gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i23.ProjectRemoteDataSource>(
      () => _i23.ProjectsRemoteDatasSourceImpl(
        firestore: gh<_i9.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i24.ProjectsLocalDataSource>(
      () => _i24.ProjectsLocalDataSourceImpl(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i25.ProjectsRepository>(
      () => _i26.ProjectsRepositoryImpl(
        remoteDataSource: gh<_i23.ProjectRemoteDataSource>(),
        localDataSource: gh<_i24.ProjectsLocalDataSource>(),
        networkInfo: gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i27.ResendMagicLinkUseCase>(
      () => _i27.ResendMagicLinkUseCase(gh<_i16.MagicLinkRepository>()),
    );
    await gh.factoryAsync<_i28.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i29.UserProfileLocalDataSource>(
      () => _i29.IsarUserProfileLocalDataSource(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i30.UserProfileRemoteDataSource>(
      () => _i30.UserProfileRemoteDataSourceImpl(
        gh<_i9.FirebaseFirestore>(),
        gh<_i10.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i31.UserProfileRepository>(
      () => _i32.UserProfileRepositoryImpl(
        gh<_i30.UserProfileRemoteDataSource>(),
        gh<_i29.UserProfileLocalDataSource>(),
        gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i33.ValidateMagicLinkUseCase>(
      () => _i33.ValidateMagicLinkUseCase(gh<_i16.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i34.WatchUserProfilesUseCase>(
      () => _i34.WatchUserProfilesUseCase(gh<_i31.UserProfileRepository>()),
    );
    gh.lazySingleton<_i35.AudioCommentLocalDataSource>(
      () => _i35.IsarAudioCommentLocalDataSource(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i36.AudioCommentRemoteDataSource>(
      () => _i36.FirebaseAudioCommentRemoteDataSource(
        gh<_i9.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i37.AudioCommentRepository>(
      () => _i38.AudioCommentRepositoryImpl(
        remoteDataSource: gh<_i36.AudioCommentRemoteDataSource>(),
        localDataSource: gh<_i35.AudioCommentLocalDataSource>(),
        networkInfo: gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i39.AudioTrackLocalDataSource>(
      () => _i39.IsarAudioTrackLocalDataSource(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i40.AudioTrackRemoteDataSource>(
      () => _i40.AudioTrackRemoteDataSourceImpl(
        gh<_i9.FirebaseFirestore>(),
        gh<_i10.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i41.AudioTrackRepository>(
      () => _i42.AudioTrackRepositoryImpl(
        gh<_i40.AudioTrackRemoteDataSource>(),
        gh<_i39.AudioTrackLocalDataSource>(),
        gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i43.AuthLocalDataSource>(
      () => _i43.AuthLocalDataSourceImpl(gh<_i28.SharedPreferences>()),
    );
    gh.lazySingleton<_i44.AuthRemoteDataSource>(
      () => _i44.AuthRemoteDataSourceImpl(
        gh<_i8.FirebaseAuth>(),
        gh<_i11.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i45.CacheMetadataLocalDataSource>(
      () => _i45.CacheMetadataLocalDataSourceImpl(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i46.CacheMetadataRepository>(
      () => _i47.CacheMetadataRepositoryImpl(
        localDataSource: gh<_i45.CacheMetadataLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i48.CacheStorageLocalDataSource>(
      () => _i48.CacheStorageLocalDataSourceImpl(gh<_i13.Isar>()),
    );
    gh.lazySingleton<_i49.CacheStorageRemoteDataSource>(
      () => _i49.CacheStorageRemoteDataSourceImpl(gh<_i10.FirebaseStorage>()),
    );
    gh.lazySingleton<_i50.CacheStorageRepository>(
      () => _i51.CacheStorageRepositoryImpl(
        localDataSource: gh<_i48.CacheStorageLocalDataSource>(),
        remoteDataSource: gh<_i49.CacheStorageRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i52.ConsumeMagicLinkUseCase>(
      () => _i52.ConsumeMagicLinkUseCase(gh<_i16.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i53.EnhancedDownloadManagementService>(
      () => _i54.EnhancedDownloadManagementServiceImpl(
        storageRepository: gh<_i50.CacheStorageRepository>(),
      ),
    );
    gh.lazySingleton<_i55.EnhancedStorageManagementService>(
      () => _i56.EnhancedStorageManagementServiceImpl(
        storageRepository: gh<_i50.CacheStorageRepository>(),
        metadataRepository: gh<_i46.CacheMetadataRepository>(),
      ),
    );
    gh.lazySingleton<_i57.GetMagicLinkStatusUseCase>(
      () => _i57.GetMagicLinkStatusUseCase(gh<_i16.MagicLinkRepository>()),
    );
    gh.lazySingleton<_i58.GetProjectByIdUseCase>(
      () => _i58.GetProjectByIdUseCase(gh<_i21.ProjectDetailRepository>()),
    );
    gh.lazySingleton<_i59.ManageCollaboratorsLocalDataSource>(
      () => _i59.ManageCollaboratorsLocalDataSourceImpl(
        gh<_i24.ProjectsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i60.ManageCollaboratorsRemoteDataSource>(
      () => _i60.ManageCollaboratorsRemoteDataSourceImpl(
        userProfileRemoteDataSource: gh<_i30.UserProfileRemoteDataSource>(),
        firestore: gh<_i9.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i61.ManageCollaboratorsRepository>(
      () => _i62.ManageCollaboratorsRepositoryImpl(
        remoteDataSourceManageCollaborators:
            gh<_i60.ManageCollaboratorsRemoteDataSource>(),
        localDataSourceManageCollaborators:
            gh<_i59.ManageCollaboratorsLocalDataSource>(),
        networkInfo: gh<_i19.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i63.ProjectCommentService>(
      () => _i63.ProjectCommentService(gh<_i37.AudioCommentRepository>()),
    );
    gh.lazySingleton<_i64.ProjectTrackService>(
      () => _i64.ProjectTrackService(gh<_i41.AudioTrackRepository>()),
    );
    gh.lazySingleton<_i65.SessionStorage>(
      () => _i65.SessionStorage(prefs: gh<_i28.SharedPreferences>()),
    );
    gh.lazySingleton<_i66.SyncAudioCommentsUseCase>(
      () => _i66.SyncAudioCommentsUseCase(
        gh<_i36.AudioCommentRemoteDataSource>(),
        gh<_i35.AudioCommentLocalDataSource>(),
        gh<_i23.ProjectRemoteDataSource>(),
        gh<_i65.SessionStorage>(),
        gh<_i40.AudioTrackRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i67.SyncAudioTracksUseCase>(
      () => _i67.SyncAudioTracksUseCase(
        gh<_i40.AudioTrackRemoteDataSource>(),
        gh<_i39.AudioTrackLocalDataSource>(),
        gh<_i23.ProjectRemoteDataSource>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i68.SyncProjectsUseCase>(
      () => _i68.SyncProjectsUseCase(
        gh<_i23.ProjectRemoteDataSource>(),
        gh<_i24.ProjectsLocalDataSource>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i69.SyncUserProfileCollaboratorsUseCase>(
      () => _i69.SyncUserProfileCollaboratorsUseCase(
        gh<_i24.ProjectsLocalDataSource>(),
        gh<_i31.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i70.SyncUserProfileUseCase>(
      () => _i70.SyncUserProfileUseCase(
        gh<_i30.UserProfileRemoteDataSource>(),
        gh<_i29.UserProfileLocalDataSource>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i71.UpdateCollaboratorRoleUseCase>(
      () => _i71.UpdateCollaboratorRoleUseCase(
        gh<_i21.ProjectDetailRepository>(),
        gh<_i61.ManageCollaboratorsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i72.UpdateProjectUseCase>(
      () => _i72.UpdateProjectUseCase(
        gh<_i25.ProjectsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.factory<_i73.UpdateUserProfileUseCase>(
      () => _i73.UpdateUserProfileUseCase(
        gh<_i31.UserProfileRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i74.UploadAudioTrackUseCase>(
      () => _i74.UploadAudioTrackUseCase(
        gh<_i64.ProjectTrackService>(),
        gh<_i21.ProjectDetailRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i75.WatchAllProjectsUseCase>(
      () => _i75.WatchAllProjectsUseCase(
        gh<_i25.ProjectsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i76.WatchCommentsByTrackUseCase>(
      () => _i76.WatchCommentsByTrackUseCase(gh<_i63.ProjectCommentService>()),
    );
    gh.lazySingleton<_i77.WatchProjectDetailUseCase>(
      () => _i77.WatchProjectDetailUseCase(
        gh<_i39.AudioTrackLocalDataSource>(),
        gh<_i29.UserProfileLocalDataSource>(),
        gh<_i35.AudioCommentLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i78.WatchTracksByProjectIdUseCase>(
      () => _i78.WatchTracksByProjectIdUseCase(gh<_i41.AudioTrackRepository>()),
    );
    gh.lazySingleton<_i79.WatchUserProfileUseCase>(
      () => _i79.WatchUserProfileUseCase(
        gh<_i31.UserProfileRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i80.AddAudioCommentUseCase>(
      () => _i80.AddAudioCommentUseCase(
        gh<_i63.ProjectCommentService>(),
        gh<_i21.ProjectDetailRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i81.AddCollaboratorToProjectUseCase>(
      () => _i81.AddCollaboratorToProjectUseCase(
        gh<_i21.ProjectDetailRepository>(),
        gh<_i61.ManageCollaboratorsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i82.AuthRepository>(
      () => _i83.AuthRepositoryImpl(
        remote: gh<_i44.AuthRemoteDataSource>(),
        local: gh<_i43.AuthLocalDataSource>(),
        networkInfo: gh<_i19.NetworkInfo>(),
        firestore: gh<_i9.FirebaseFirestore>(),
        userProfileLocalDataSource: gh<_i29.UserProfileLocalDataSource>(),
        projectLocalDataSource: gh<_i24.ProjectsLocalDataSource>(),
        audioTrackLocalDataSource: gh<_i39.AudioTrackLocalDataSource>(),
        audioCommentLocalDataSource: gh<_i35.AudioCommentLocalDataSource>(),
        sessionStorage: gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i84.CacheOrchestrationService>(
      () => _i85.CacheOrchestrationServiceImpl(
        metadataRepository: gh<_i46.CacheMetadataRepository>(),
        storageRepository: gh<_i50.CacheStorageRepository>(),
      ),
    );
    gh.factory<_i86.CachePlaylistUseCase>(
      () => _i86.CachePlaylistUseCase(gh<_i84.CacheOrchestrationService>()),
    );
    gh.factory<_i87.CacheTrackUseCase>(
      () => _i87.CacheTrackUseCase(gh<_i84.CacheOrchestrationService>()),
    );
    gh.factory<_i88.CleanupCacheUseCase>(
      () => _i88.CleanupCacheUseCase(gh<_i84.CacheOrchestrationService>()),
    );
    gh.lazySingleton<_i89.CreateProjectUseCase>(
      () => _i89.CreateProjectUseCase(
        gh<_i25.ProjectsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i90.DeleteAudioCommentUseCase>(
      () => _i90.DeleteAudioCommentUseCase(
        gh<_i63.ProjectCommentService>(),
        gh<_i21.ProjectDetailRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i91.DeleteAudioTrack>(
      () => _i91.DeleteAudioTrack(
        gh<_i65.SessionStorage>(),
        gh<_i21.ProjectDetailRepository>(),
        gh<_i64.ProjectTrackService>(),
      ),
    );
    gh.lazySingleton<_i92.DeleteProjectUseCase>(
      () => _i92.DeleteProjectUseCase(
        gh<_i25.ProjectsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i93.EditAudioTrackUseCase>(
      () => _i93.EditAudioTrackUseCase(
        gh<_i64.ProjectTrackService>(),
        gh<_i21.ProjectDetailRepository>(),
      ),
    );
    gh.lazySingleton<_i94.GenerateMagicLinkUseCase>(
      () => _i94.GenerateMagicLinkUseCase(
        gh<_i16.MagicLinkRepository>(),
        gh<_i82.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i95.GetAuthStateUseCase>(
      () => _i95.GetAuthStateUseCase(gh<_i82.AuthRepository>()),
    );
    gh.factory<_i96.GetCacheStorageStatsUseCase>(
      () => _i96.GetCacheStorageStatsUseCase(
        gh<_i84.CacheOrchestrationService>(),
      ),
    );
    gh.factory<_i97.GetPlaylistCacheStatusUseCase>(
      () => _i97.GetPlaylistCacheStatusUseCase(
        gh<_i84.CacheOrchestrationService>(),
      ),
    );
    gh.factory<_i98.GetTrackCacheStatusUseCase>(
      () =>
          _i98.GetTrackCacheStatusUseCase(gh<_i84.CacheOrchestrationService>()),
    );
    gh.lazySingleton<_i99.GoogleSignInUseCase>(
      () => _i99.GoogleSignInUseCase(gh<_i82.AuthRepository>()),
    );
    gh.lazySingleton<_i100.JoinProjectWithIdUseCase>(
      () => _i100.JoinProjectWithIdUseCase(
        gh<_i21.ProjectDetailRepository>(),
        gh<_i61.ManageCollaboratorsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i101.LeaveProjectUseCase>(
      () => _i101.LeaveProjectUseCase(
        gh<_i61.ManageCollaboratorsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.factory<_i102.MagicLinkBloc>(
      () => _i102.MagicLinkBloc(
        generateMagicLink: gh<_i94.GenerateMagicLinkUseCase>(),
        validateMagicLink: gh<_i33.ValidateMagicLinkUseCase>(),
        consumeMagicLink: gh<_i52.ConsumeMagicLinkUseCase>(),
        resendMagicLink: gh<_i27.ResendMagicLinkUseCase>(),
        getMagicLinkStatus: gh<_i57.GetMagicLinkStatusUseCase>(),
        joinProjectWithId: gh<_i100.JoinProjectWithIdUseCase>(),
        authRepository: gh<_i82.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i103.OnboardingUseCase>(
      () => _i103.OnboardingUseCase(gh<_i82.AuthRepository>()),
    );
    gh.factory<_i104.ProjectDetailBloc>(
      () => _i104.ProjectDetailBloc(
        watchProjectDetail: gh<_i77.WatchProjectDetailUseCase>(),
      ),
    );
    gh.factory<_i105.ProjectsBloc>(
      () => _i105.ProjectsBloc(
        createProject: gh<_i89.CreateProjectUseCase>(),
        updateProject: gh<_i72.UpdateProjectUseCase>(),
        deleteProject: gh<_i92.DeleteProjectUseCase>(),
        watchAllProjects: gh<_i75.WatchAllProjectsUseCase>(),
      ),
    );
    gh.lazySingleton<_i106.RemoveCollaboratorUseCase>(
      () => _i106.RemoveCollaboratorUseCase(
        gh<_i21.ProjectDetailRepository>(),
        gh<_i61.ManageCollaboratorsRepository>(),
        gh<_i65.SessionStorage>(),
      ),
    );
    gh.factory<_i107.RemovePlaylistCacheUseCase>(
      () => _i107.RemovePlaylistCacheUseCase(
        gh<_i84.CacheOrchestrationService>(),
      ),
    );
    gh.factory<_i108.RemoveTrackCacheUseCase>(
      () => _i108.RemoveTrackCacheUseCase(gh<_i84.CacheOrchestrationService>()),
    );
    gh.lazySingleton<_i109.SignInUseCase>(
      () => _i109.SignInUseCase(gh<_i82.AuthRepository>()),
    );
    gh.lazySingleton<_i110.SignOutUseCase>(
      () => _i110.SignOutUseCase(gh<_i82.AuthRepository>()),
    );
    gh.lazySingleton<_i111.SignUpUseCase>(
      () => _i111.SignUpUseCase(gh<_i82.AuthRepository>()),
    );
    gh.lazySingleton<_i112.StartupResourceManager>(
      () => _i112.StartupResourceManager(
        gh<_i66.SyncAudioCommentsUseCase>(),
        gh<_i67.SyncAudioTracksUseCase>(),
        gh<_i68.SyncProjectsUseCase>(),
        gh<_i70.SyncUserProfileUseCase>(),
        gh<_i69.SyncUserProfileCollaboratorsUseCase>(),
      ),
    );
    gh.factory<_i113.TrackCacheBloc>(
      () => _i113.TrackCacheBloc(
        gh<_i87.CacheTrackUseCase>(),
        gh<_i98.GetTrackCacheStatusUseCase>(),
        gh<_i108.RemoveTrackCacheUseCase>(),
      ),
    );
    gh.factory<_i114.UserProfileBloc>(
      () => _i114.UserProfileBloc(
        updateUserProfileUseCase: gh<_i73.UpdateUserProfileUseCase>(),
        watchUserProfileUseCase: gh<_i79.WatchUserProfileUseCase>(),
      ),
    );
    gh.lazySingleton<_i115.AddCollaboratorAndSyncProfileService>(
      () => _i115.AddCollaboratorAndSyncProfileService(
        gh<_i81.AddCollaboratorToProjectUseCase>(),
        gh<_i31.UserProfileRepository>(),
      ),
    );
    gh.factory<_i116.AudioCommentBloc>(
      () => _i116.AudioCommentBloc(
        watchCommentsByTrackUseCase: gh<_i76.WatchCommentsByTrackUseCase>(),
        addAudioCommentUseCase: gh<_i80.AddAudioCommentUseCase>(),
        deleteAudioCommentUseCase: gh<_i90.DeleteAudioCommentUseCase>(),
      ),
    );
    gh.factory<_i117.AudioSourceResolver>(
      () => _i118.AudioSourceResolverImpl(gh<_i84.CacheOrchestrationService>()),
    );
    gh.factory<_i119.AudioTrackBloc>(
      () => _i119.AudioTrackBloc(
        watchAudioTracksByProject: gh<_i78.WatchTracksByProjectIdUseCase>(),
        deleteAudioTrack: gh<_i91.DeleteAudioTrack>(),
        uploadAudioTrackUseCase: gh<_i74.UploadAudioTrackUseCase>(),
        editAudioTrackUseCase: gh<_i93.EditAudioTrackUseCase>(),
      ),
    );
    gh.factory<_i120.AuthBloc>(
      () => _i120.AuthBloc(
        signIn: gh<_i109.SignInUseCase>(),
        signUp: gh<_i111.SignUpUseCase>(),
        signOut: gh<_i110.SignOutUseCase>(),
        googleSignIn: gh<_i99.GoogleSignInUseCase>(),
        getAuthState: gh<_i95.GetAuthStateUseCase>(),
        onboarding: gh<_i103.OnboardingUseCase>(),
      ),
    );
    gh.factory<_i121.ManageCollaboratorsBloc>(
      () => _i121.ManageCollaboratorsBloc(
        addCollaboratorAndSyncProfileService:
            gh<_i115.AddCollaboratorAndSyncProfileService>(),
        removeCollaboratorUseCase: gh<_i106.RemoveCollaboratorUseCase>(),
        updateCollaboratorRoleUseCase: gh<_i71.UpdateCollaboratorRoleUseCase>(),
        leaveProjectUseCase: gh<_i101.LeaveProjectUseCase>(),
        watchUserProfilesUseCase: gh<_i34.WatchUserProfilesUseCase>(),
      ),
    );
    gh.factory<_i122.PlaylistCacheBloc>(
      () => _i122.PlaylistCacheBloc(
        gh<_i86.CachePlaylistUseCase>(),
        gh<_i97.GetPlaylistCacheStatusUseCase>(),
        gh<_i107.RemovePlaylistCacheUseCase>(),
      ),
    );
    gh.lazySingleton<_i123.AudioContentRepository>(
      () => _i124.AudioContentRepositoryImpl(
        gh<_i41.AudioTrackRepository>(),
        gh<_i117.AudioSourceResolver>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i125.AppModule {}
