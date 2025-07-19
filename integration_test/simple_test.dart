import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple App Test', () {
    testWidgets('App starts without dependency injection errors', (
      WidgetTester tester,
    ) async {
      // Reset dependencies first
      await TestUserFlow.resetDependencies();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait a bit for initialization
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Just verify the app doesn't crash
      print('App started successfully without crashes');

      // Check if any text is visible
      final textWidgets = find.byType(Text).evaluate();
      print('Found ${textWidgets.length} text widgets');

      for (final widget in textWidgets) {
        final text = widget.widget as Text;
        print('Text: "${text.data}"');
      }
    });
  });
}
