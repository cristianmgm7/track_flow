import 'package:flutter/material.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/app_initializer.dart';
import 'package:trackflow/core/dev/dev_sign_in.dart';
import 'package:trackflow/core/services/service_locator.dart';

void main({bool testMode = false, bool devSignIn = true}) async {
  debugPrint('main() called with testMode: $testMode');
  final initializer = AppInitializer();
  await initializer.initialize();
  setupProjectDependencies(testMode: testMode);
  await setupAuthDependencies(initializer.prefs);

  // After the first frame, trigger dev sign-in if needed
  if (devSignIn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context =
          WidgetsBinding.instance.focusManager.primaryFocus?.context ??
          WidgetsBinding.instance.rootElement;
      if (context != null) {
        signInDevUserIfNeeded(context);
      }
    });
  }

  runApp(
    MyApp(
      prefs: initializer.prefs,
      onboardingRepository: initializer.onboardingRepository,
      testMode: testMode,
    ),
  );
}
