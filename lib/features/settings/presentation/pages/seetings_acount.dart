import 'package:flutter/material.dart';
import 'package:trackflow/features/settings/presentation/widgets/preferences.dart';
import 'package:trackflow/features/settings/presentation/widgets/profile_information.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information Card
            ProfileInformation(),
            const SizedBox(height: 16),
            // Preferences Card
            const Preferences(),
            const SizedBox(height: 16),
            // Sign Out Card
            const SignOut(),
          ],
        ),
      ),
    );
  }
}
