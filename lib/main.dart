import 'package:flutter/material.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  await Hive.initFlutter();
  var box = await Hive.openBox<Map<String, dynamic>>('projectsBox');
  await box.clear();
  runApp(MyApp());
}
