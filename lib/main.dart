import 'package:flutter/material.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/app_initializer.dart';
import 'package:trackflow/core/services/service_locator.dart';

void main() async {
  final initializer = AppInitializer();
  await initializer.initialize();
  setupProjectDependencies();
  await setupAuthDependencies(initializer.prefs);

  runApp(
    MyApp(
      prefs: initializer.prefs,
      onboardingRepository: initializer.onboardingRepository,
    ),
  );
}
