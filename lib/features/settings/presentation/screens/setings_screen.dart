import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/settings/presentation/widgets/preferences.dart';
import 'package:trackflow/features/user_profile/presentation/components/user_profile_information_component.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

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
          children: const [
            ProfileInformation(),
            SizedBox(height: 16),
            Divider(),
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
