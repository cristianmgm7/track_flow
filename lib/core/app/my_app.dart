import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    debugPrint('MyApp constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<NavigationCubit>(
          create: (context) => sl<NavigationCubit>(),
        ),
        BlocProvider<ProjectsBloc>(create: (context) => sl<ProjectsBloc>()),
        BlocProvider<MagicLinkBloc>(create: (context) => sl<MagicLinkBloc>()),
      ],
      child: _App(),
    );
  }
}

class _App extends StatefulWidget {
  _App() {
    debugPrint('App constructor called');
  }
  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(context.read<AuthBloc>());

    // final dynamicLinkService = getIt<DynamicLinkService>();
    // dynamicLinkService.magicLinkToken.addListener(() {
    //   final token = dynamicLinkService.magicLinkToken.value;
    //   if (token != null && token.isNotEmpty) {
    //     _router.routerDelegate.go('/magic-link/$token');
    //     dynamicLinkService.magicLinkToken.value = null;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}
