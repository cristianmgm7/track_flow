import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppFlowBloc, AppFlowState>(
      builder: (context, state) {
        print('🔄 [SplashScreen] Building with state: ${state.runtimeType}');

        if (state is AppFlowLoading && state.progress > 0) {
          print(
            '🔄 [SplashScreen] Showing sync progress: ${(state.progress * 100).toInt()}%',
          );
          // Show sync progress with progress bar
          return AppSplashScreen(
            message: _getSyncMessage(state.progress),
            logo: Image.asset('assets/images/logo.png', height: 100),
            progress: state.progress,
            showProgress: true,
          );
        } else if (state is AppFlowLoading) {
          print('🔄 [SplashScreen] Showing general loading');
          // Show general loading
          return AppSplashScreen(
            message: 'Initializing TrackFlow...',
            logo: Image.asset('assets/images/logo.png', height: 100),
          );
        } else {
          print('🔄 [SplashScreen] Showing default splash');
          // Default splash
          return AppSplashScreen(
            message: 'Welcome to TrackFlow',
            logo: Image.asset('assets/images/logo.png', height: 100),
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
