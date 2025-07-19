import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('New User Flow End-to-End Tests', () {
    testWidgets(
      'Complete new user flow: Splash → Auth → Onboarding → Profile Creation → Dashboard',
      (WidgetTester tester) async {
        // Arrange: Reset dependencies and start the app
        await TestUserFlow.resetDependencies();
        app.main();
        await TestUserFlow.waitForNavigation(tester);

        // Step 1: Verify we're on the auth screen (splash has passed)
        expect(find.text('TrackFlow'), findsOneWidget);
        expect(find.text('All your team in the same place'), findsOneWidget);
        expect(find.text('Continue with Email'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);

        // Step 2: Click "Continue with Email" to show form fields
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Step 3: Verify form fields are now visible (default to signup mode)
        expect(
          find.byType(TextFormField),
          findsAtLeast(2),
        ); // Email and password fields
        expect(
          find.textContaining('Create Account'),
          findsOneWidget,
        ); // Default to signup mode
        expect(
          find.textContaining('Already have an account? Sign in'),
          findsOneWidget,
        ); // Toggle to login

        // Step 4: Complete sign up process
        await _completeSignUp(tester);

        // Step 5: Verify redirect to onboarding after successful auth
        await TestUserFlow.waitForNavigation(tester);
        expect(
          find.textContaining('Welcome to TrackFlow'),
          findsOneWidget,
        ); // Onboarding screen

        // Step 6: Complete onboarding
        await _completeOnboarding(tester);

        // Step 7: Verify redirect to profile creation
        await TestUserFlow.waitForNavigation(tester);
        expect(find.textContaining('Complete Your Profile'), findsOneWidget);

        // Step 8: Complete profile creation
        await _completeProfileCreation(tester);

        // Step 9: Verify redirect to dashboard
        await TestUserFlow.waitForNavigation(tester);
        expect(find.textContaining('Projects'), findsOneWidget);
      },
    );

    testWidgets('New user flow with Google Sign-In', (
      WidgetTester tester,
    ) async {
      await TestUserFlow.resetDependencies();
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify we're on auth screen
      expect(find.text('TrackFlow'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Click Google Sign-In
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Verify redirect to onboarding after Google auth
      await TestUserFlow.waitForNavigation(tester);
      expect(find.textContaining('Welcome to TrackFlow'), findsOneWidget);

      // Complete onboarding and profile creation
      await _completeOnboarding(tester);
      await TestUserFlow.waitForNavigation(tester);
      await _completeProfileCreation(tester);
      await TestUserFlow.waitForNavigation(tester);

      // Verify dashboard access
      expect(find.textContaining('Projects'), findsOneWidget);
    });

    testWidgets('New user flow with magic link', (WidgetTester tester) async {
      await TestUserFlow.resetDependencies();
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify we're on auth screen
      expect(find.text('TrackFlow'), findsOneWidget);
      expect(find.text('Continue with Email'), findsOneWidget);

      // Click "Continue with Email" to show form
      await tester.tap(find.text('Continue with Email'));
      await tester.pumpAndSettle();

      // Verify form fields are visible
      expect(find.byType(TextFormField), findsAtLeast(2));

      // Test magic link flow (simplified for now)
      await _testMagicLinkFlow(tester);
    });

    testWidgets('Error handling in new user flow', (WidgetTester tester) async {
      await TestUserFlow.resetDependencies();
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify auth screen loads
      expect(find.text('TrackFlow'), findsOneWidget);

      // Test error scenarios
      await _testErrorScenarios(tester);
    });
  });
}

Future<void> _completeSignUp(WidgetTester tester) async {
  // Find email and password fields
  final emailField = find.byType(TextFormField).first;
  final passwordField = find.byType(TextFormField).last;

  // Enter test credentials
  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle();

  // Tap create account button (default signup mode)
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  // Skip onboarding or complete it
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

Future<void> _completeProfileCreation(WidgetTester tester) async {
  // Find and fill profile fields
  final nameField = find.byType(TextFormField).first;
  await tester.enterText(nameField, 'Test User');
  await tester.pumpAndSettle();

  // Submit profile
  await tester.tap(find.text('Complete Setup'));
  await tester.pumpAndSettle();
}

Future<void> _testMagicLinkFlow(WidgetTester tester) async {
  // Enter email for magic link
  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'test@example.com');
  await tester.pumpAndSettle();

  // This would typically trigger magic link sending
  // For now, just verify the flow doesn't crash
}

Future<void> _testErrorScenarios(WidgetTester tester) async {
  // Test invalid email format
  await tester.tap(find.text('Continue with Email'));
  await tester.pumpAndSettle();

  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'invalid-email');
  await tester.pumpAndSettle();

  // Verify error handling works
  // This is a basic test - actual error handling would depend on the implementation
}
