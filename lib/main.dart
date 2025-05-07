import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/config/firebase_options.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => OnboardingBloc()..add(OnboardingStarted()),
        ),
      ],
      child: MaterialApp.router(
        title: 'TrackFlow',
        theme: AppTheme.theme,
        routerConfig: AppRouter.router(context),
      ),
    );
  }
}
