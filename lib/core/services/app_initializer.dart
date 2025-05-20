import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/config/firebase_options.dart';
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service responsible for initializing all app dependencies and services
class AppInitializer {
  late final SharedPreferences prefs;
  late final FirebaseAuthRepository authRepository;
  late final SharedPrefsOnboardingRepository onboardingRepository;
  late final HiveProjectLocalDataSource projectLocalDataSource;
  FirebaseAuth? _firebaseAuth;

  /// Initialize all app dependencies
  Future<void> initialize() async {
    try {
      debugPrint('AppInitializer: Starting initialization');
      // Initialize Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint('AppInitializer: Flutter bindings initialized');

      // Initialize Firebase with error handling
      try {
        debugPrint('AppInitializer: Initializing Firebase');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseAuth = FirebaseAuth.instance;
        debugPrint('AppInitializer: Firebase initialized');
      } catch (e) {
        debugPrint('Firebase initialization failed: $e');
        _firebaseAuth = null;
        debugPrint('AppInitializer: Firebase failed, continuing');
      }

      // Initialize Hive for local storage
      debugPrint('AppInitializer: Initializing Hive');
      await Hive.initFlutter();
      await Hive.openBox<Map<String, dynamic>>('projects');
      debugPrint('AppInitializer: Hive initialized (disabled)');

      // Initialize SharedPreferences
      debugPrint('AppInitializer: Initializing SharedPreferences');
      prefs = await SharedPreferences.getInstance();
      debugPrint('AppInitializer: SharedPreferences initialized');

      // Initialize repositories with potentially null Firebase auth
      debugPrint('AppInitializer: Initializing repositories');
      authRepository = FirebaseAuthRepository(
        auth: _firebaseAuth,
        googleSignIn: _firebaseAuth != null ? GoogleSignIn() : null,
        prefs: prefs,
      );
      onboardingRepository = SharedPrefsOnboardingRepository(prefs);
      debugPrint('AppInitializer: Repositories initialized');
    } catch (e) {
      debugPrint('App initialization error: $e');
      debugPrint('AppInitializer: Error during initialization: $e');
      rethrow;
    }
  }
}
