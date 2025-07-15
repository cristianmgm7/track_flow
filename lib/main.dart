import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  await DynamicLinkService().init();

  runApp(MyApp());
}
