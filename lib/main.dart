import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/config/firebase_options.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/data/repositories/firestore_project_repository.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/services/app_initializer.dart';

void main() async {
  final initializer = AppInitializer();
  await initializer.initialize();

  runApp(
    MyApp(
      authRepository: initializer.authRepository,
      onboardingRepository: initializer.onboardingRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAuthRepository authRepository;
  final SharedPrefsOnboardingRepository onboardingRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.onboardingRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (context) => AuthBloc(authRepository)..add(AuthCheckRequested()),
        ),
        BlocProvider<ProjectsBloc>(
          create: (context) => ProjectsBloc(FirestoreProjectRepository()),
        ),
        BlocProvider<OnboardingBloc>(
          create:
              (context) =>
                  OnboardingBloc(onboardingRepository)
                    ..add(OnboardingCheckRequested()),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router(context),
    );
  }
}
