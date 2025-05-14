import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/router/app_router.dart';
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
import 'package:trackflow/features/auth/domain/usecases/auth_usecases.dart';

void main() async {
  final initializer = AppInitializer();
  await initializer.initialize();
  setupProjectDependencies();
  await setupAuthDependencies();
  runApp(
    MyApp(
      prefs: initializer.prefs,
      onboardingRepository: initializer.onboardingRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final SharedPrefsOnboardingRepository onboardingRepository;

  const MyApp({
    super.key,
    required this.prefs,
    required this.onboardingRepository,
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
                    AuthBloc(sl<AuthUseCases>())..add(AuthCheckRequested()),
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
            if (state is AuthAuthenticated) {
              context.read<ProjectsBloc>().currentUserId = state.user.id;
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
