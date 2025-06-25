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
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_document.dart';

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

  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    //if (Isar.instanceNames.isEmpty) {
    return await Isar.open([
      ProjectDocumentSchema,
      AudioCommentDocumentSchema,
      AudioTrackDocumentSchema,
      UserProfileDocumentSchema,
    ], directory: dir.path);
    //}
    //return Future.value(Isar.getInstance());
  }
}
