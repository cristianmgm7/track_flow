import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 24,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(width: 8),
                Text(
                  "Sign Out",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "You will be logged out of your account on this device.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                // Stop audio playback before signing out
                context.read<AudioPlayerBloc>().add(StopAudioRequested());
                // Use AppFlowBloc for coordinated sign out
                context.read<AppFlowBloc>().add(SignOutRequested());
                context.read<NavigationCubit>().reset();
              },
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
