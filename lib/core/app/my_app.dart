import 'package:flutter/material.dart';
import 'package:trackflow/core/coordination/app_flow_%20events.dart';
import 'package:trackflow/core/theme/app_theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/core/coordination/app_flow_bloc.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    // App constructor called
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<OnboardingBloc>(create: (context) => sl<OnboardingBloc>()),
        BlocProvider<UserProfileBloc>(
          create: (context) => sl<UserProfileBloc>(),
        ),
        BlocProvider<AppFlowBloc>(create: (context) => sl<AppFlowBloc>()),
        BlocProvider<NavigationCubit>(
          create: (context) => sl<NavigationCubit>(),
        ),
        BlocProvider<MagicLinkBloc>(create: (context) => sl<MagicLinkBloc>()),
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
        BlocProvider<AudioWaveformBloc>(
          create: (context) => sl<AudioWaveformBloc>(),
        ),
      ],
      child: _App(),
    );
  }
}

class _App extends StatefulWidget {
  _App() {
    // App constructor called
  }
  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  late final GoRouter _router;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    print('🔄 [MyApp] initState() called');
    _router = AppRouter.router(context.read<AppFlowBloc>());

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
    print('🔄 [MyApp] build() called');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔄 [MyApp] AuthBloc state changed: ${state.runtimeType}');
        print('🔄 [MyApp] _hasInitialized: $_hasInitialized');

        if (state is AuthAuthenticated && !_hasInitialized) {
          print(
            '🔄 [MyApp] User authenticated and not initialized, triggering AppFlow',
          );
          _hasInitialized = true;
          // AppFlowBloc now handles sync internally - just trigger the flow
          context.read<AppFlowBloc>().add(CheckAppFlow());
        } else if (state is AuthUnauthenticated && !_hasInitialized) {
          print(
            '🔄 [MyApp] User unauthenticated and not initialized, triggering AppFlow',
          );
          _hasInitialized = true;
          // For unauthenticated users, check app flow immediately
          context.read<AppFlowBloc>().add(CheckAppFlow());
        } else if (state is AuthUnauthenticated && _hasInitialized) {
          print(
            '🔄 [MyApp] User signed out after initialization, notifying AppFlowBloc',
          );
          // User signed out after initialization, notify AppFlowBloc
          context.read<AppFlowBloc>().add(UserSignedOut());
        } else {
          print(
            '🔄 [MyApp] State change ignored: ${state.runtimeType} with _hasInitialized: $_hasInitialized',
          );
        }
      },
      child: MaterialApp.router(
        title: 'TrackFlow',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
