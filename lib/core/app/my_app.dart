import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'package:trackflow/core/services/service_locator.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    debugPrint('MyApp constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
                  OnboardingBloc(sl<OnboardingRepository>())
                    ..add(OnboardingCheckRequested()),
        ),
        BlocProvider<AppFlowCubit>(
          create:
              (context) => AppFlowCubit(
                authRepository: sl(),
                onboardingRepository: sl(),
              ),
        ),
      ],
      child: _App(),
    );
  }
}

class _App extends StatelessWidget {
  _App() {
    debugPrint('App constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router(context),
    );
  }
}
