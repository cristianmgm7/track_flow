import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';

class ProfileInformation extends StatelessWidget {
  const ProfileInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserProfileLoaded) {
          final profile = state.profile;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Profile Information",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Manage your personal information",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Text("Name", style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text("Email", style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // Handle edit profile logic
                    },
                    child: Text("Edit Profile"),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink(); // or show error state
      },
    );
  }
}
