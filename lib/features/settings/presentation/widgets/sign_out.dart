import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.logout, size: 24, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  "Sign Out",
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "You will be logged out of your account on this device.",
              style: AppTextStyle.bodyMedium.copyWith(color: AppColors.error),
            ),
            SizedBox(height: 16),
            PrimaryButton(
              text: "Sign Out",
              isDestructive: true,
              onPressed: () {
                // Stop audio playbook before signing out
                context.read<AudioPlayerBloc>().add(StopAudioRequested());
                // Use AuthBloc for sign out (BLoC states will be reset automatically)
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
