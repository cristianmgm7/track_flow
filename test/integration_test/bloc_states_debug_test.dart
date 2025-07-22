import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BLoC States Debug Test', () {
    testWidgets('Debug BLoC states after signup', (WidgetTester tester) async {
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

        // Fill the form
        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(emailField, 'test_bloc_states@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        // Tap Create Account button (find by text and tap the first one)
        final createAccountButtons = find.text('Create Account');
        if (createAccountButtons.evaluate().isNotEmpty) {
          await tester.tap(createAccountButtons.first);
          await tester.pumpAndSettle();

          // Wait for auth to complete
          await Future.delayed(const Duration(seconds: 5));
          await tester.pumpAndSettle();

          // Check what screen we're on now
          final onboardingText = find.textContaining('Welcome to TrackFlow');
          final dashboardText = find.textContaining('Projects');
          final authStillText = find.text('TrackFlow');
          final successText = find.text('Account created successfully!');

          if (onboardingText.evaluate().isNotEmpty) {
            // Navigated to onboarding screen
          } else if (dashboardText.evaluate().isNotEmpty) {
            // Navigated to dashboard
          } else if (authStillText.evaluate().isNotEmpty) {
            // Still on auth screen
            if (successText.evaluate().isNotEmpty) {
              // Success message shown but no navigation
            }
          } else {
            // Navigated to different screen
          }
        }
      }
    });
  });
}
