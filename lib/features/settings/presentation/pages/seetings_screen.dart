import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:trackflow/features/settings/presentation/blocs/settings_state.dart';
import 'package:trackflow/features/settings/presentation/widgets/preferences.dart';
import 'package:trackflow/features/settings/presentation/widgets/profile_information.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SignedOut) {
          context.go(AppRoutes.auth); // or Navigator.pushReplacement...
        }
        if (state is SignOutError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
