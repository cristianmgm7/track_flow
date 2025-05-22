import 'package:flutter/material.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(MyApp());
}
