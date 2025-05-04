import 'package:flutter/material.dart';

class Preferences extends StatelessWidget {
  const Preferences({super.key});

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
                  Icons.settings,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  "Preferences",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Configure your account preferences",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email Notifications",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "Receive email updates about your projects",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Switch(
                  value: true, // Replace with actual state
                  onChanged: (value) {
                    // Handle toggle logic
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dark Mode",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "Toggle between light and dark theme",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Switch(
                  value: false, // Replace with actual state
                  onChanged: (value) {
                    // Handle toggle logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
