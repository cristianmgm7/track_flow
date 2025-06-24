import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(Icons.music_note, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Welcome to TrackFlow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'The ultimate platform for artists, producers, and songwriters to collaborate on music projects.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Get Started button
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.onboarding);
                      context.read<AuthBloc>().add(
                        WelcomeScreenMarkCompleted(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(height: 16),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.auth);
                          context.read<AuthBloc>().add(
                            WelcomeScreenMarkCompleted(),
                          );
                        },
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
