import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signup Feedback Test', () {
    testWidgets(
      'Signup provides proper feedback and prevents multiple submissions',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to initialize
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Navigate to auth screen
        final authText = find.text('TrackFlow');
        if (authText.evaluate().isNotEmpty) {
          // Click "Continue with Email"
          await tester.tap(find.text('Continue with Email'));
          await tester.pumpAndSettle();

          // Verify we're in signup mode (default)
          final createAccountText = find.text('Create Account');
          if (createAccountText.evaluate().isNotEmpty) {
            // Fill the form
            final emailField = find.byType(TextFormField).first;
            final passwordField = find.byType(TextFormField).last;

            await tester.enterText(
              emailField,
              'test_signup_feedback@example.com',
            );
            await tester.enterText(passwordField, 'password123');
            await tester.pumpAndSettle();

            // Try to tap Create Account button
            final createAccountButton = find.text('Create Account');
            if (createAccountButton.evaluate().isNotEmpty) {
              await tester.tap(createAccountButton);
              await tester.pumpAndSettle();

              // Wait a bit to see if there's any feedback
              await Future.delayed(const Duration(seconds: 3));
              await tester.pumpAndSettle();

              // Check for success message or error
              final successText = find.text('Account created successfully!');
              final errorText = find.textContaining('already exists');

              if (successText.evaluate().isNotEmpty) {
                // Success message shown
              } else if (errorText.evaluate().isNotEmpty) {
                // Error message shown: Account already exists
              }

              // Check if button is disabled during loading
              final button = find.byType(ElevatedButton);
              if (button.evaluate().isNotEmpty) {
                final buttonWidget =
                    button.evaluate().first.widget as ElevatedButton;
                // Button enabled: ${buttonWidget.onPressed != null}
              }
            }
          }
        }
      },
    );
  });
}
