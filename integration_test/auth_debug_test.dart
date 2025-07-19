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
      print('=== STARTING AUTH DEBUG TEST ===');

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      print('App started, waiting for initialization...');
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Debug: Print all text widgets found
      print('\n=== CURRENT UI STATE ===');
      final textWidgets = find.byType(Text).evaluate();
      print('Found ${textWidgets.length} text widgets:');

      for (final widget in textWidgets) {
        final text = widget.widget as Text;
        print('  - "${text.data}"');
      }

      // Debug: Print all buttons found
      print('\n=== BUTTONS FOUND ===');
      final buttons = find.byType(ElevatedButton).evaluate();
      print('Found ${buttons.length} ElevatedButton widgets');

      for (final widget in buttons) {
        final button = widget.widget as ElevatedButton;
        if (button.child is Text) {
          final text = button.child as Text;
          print('  - Button: "${text.data}"');
        }
      }

      // Debug: Print all form fields found
      print('\n=== FORM FIELDS FOUND ===');
      final formFields = find.byType(TextFormField).evaluate();
      print('Found ${formFields.length} TextFormField widgets');

      // Debug: Check if we're on auth screen
      print('\n=== AUTH SCREEN CHECK ===');
      final hasTrackFlowText = find.text('TrackFlow').evaluate().isNotEmpty;
      final hasContinueWithEmail =
          find.text('Continue with Email').evaluate().isNotEmpty;
      final hasContinueWithGoogle =
          find.text('Continue with Google').evaluate().isNotEmpty;

      print('Has "TrackFlow" text: $hasTrackFlowText');
      print('Has "Continue with Email" text: $hasContinueWithEmail');
      print('Has "Continue with Google" text: $hasContinueWithGoogle');

      if (hasTrackFlowText && hasContinueWithEmail && hasContinueWithGoogle) {
        print('✅ App is on auth screen correctly');

        // Try to click "Continue with Email"
        print('\n=== TESTING "Continue with Email" CLICK ===');
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Check if form fields appeared
        final formFieldsAfterClick = find.byType(TextFormField).evaluate();
        print('Form fields after click: ${formFieldsAfterClick.length}');

        if (formFieldsAfterClick.isNotEmpty) {
          print('✅ Form fields appeared after clicking "Continue with Email"');

          // Try to fill the form
          print('\n=== TESTING FORM FILLING ===');
          final emailField = find.byType(TextFormField).first;
          final passwordField = find.byType(TextFormField).last;

          await tester.enterText(emailField, 'test@example.com');
          await tester.enterText(passwordField, 'password123');
          await tester.pumpAndSettle();

          print('✅ Form filled successfully');

          // Check what buttons are available
          print('\n=== CHECKING AVAILABLE BUTTONS ===');
          final allButtons = find.byType(ElevatedButton).evaluate();
          print('Found ${allButtons.length} ElevatedButton widgets');

          final allTextButtons = find.byType(TextButton).evaluate();
          print('Found ${allTextButtons.length} TextButton widgets');

          // Look for the toggle button to switch to signup mode
          print('\n=== LOOKING FOR TOGGLE BUTTON ===');
          final toggleButton = find.text('Need an account? Sign up');
          if (toggleButton.evaluate().isNotEmpty) {
            print('✅ Found toggle button, switching to signup mode');
            await tester.tap(toggleButton);
            await tester.pumpAndSettle();

            // Now look for "Create Account" button
            final createAccountButton = find.text('Create Account');
            if (createAccountButton.evaluate().isNotEmpty) {
              print('✅ Found "Create Account" button, clicking it');
              await tester.tap(createAccountButton);
              await tester.pumpAndSettle();

              print('✅ Create Account button clicked');

              // Wait a bit and check what happened
              await Future.delayed(const Duration(seconds: 2));
              await tester.pumpAndSettle();

              final textAfterSignUp = find.byType(Text).evaluate();
              print('Text widgets after sign up: ${textAfterSignUp.length}');
              for (final widget in textAfterSignUp) {
                final text = widget.widget as Text;
                print('  - "${text.data}"');
              }
            } else {
              print('❌ "Create Account" button not found after toggle');
            }
          } else {
            print('❌ Toggle button not found');

            // Try to find any button with "Sign" in the text
            final signButtons = find.textContaining('Sign').evaluate();
            print('Found ${signButtons.length} buttons with "Sign" in text');
            for (final widget in signButtons) {
              final text = widget.widget as Text;
              print('  - "${text.data}"');
            }
          }
        } else {
          print(
            '❌ Form fields did not appear after clicking "Continue with Email"',
          );
        }
      } else {
        print('❌ App is NOT on auth screen correctly');
        print(
          'This explains why the app gets stuck - it\'s not loading the auth screen properly',
        );
      }

      print('\n=== AUTH DEBUG TEST COMPLETED ===');
    });
  });
}
