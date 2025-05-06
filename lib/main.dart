import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/screens/auth.dart';
import 'package:trackflow/screens/dashboard.dart';
import 'package:trackflow/screens/launch_screen.dart';
import 'package:trackflow/screens/onboarding_screen.dart';
import 'package:trackflow/screens/splash.dart';
import 'package:trackflow/theme/theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // If it's the first time, show the launch screen
          if (snapshot.data == true) {
            return const LaunchScreen();
          }

          // Otherwise, check authentication state
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              // If user is authenticated, show dashboard
              if (authSnapshot.hasData) {
                return const DashboardScreen();
              }

              // If user is not authenticated, show auth screen
              return const AuthScreen();
            },
          );
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }

  Future<bool> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding');
      return hasCompletedOnboarding == null || !hasCompletedOnboarding;
    } catch (e) {
      // If there's an error, assume it's first time
      return true;
    }
  }
}
