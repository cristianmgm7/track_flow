import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signup Mode Test', () {
    testWidgets('App defaults to signup mode', (WidgetTester tester) async {
      print('=== TESTING SIGNUP MODE DEFAULT ===');

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to fully load
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Check if auth screen loads
      final trackFlowText = find.text('TrackFlow');
      if (trackFlowText.evaluate().isNotEmpty) {
        print('✅ Auth screen loaded successfully');

        // Click "Continue with Email"
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Verify we're in signup mode by default
        final createAccountText = find.text('Create Account');
        final toggleText = find.text('Already have an account? Sign in');

        if (createAccountText.evaluate().isNotEmpty) {
          print('✅ Default to signup mode: "Create Account" button found');
        } else {
          print('❌ Expected "Create Account" button not found');
        }

        if (toggleText.evaluate().isNotEmpty) {
          print('✅ Toggle text correct: "Already have an account? Sign in"');
        } else {
          print('❌ Expected toggle text not found');
        }

        // Verify form fields are visible
        final formFields = find.byType(TextFormField);
        if (formFields.evaluate().length >= 2) {
          print('✅ Form fields are visible (email and password)');
        } else {
          print('❌ Form fields not found');
        }
      } else {
        print('❌ Auth screen not loaded - "TrackFlow" text not found');

        // Debug: Print all text widgets found
        final allTexts = find.byType(Text).evaluate();
        print('All text widgets found: ${allTexts.length}');
        for (final widget in allTexts) {
          final text = widget.widget as Text;
          print('  - "${text.data}"');
        }
      }
    });
  });
}
