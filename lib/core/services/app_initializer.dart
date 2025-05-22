import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';
import 'package:trackflow/core/config/firebase_options.dart';
import 'package:trackflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trackflow/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service responsible for initializing all app dependencies and services
class AppInitializer {
  late final SharedPreferences prefs;
  late final AuthRepositoryImpl authRepository;
  late final OnboardingRepositoryImpl onboardingRepository;
  late final ProjectsLocalDataSource projectLocalDataSource;
  late final AppFlowCubit appFlowCubit;
  FirebaseAuth? _firebaseAuth;

  /// Initialize all app dependencies
  Future<void> initialize() async {
    try {
      // Initialize Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase with error handling
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseAuth = FirebaseAuth.instance;
      } catch (e) {
        _firebaseAuth = null;
      }

      // Initialize Hive for local storage
      await Hive.initFlutter();
      await Hive.openBox<Map<String, dynamic>>('projects');

      // Initialize SharedPreferences
      prefs = await SharedPreferences.getInstance();

      // Initialize repositories with potentially null Firebase auth
      authRepository = AuthRepositoryImpl(
        auth: _firebaseAuth,
        googleSignIn: _firebaseAuth != null ? GoogleSignIn() : null,
        prefs: prefs,
      );
      onboardingRepository = OnboardingRepositoryImpl(prefs);
    } catch (e) {
      rethrow;
    }
  }
}
