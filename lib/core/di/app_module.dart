import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@module
abstract class AppModule {
  @preResolve
  Future<Directory> get cacheDir async => await getTemporaryDirectory();

  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  InternetConnectionChecker get internetConnectionChecker =>
      InternetConnectionChecker();

  @lazySingleton
  Box<ProjectDTO> get projectsBox => Hive.box<ProjectDTO>('projectsBox');

  @lazySingleton
  Box<AudioCommentDTO> get audioCommentsBox =>
      Hive.box<AudioCommentDTO>('audioCommentsBox');

  @lazySingleton
  Box<AudioTrackDTO> get audioTracksBox =>
      Hive.box<AudioTrackDTO>('audioTracksBox');

  @lazySingleton
  Box<UserProfileDTO> get userProfilesBox =>
      Hive.box<UserProfileDTO>('userProfilesBox');
}
