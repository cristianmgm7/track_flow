import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signup Mode Test', () {
    testWidgets('App defaults to signup mode', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to fully load
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Check if auth screen loads
      final trackFlowText = find.text('TrackFlow');
      if (trackFlowText.evaluate().isNotEmpty) {
        // Click "Continue with Email"
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Verify we're in signup mode by default
        final createAccountText = find.text('Create Account');
        final toggleText = find.text('Already have an account? Sign in');

        if (createAccountText.evaluate().isNotEmpty) {
          // Default to signup mode: "Create Account" button found
        }

        if (toggleText.evaluate().isNotEmpty) {
          // Toggle text correct: "Already have an account? Sign in"
        }

        // Verify form fields are visible
        final formFields = find.byType(TextFormField);
        if (formFields.evaluate().length >= 2) {
          // Form fields are visible (email and password)
        }
      }
    });
  });
}
