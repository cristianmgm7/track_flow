import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/theme/app_theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/core/app/providers/app_bloc_providers.dart';
import 'package:trackflow/core/app/services/dynamic_link_handler.dart';
import 'package:trackflow/core/app/services/app_initializer.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.getAllProviders(),
      child: const _App(),
    );
  }
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> with WidgetsBindingObserver {
  late final GoRouter _router;
  late final DynamicLinkHandler _dynamicLinkHandler;
  late final AppInitializer _appInitializer;
  late final TriggerForegroundSyncUseCase _triggerForegroundSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  void _initializeApp() {
    AppLogger.info('Initializing app components', tag: 'APP_STATE');

    // Initialize router
    _router = AppRouter.router(context.read());

    // Initialize services
    _dynamicLinkHandler = DynamicLinkHandler(
      dynamicLinkService: sl<DynamicLinkService>(),
      router: _router,
    );

    _appInitializer = AppInitializer(appFlowBloc: context.read());
    _triggerForegroundSync = TriggerForegroundSyncUseCase(
      sl<BackgroundSyncCoordinator>(),
      sl<SessionService>(),
    );

    // Start initialization
    _appInitializer.initialize();
    _dynamicLinkHandler.initialize();

    AppLogger.info('App components initialized successfully', tag: 'APP_STATE');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dynamicLinkHandler.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Persist playback state on backgrounding or app going inactive/detached
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Best-effort save; avoid throwing inside lifecycle callback
      try {
        context.read<AudioPlayerBloc>().add(const SavePlaybackStateRequested());
      } catch (_) {}
    }

    // Trigger foreground sync when app becomes active
    if (state == AppLifecycleState.resumed) {
      // Best-effort sync; avoid throwing inside lifecycle callback
      try {
        _triggerForegroundSync.call();
      } catch (_) {}
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFlow',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
