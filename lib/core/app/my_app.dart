import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';

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
        BlocProvider<UserProfileBloc>(
          create: (context) => sl<UserProfileBloc>(),
        ),
        BlocProvider<NavigationCubit>(
          create: (context) => sl<NavigationCubit>(),
        ),
        BlocProvider<ProjectsBloc>(create: (context) => sl<ProjectsBloc>()),
        BlocProvider<MagicLinkBloc>(create: (context) => sl<MagicLinkBloc>()),
        BlocProvider<ProjectDetailBloc>(
          create: (context) => sl<ProjectDetailBloc>(),
        ),
        BlocProvider<ManageCollaboratorsBloc>(
          create: (context) => sl<ManageCollaboratorsBloc>(),
        ),
        BlocProvider<AudioTrackBloc>(create: (context) => sl<AudioTrackBloc>()),
        BlocProvider<AudioCommentBloc>(
          create: (context) => sl<AudioCommentBloc>(),
        ),
        BlocProvider<AudioPlayerBloc>(
          create: (context) => sl<AudioPlayerBloc>(),
        ),
        BlocProvider<FabContextCubit>(
          create: (context) => sl<FabContextCubit>(),
        ),
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

    // Escuchar el dynamic link
    final dynamicLinkService = sl<DynamicLinkService>();
    dynamicLinkService.magicLinkToken.addListener(() {
      final token = dynamicLinkService.magicLinkToken.value;
      if (token != null && token.isNotEmpty) {
        // Navegar a la pantalla de manejo del magic link (ajusta la ruta cuando la tengas)
        _router.go(AppRoutes.magicLink);
        // Limpiar el token después de manejarlo
        dynamicLinkService.magicLinkToken.value = null;
      }
    });
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
