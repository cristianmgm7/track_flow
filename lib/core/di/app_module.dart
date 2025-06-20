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

  @Named('projectsBox')
  @lazySingleton
  Box<Map> get projectsBox => Hive.box<Map>('projectsBox');

  @Named('audioCommentsBox')
  @lazySingleton
  Box<Map> get audioCommentsBox => Hive.box<Map>('audioCommentsBox');

  @Named('audioTracksBox')
  @lazySingleton
  Box<Map> get audioTracksBox => Hive.box<Map>('audioTracksBox');

  @Named('userProfilesBox')
  @lazySingleton
  Box<Map> get userProfilesBox => Hive.box<Map>('userProfilesBox');
}
