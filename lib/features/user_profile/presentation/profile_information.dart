import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';

class ProfileInformation extends StatelessWidget {
  final UserProfile profile;

  const ProfileInformation({super.key, required this.profile});

  void _onEditProfile(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        ? Icon(Icons.person, size: 48)
                        : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              profile.creativeRole?.name ?? 'N/A',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("User ID", style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(width: 8),
                SizedBox(
                  width: 150, // Fixed width for the User ID display
                  child: Text(
                    profile.id.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis, // Hide overflow text
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, size: 20),
                  onPressed: () => Share.share(profile.id.value),
                ),
              ],
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _onEditProfile(context, profile),
              child: Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
