import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/auth/presentation/pages/auth.dart';
import 'package:trackflow/features/home/presentation/pages/dashboard.dart';
import 'package:trackflow/features/onboarding/presentation/pages/launch_screen.dart';
import 'package:trackflow/features/onboarding/presentation/pages/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LaunchScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
