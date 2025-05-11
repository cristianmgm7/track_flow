import 'package:firebase_core/firebase_core.dart';
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

  /// Initialize all app dependencies
  Future<void> initialize() async {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Hive
    await Hive.initFlutter();
    await Hive.openBox<Map<String, dynamic>>('projects');

    // Initialize SharedPreferences
    prefs = await SharedPreferences.getInstance();

    // Initialize repositories
    authRepository = FirebaseAuthRepository(prefs: prefs);
    onboardingRepository = SharedPrefsOnboardingRepository(prefs);
  }
}
