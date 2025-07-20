import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Debug Flow Test', () {
    testWidgets('Debug app flow and find actual UI elements', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait a bit for initialization
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Take a screenshot for visual debugging
      await tester.pumpAndSettle();
    });
  });
}
