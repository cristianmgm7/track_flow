import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Debug Test', () {
    testWidgets('Debug authentication flow step by step', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Check if we're on auth screen
      final hasTrackFlowText = find.text('TrackFlow').evaluate().isNotEmpty;
      final hasContinueWithEmail =
          find.text('Continue with Email').evaluate().isNotEmpty;
      final hasContinueWithGoogle =
          find.text('Continue with Google').evaluate().isNotEmpty;

      if (hasTrackFlowText && hasContinueWithEmail && hasContinueWithGoogle) {
        // Try to click "Continue with Email"
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Check if form fields appeared
        final formFieldsAfterClick = find.byType(TextFormField).evaluate();

        if (formFieldsAfterClick.isNotEmpty) {
          // Try to fill the form
          final emailField = find.byType(TextFormField).first;
          final passwordField = find.byType(TextFormField).last;

          await tester.enterText(emailField, 'test@example.com');
          await tester.enterText(passwordField, 'password123');
          await tester.pumpAndSettle();

          // Look for the toggle button to switch to signup mode
          final toggleButton = find.text('Need an account? Sign up');
          if (toggleButton.evaluate().isNotEmpty) {
            await tester.tap(toggleButton);
            await tester.pumpAndSettle();

            // Now look for "Create Account" button
            final createAccountButton = find.text('Create Account');
            if (createAccountButton.evaluate().isNotEmpty) {
              await tester.tap(createAccountButton);
              await tester.pumpAndSettle();

              // Wait a bit and check what happened
              await Future.delayed(const Duration(seconds: 2));
              await tester.pumpAndSettle();
            }
          }
        }
      }
    });
  });
}
