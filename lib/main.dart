import 'package:flutter/material.dart';
import 'package:trackflow/screens/auth.dart';
import 'package:trackflow/theme/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      home: const AuthScreen(),
    );
  }
}
