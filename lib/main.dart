import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/auth/presentation/pages/auth.dart';
import 'package:trackflow/features/auth/presentation/pages/splash.dart';
import 'package:trackflow/features/home/presentation/pages/dashboard.dart';
import 'package:trackflow/features/onboarding/presentation/pages/launch_screen.dart';
import 'package:trackflow/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      home: FutureBuilder<AppState>(
        future: _determineInitialState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final appState = snapshot.data ?? AppState.launch;

          switch (appState) {
            case AppState.launch:
              return const LaunchScreen();
            case AppState.onboarding:
              return const OnboardingScreen();
            case AppState.auth:
              return const AuthScreen();
            case AppState.dashboard:
              return const DashboardScreen();
          }
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }

  Future<AppState> _determineInitialState() async {
    try {
      // Check if user is already authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return AppState.dashboard;
      }

      // Check if this is a fresh install or reinstall
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding');
      final hasSeenLaunch = prefs.getBool('hasSeenLaunch');

      // Fresh install or reinstall
      if (hasSeenLaunch == null) {
        await prefs.setBool('hasSeenLaunch', true);
        return AppState.launch;
      }

      // Has seen launch but not completed onboarding
      if (hasCompletedOnboarding == null || !hasCompletedOnboarding) {
        return AppState.onboarding;
      }

      // Has completed onboarding but not logged in
      return AppState.auth;
    } catch (e) {
      // If there's an error, start from launch
      return AppState.launch;
    }
  }
}

enum AppState { launch, onboarding, auth, dashboard }
