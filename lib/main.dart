import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/core/services/app_initializer.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'package:trackflow/core/services/service_locator.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

void main() async {
  final initializer = AppInitializer();
  await initializer.initialize();
  setupProjectDependencies();
  runApp(
    MyApp(
      authRepository: initializer.authRepository,
      onboardingRepository: initializer.onboardingRepository,
      prefs: initializer.prefs,
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAuthRepository authRepository;
  final SharedPrefsOnboardingRepository onboardingRepository;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.onboardingRepository,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: prefs)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(authRepository)..add(AuthCheckRequested()),
          ),
          BlocProvider<ProjectsBloc>(
            create: (context) => ProjectsBloc(sl<ProjectUseCases>()),
          ),
          BlocProvider<OnboardingBloc>(
            create:
                (context) =>
                    OnboardingBloc(onboardingRepository)
                      ..add(OnboardingCheckRequested()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated && state.user != null) {
              context.read<ProjectsBloc>().currentUserId = state.user!.uid;
            }
            if (state is AuthUnauthenticated) {
              context.read<ProjectsBloc>().currentUserId = null;
            }
          },
          child: const App(),
        ),
      ),
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
