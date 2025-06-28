import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/settings/presentation/widgets/preferences.dart';
import 'package:trackflow/features/user_profile/presentation/components/user_profile_information_component.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.auth); // or Navigator.pushReplacement...
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Account Settings")),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const ProfileInformation(),
            const SizedBox(height: 16),
            const Divider(),
            // Preferences Card
            const Preferences(),
            const SizedBox(height: 16),
            // Developer/Debug Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Tools',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.cached),
                      title: const Text('Audio Cache Demo'),
                      subtitle: const Text('Test new audio caching system'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go(AppRoutes.cacheDemo),
                    ),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Storage Management'),
                      subtitle: const Text(
                        'Manage cached audio and storage usage',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.push('/storage-management'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sign Out Card
            const SignOut(),
          ],
        ),
      ),
    );
  }
}
