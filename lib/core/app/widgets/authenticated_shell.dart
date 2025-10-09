import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_event.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Wrapper widget for authenticated shell that triggers initial sync once
///
/// This widget wraps the main app shell and triggers the initial sync
/// exactly once when the user enters the authenticated area of the app.
/// This is the perfect time because:
/// - User is fully authenticated
/// - Profile is set up
/// - Main app is about to be shown
class AuthenticatedShell extends StatefulWidget {
  final Widget child;

  const AuthenticatedShell({super.key, required this.child});

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  bool _syncTriggered = false;

  @override
  void initState() {
    super.initState();

    // Trigger initial sync when shell is first built
    // This happens exactly once when user enters the main app
    if (!_syncTriggered) {
      _syncTriggered = true;

      // Use post-frame callback to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppLogger.info(
            'Triggering initial sync from authenticated shell',
            tag: 'AUTHENTICATED_SHELL',
          );
          context.read<SyncBloc>().add(const StartupSyncRequested());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
