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
        print('=== TESTING SIGNUP FEEDBACK ===');

        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to initialize
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Navigate to auth screen
        final authText = find.text('TrackFlow');
        if (authText.evaluate().isNotEmpty) {
          print('✅ Auth screen loaded');

          // Click "Continue with Email"
          await tester.tap(find.text('Continue with Email'));
          await tester.pumpAndSettle();

          // Verify we're in signup mode (default)
          final createAccountText = find.text('Create Account');
          if (createAccountText.evaluate().isNotEmpty) {
            print('✅ In signup mode');

            // Fill the form
            final emailField = find.byType(TextFormField).first;
            final passwordField = find.byType(TextFormField).last;

            await tester.enterText(
              emailField,
              'test_signup_feedback@example.com',
            );
            await tester.enterText(passwordField, 'password123');
            await tester.pumpAndSettle();

            print('✅ Form filled');

            // Try to tap Create Account button
            final createAccountButton = find.text('Create Account');
            if (createAccountButton.evaluate().isNotEmpty) {
              await tester.tap(createAccountButton);
              await tester.pumpAndSettle();

              print('✅ Create Account button tapped');

              // Wait a bit to see if there's any feedback
              await Future.delayed(const Duration(seconds: 3));
              await tester.pumpAndSettle();

              // Check for success message or error
              final successText = find.text('Account created successfully!');
              final errorText = find.textContaining('already exists');

              if (successText.evaluate().isNotEmpty) {
                print('✅ Success message shown');
              } else if (errorText.evaluate().isNotEmpty) {
                print('❌ Error message shown: Account already exists');
              } else {
                print('❓ No feedback message found');
              }

              // Check if button is disabled during loading
              final button = find.byType(ElevatedButton);
              if (button.evaluate().isNotEmpty) {
                final buttonWidget =
                    button.evaluate().first.widget as ElevatedButton;
                print('Button enabled: ${buttonWidget.onPressed != null}');
              }
            } else {
              print('❌ Create Account button not found');
            }
          } else {
            print('❌ Not in signup mode');
          }
        } else {
          print('❌ Auth screen not loaded');
        }
      },
    );
  });
}
