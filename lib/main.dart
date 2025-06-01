import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  await DynamicLinkService().init();
  await Hive.initFlutter();
  // SOLO EN DESARROLLO: Borra el box antes de abrirlo
  //await Hive.deleteBoxFromDisk('projectsBox');
  await Hive.openBox<Map>('projectsBox');
  runApp(MyApp());
}
