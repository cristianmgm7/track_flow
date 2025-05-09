import 'package:flutter/material.dart';

class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool _emailNotifications = true;
  bool _darkMode = false;

  void _handleEmailNotificationsChange(bool value) {
    setState(() {
      _emailNotifications = value;
    });
    // TODO: Implement email notifications logic
  }

  void _handleDarkModeChange(bool value) {
    setState(() {
      _darkMode = value;
    });
    // TODO: Implement dark mode logic
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
                  Icons.settings,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Preferences",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Configure your account preferences",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildPreferenceRow(
              context,
              title: "Email Notifications",
              subtitle: "Receive email updates about your projects",
              value: _emailNotifications,
              onChanged: _handleEmailNotificationsChange,
            ),
            const SizedBox(height: 16),
            _buildPreferenceRow(
              context,
              title: "Dark Mode",
              subtitle: "Toggle between light and dark theme",
              value: _darkMode,
              onChanged: _handleDarkModeChange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
