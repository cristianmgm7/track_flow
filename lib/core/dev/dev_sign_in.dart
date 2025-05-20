import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';

/// Call this after dependency initialization, before runApp, in main().
Future<void> signInDevUserIfNeeded(BuildContext context) async {
  if (kDebugMode) {
    // Replace with your dev credentials
    const devEmail = 'devuser@example.com';
    const devPassword = 'devpassword123';
    // Dispatch the sign-in event
    context.read<AuthBloc>().add(
      AuthSignInRequested(email: devEmail, password: devPassword),
    );
  }
}
