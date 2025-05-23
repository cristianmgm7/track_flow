import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/app_initializer.dart';
import 'package:trackflow/core/services/injection.dart';
import 'package:trackflow/core/services/service_locator.dart';

void main() async {
  final initializer = AppInitializer();
  await initializer.initialize();
  await Hive.initFlutter();
  sl.registerLazySingleton<SharedPreferences>(() => initializer.prefs);
  setupProjectDependencies();
  setupAuthDependencies(initializer.prefs);

  await configureDependencies();

  runApp(MyApp());
}
