import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BLoC States Debug Test', () {
    testWidgets('Debug BLoC states after signup', (WidgetTester tester) async {
      print('=== DEBUGGING BLOC STATES AFTER SIGNUP ===');

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

        // Fill the form
        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(emailField, 'test_bloc_states@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        print('✅ Form filled');

        // Tap Create Account button (find by text and tap the first one)
        final createAccountButtons = find.text('Create Account');
        if (createAccountButtons.evaluate().isNotEmpty) {
          await tester.tap(createAccountButtons.first);
          await tester.pumpAndSettle();

          print('✅ Create Account button tapped');

          // Wait for auth to complete
          await Future.delayed(const Duration(seconds: 5));
          await tester.pumpAndSettle();

          // Check what screen we're on now
          final onboardingText = find.textContaining('Welcome to TrackFlow');
          final dashboardText = find.textContaining('Projects');
          final authStillText = find.text('TrackFlow');
          final successText = find.text('Account created successfully!');

          if (onboardingText.evaluate().isNotEmpty) {
            print('✅ Navigated to onboarding screen - COORDINATOR WORKING!');
          } else if (dashboardText.evaluate().isNotEmpty) {
            print('✅ Navigated to dashboard - COORDINATOR WORKING!');
          } else if (authStillText.evaluate().isNotEmpty) {
            print('❌ Still on auth screen - navigation failed');

            if (successText.evaluate().isNotEmpty) {
              print('✅ Success message shown but no navigation');
            } else {
              print('❌ No success message shown');
            }
          } else {
            print('✅ Navigated to different screen - COORDINATOR WORKING!');
            print(
              '   (App is no longer on auth screen, which means navigation succeeded)',
            );
          }
        } else {
          print('❌ Create Account button not found');
        }
      } else {
        print('❌ Auth screen not loaded');
      }
    });
  });
}
