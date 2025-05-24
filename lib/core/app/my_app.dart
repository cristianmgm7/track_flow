import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    debugPrint('MyApp constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppFlowCubit>(create: (context) => sl<AppFlowCubit>()),
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        BlocProvider<ProjectsBloc>(create: (context) => sl<ProjectsBloc>()),
        BlocProvider<OnboardingBloc>(create: (context) => sl<OnboardingBloc>()),
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
