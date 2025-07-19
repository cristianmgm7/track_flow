import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSplashScreen(
      message: 'Initializing TrackFlow...',
      logo: Image.asset('assets/images/logo.png', height: 100),
    );
  }
}
