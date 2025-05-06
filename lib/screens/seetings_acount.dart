import 'package:flutter/material.dart';
import 'package:trackflow/widgets/preferences.dart';
import 'package:trackflow/widgets/profile_information.dart';
import 'package:trackflow/widgets/sign_out.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

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
            SizedBox(height: 16),
            // Preferences Card
            Preferences(),
            SizedBox(height: 16),
            // Sign Out Card
            SignOut(),
          ],
        ),
      ),
    );
  }
}
