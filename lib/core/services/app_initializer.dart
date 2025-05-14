import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/config/firebase_options.dart';
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service responsible for initializing all app dependencies and services
class AppInitializer {
  late final SharedPreferences prefs;
  late final FirebaseAuthRepository authRepository;
  late final SharedPrefsOnboardingRepository onboardingRepository;
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
        debugPrint('Firebase initialization failed: $e');
        _firebaseAuth = null;
        // Continue app initialization even if Firebase fails
        // This allows the app to work in offline mode or when Google Play Services are not available
      }

      // Initialize Hive for local storage
      await Hive.initFlutter();
      await Hive.openBox<Map<String, dynamic>>('projects');

      // Initialize SharedPreferences
      prefs = await SharedPreferences.getInstance();

      // Initialize repositories with potentially null Firebase auth
      authRepository = FirebaseAuthRepository(
        auth: _firebaseAuth,
        googleSignIn: _firebaseAuth != null ? GoogleSignIn() : null,
        prefs: prefs,
      );
      onboardingRepository = SharedPrefsOnboardingRepository(prefs);
    } catch (e) {
      debugPrint('App initialization error: $e');
      rethrow;
    }
  }
}
