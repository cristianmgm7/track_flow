import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/playlist/data/models/playlist_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_document.dart';
import 'package:trackflow/features/audio_cache/shared/data/models/cached_audio_document_unified.dart';
import 'package:trackflow/features/audio_cache/shared/data/models/cache_reference_document.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';

// NEW SERVICES - SOLID Architecture
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/core/sync/data/services/sync_service.dart';
import 'package:trackflow/core/app_flow/data/services/app_flow_coordinator.dart';
import 'package:trackflow/core/session/domain/usecases/check_authentication_status_usecase.dart';
import 'package:trackflow/core/session/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/core/session/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/onboarding/domain/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart';

@module
abstract class AppModule {
  // Firebase
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  // Google Sign In
  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  // Network
  @lazySingleton
  InternetConnectionChecker get internetConnectionChecker =>
      InternetConnectionChecker();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  // Storage
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([
      ProjectDocumentSchema,
      AudioTrackDocumentSchema,
      AudioCommentDocumentSchema,
      PlaylistDocumentSchema,
      UserProfileDocumentSchema,
      CachedAudioDocumentUnifiedSchema,
      CacheReferenceDocumentSchema,
      SyncOperationDocumentSchema,
    ], directory: dir.path);
  }

  @preResolve
  Future<Directory> get cacheDir async {
    return await getTemporaryDirectory();
  }

  // NEW SERVICES - SOLID Architecture
  // These will be registered as factories in the generated injection.config.dart
}
