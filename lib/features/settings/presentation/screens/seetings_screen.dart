import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/settings/presentation/widgets/preferences.dart';
import 'package:trackflow/features/user_profile/presentation/profile_information.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_events.dart';
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
    context.read<UserProfileBloc>().add(LoadUserProfile());
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<UserProfileBloc, UserProfileState>(
                builder: (context, state) {
                  if (state is UserProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UserProfileLoaded) {
                    return Column(
                      children: [
                        ProfileInformation(profile: state.profile),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
