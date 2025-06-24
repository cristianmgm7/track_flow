import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final UserId userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(
      WatchUserProfile(userId: widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artist Profile')),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserProfileLoaded) {
            final profile = state.profile;
            ImageProvider? avatarProvider;
            if (profile.avatarUrl.isNotEmpty) {
              if (Uri.tryParse(profile.avatarUrl)?.isAbsolute == true) {
                avatarProvider = NetworkImage(profile.avatarUrl);
              } else {
                avatarProvider = AssetImage(profile.avatarUrl);
              }
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: avatarProvider,
                      child:
                          avatarProvider == null
                              ? const Icon(Icons.person, size: 56)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Creative Role: ${profile.creativeRole?.name ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project Role: ${profile.role?.toShortString() ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: ${profile.id.value}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined: ${profile.createdAt.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => EditProfileDialog(profile: profile),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            );
          }
          if (state is UserProfileError) {
            return const Center(
              child: Text('An error occurred loading the profile.'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
