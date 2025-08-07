import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/utils/flavor_logo_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppFlowBloc, AppFlowState>(
      builder: (context, state) {
        AppLogger.debug(
          'Building with state: ${state.runtimeType}',
          tag: 'SplashScreen',
        );

        if (state is AppFlowLoading && state.progress > 0) {
          AppLogger.debug(
            'Showing sync progress: ${(state.progress * 100).toInt()}%',
            tag: 'SplashScreen',
          );
          // Show sync progress with progress bar
          return AppSplashScreen(
            message: _getSyncMessage(state.progress),
            logo: Image.asset(
              FlavorLogoHelper.getSplashLogoPath(),
              height: 100,
            ),
            progress: state.progress,
            showProgress: true,
          );
        } else if (state is AppFlowLoading) {
          AppLogger.debug('Showing general loading', tag: 'SplashScreen');
          // Show general loading
          return AppSplashScreen(
            message: 'Initializing TrackFlow...',
            logo: Image.asset(
              FlavorLogoHelper.getSplashLogoPath(),
              height: 100,
            ),
          );
        } else {
          AppLogger.debug('Showing default splash', tag: 'SplashScreen');
          // Default splash
          return AppSplashScreen(
            message: 'Welcome to TrackFlow',
            logo: Image.asset(
              FlavorLogoHelper.getSplashLogoPath(),
              height: 100,
            ),
          );
        }
      },
    );
  }

  String _getSyncMessage(double progress) {
    if (progress < 0.3) {
      return 'Syncing user profile...';
    } else if (progress < 0.6) {
      return 'Loading projects...';
    } else if (progress < 0.9) {
      return 'Syncing audio content...';
    } else {
      return 'Almost ready...';
    }
  }
}
