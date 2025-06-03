import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _copyUserId(BuildContext context, String userId) {
    Clipboard.setData(ClipboardData(text: userId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('User ID copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
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
            Text(profile.name, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8),
            Text("Email", style: Theme.of(context).textTheme.bodyMedium),
            Text(profile.email, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8),
            Text(
              "Creative Role",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              profile.creativeRole?.name ?? 'N/A',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Row(
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
                  icon: Icon(Icons.copy, size: 20),
                  onPressed: () => _copyUserId(context, profile.id.value),
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
