import 'package:flutter/material.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/features/magic_link/presentation/screens/magic_link_handler_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DynamicLinkService().init();
  await Firebase.initializeApp();
  await configureDependencies();
  await Hive.initFlutter();
  await Hive.openBox<Map>('projectsBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to magic link tokens and navigate when received
    DynamicLinkService().magicLinkToken.addListener(() {
      final token = DynamicLinkService().magicLinkToken.value;
      if (token != null && navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => MagicLinkHandlerScreen(token: token),
          ),
        );
        // Optionally clear the token after handling
        DynamicLinkService().magicLinkToken.value = null;
      }
    });
    return MaterialApp(navigatorKey: navigatorKey, home: MyApp());
  }
}
