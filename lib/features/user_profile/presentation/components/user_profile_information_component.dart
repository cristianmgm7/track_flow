import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({super.key});

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(WatchUserProfile(userId: null));
  }

  void _onEditProfile(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
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
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: avatarProvider,
                      child:
                          avatarProvider == null
                              ? const Icon(Icons.person, size: 48)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.creativeRole?.name ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "User ID",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150, // Fixed width for the User ID display
                        child: Text(
                          profile.id.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis, // Hide overflow text
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        onPressed: () => Share.share(profile.id.value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _onEditProfile(context, profile),
                    child: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is UserProfileError) {
          return const Center(child: Text("An error occurred."));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
