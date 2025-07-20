import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Detection Tests', () {
    testWidgets('Detect infinite redirect loops', (WidgetTester tester) async {
      // This test detects if the router gets stuck in redirect loops
      app.main();

      // Monitor navigation for a reasonable time
      final startTime = DateTime.now();
      const maxWaitTime = Duration(seconds: 10);

      while (DateTime.now().difference(startTime) < maxWaitTime) {
        await TestUserFlow.waitForNavigation(tester);

        // Check if we're stuck on a loading screen
        final loadingIndicators = find.byType(CircularProgressIndicator);
        if (loadingIndicators.evaluate().isNotEmpty) {
          // Wait a bit more to see if it resolves
          await Future.delayed(const Duration(seconds: 2));
          await TestUserFlow.waitForNavigation(tester);

          // If still loading, this might be an infinite loop
          if (loadingIndicators.evaluate().isNotEmpty) {
            fail(
              'Potential infinite redirect loop detected - app stuck on loading screen',
            );
          }
        }

        // Check if we've reached a stable state
        final authScreen = find.byType(TextFormField);
        final dashboardScreen = find.textContaining('Projects');
        final onboardingScreen = find.textContaining('Welcome');
        final profileScreen = find.textContaining('Create Profile');

        if (authScreen.evaluate().isNotEmpty ||
            dashboardScreen.evaluate().isNotEmpty ||
            onboardingScreen.evaluate().isNotEmpty ||
            profileScreen.evaluate().isNotEmpty) {
          // We've reached a stable screen, break the loop
          break;
        }
      }

      // Verify we're on a valid screen
      final validScreens = [
        find.byType(TextFormField), // Auth screen
        find.textContaining('Projects'), // Dashboard
        find.textContaining('Welcome'), // Onboarding
        find.textContaining('Create Profile'), // Profile creation
      ];

      bool onValidScreen = validScreens.any(
        (finder) => finder.evaluate().isNotEmpty,
      );
      expect(
        onValidScreen,
        true,
        reason: 'App should be on a valid screen after navigation',
      );
    });

    testWidgets('Detect state inconsistencies', (WidgetTester tester) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Test various state combinations that should not occur
      await _testInvalidStateCombinations(tester);
    });

    testWidgets('Detect navigation to invalid routes', (
      WidgetTester tester,
    ) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Test navigation to routes that shouldn't be accessible
      await _testInvalidRouteAccess(tester);
    });

    testWidgets('Detect missing UI elements', (WidgetTester tester) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Test that required UI elements are present
      await _testRequiredUIElements(tester);
    });

    testWidgets('Detect performance issues', (WidgetTester tester) async {
      app.main();

      // Measure time to reach stable state
      final startTime = DateTime.now();
      await TestUserFlow.waitForNavigation(tester);
      final endTime = DateTime.now();

      final navigationTime = endTime.difference(startTime);
      const maxAcceptableTime = Duration(seconds: 5);

      expect(
        navigationTime,
        lessThan(maxAcceptableTime),
        reason: 'Navigation should complete within 5 seconds',
      );
    });

    testWidgets('Detect memory leaks in state management', (
      WidgetTester tester,
    ) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Navigate through multiple screens to test for memory leaks
      await _testMemoryLeaks(tester);
    });

    testWidgets('Detect race conditions', (WidgetTester tester) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Test rapid state changes to detect race conditions
      await _testRaceConditions(tester);
    });
  });
}

/// Helper methods for error detection tests
Future<void> _testInvalidStateCombinations(WidgetTester tester) async {
  // Test combinations of states that should not occur together

  // 1. Authenticated but incomplete onboarding AND incomplete profile
  // This should not happen - if onboarding is incomplete, profile check shouldn't happen yet
  await _testAuthIncompleteOnboardingIncompleteProfile(tester);

  // 2. Unauthenticated but complete profile
  // This should not happen - profile should only exist for authenticated users
  await _testUnauthenticatedCompleteProfile(tester);

  // 3. Authenticated but no profile state
  // This should not happen - authenticated users should have a profile state
  await _testAuthenticatedNoProfileState(tester);
}

Future<void> _testAuthIncompleteOnboardingIncompleteProfile(
  WidgetTester tester,
) async {
  // This test verifies that the router logic correctly handles the priority
  // of onboarding vs profile completion

  // Start the app and complete signup
  await _completeSignUp(tester);
  await TestUserFlow.waitForNavigation(tester);

  // If we're on onboarding, that's correct
  // If we're on profile creation, that's also correct
  // But we shouldn't be on dashboard if onboarding is incomplete

  final onboardingScreen = find.textContaining('Welcome');
  final dashboardScreen = find.textContaining('Projects');

  // Verify we're not on dashboard if onboarding is incomplete
  if (onboardingScreen.evaluate().isNotEmpty) {
    expect(
      dashboardScreen.evaluate().isEmpty,
      true,
      reason: 'Should not be on dashboard if onboarding is incomplete',
    );
  }
}

Future<void> _testUnauthenticatedCompleteProfile(WidgetTester tester) async {
  // This test verifies that unauthenticated users can't access profile-dependent features

  // Start the app (should be unauthenticated)
  await TestUserFlow.waitForNavigation(tester);

  // Verify we're on auth screen, not dashboard
  final authScreen = find.byType(TextFormField);
  final dashboardScreen = find.textContaining('Projects');

  expect(
    authScreen.evaluate().isNotEmpty,
    true,
    reason: 'Unauthenticated user should be on auth screen',
  );
  expect(
    dashboardScreen.evaluate().isEmpty,
    true,
    reason: 'Unauthenticated user should not access dashboard',
  );
}

Future<void> _testAuthenticatedNoProfileState(WidgetTester tester) async {
  // This test verifies that authenticated users always have a profile state

  // Complete signup to become authenticated
  await _completeSignUp(tester);
  await TestUserFlow.waitForNavigation(tester);

  // Verify we're not stuck in a loading state
  final loadingIndicator = find.byType(CircularProgressIndicator);
  expect(
    loadingIndicator.evaluate().isEmpty,
    true,
    reason: 'Authenticated user should not be stuck in loading state',
  );

  // Verify we're on a valid screen
  final validScreens = [
    find.textContaining('Welcome'), // Onboarding
    find.textContaining('Create Profile'), // Profile creation
    find.textContaining('Projects'), // Dashboard
  ];

  bool onValidScreen = validScreens.any(
    (finder) => finder.evaluate().isNotEmpty,
  );
  expect(
    onValidScreen,
    true,
    reason: 'Authenticated user should be on a valid screen',
  );
}

Future<void> _testInvalidRouteAccess(WidgetTester tester) async {
  // Test that users can't access routes they shouldn't have access to

  // Try to access dashboard without authentication
  await TestUserFlow.waitForNavigation(tester);

  // Verify we're not on dashboard (should be on auth)
  final dashboardScreen = find.textContaining('Projects');
  final authScreen = find.byType(TextFormField);

  expect(
    authScreen.evaluate().isNotEmpty,
    true,
    reason: 'Unauthenticated user should be redirected to auth',
  );
  expect(
    dashboardScreen.evaluate().isEmpty,
    true,
    reason: 'Unauthenticated user should not access dashboard',
  );
}

Future<void> _testRequiredUIElements(WidgetTester tester) async {
  // Test that required UI elements are present on each screen

  await TestUserFlow.waitForNavigation(tester);

  // Check current screen and verify required elements
  final authScreen = find.byType(TextFormField);
  final dashboardScreen = find.textContaining('Projects');
  final onboardingScreen = find.textContaining('Welcome');
  final profileScreen = find.textContaining('Create Profile');

  if (authScreen.evaluate().isNotEmpty) {
    // Auth screen should have email and password fields
    expect(find.byType(TextFormField), findsAtLeast(2));
    expect(find.textContaining('Sign In'), findsOneWidget);
    expect(find.textContaining('Sign Up'), findsOneWidget);
  } else if (dashboardScreen.evaluate().isNotEmpty) {
    // Dashboard should have main navigation elements
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  } else if (onboardingScreen.evaluate().isNotEmpty) {
    // Onboarding should have navigation buttons
    expect(find.textContaining('Next'), findsOneWidget);
  } else if (profileScreen.evaluate().isNotEmpty) {
    // Profile creation should have form fields
    expect(find.byType(TextFormField), findsAtLeast(1));
    expect(find.textContaining('Save'), findsOneWidget);
  }
}

Future<void> _testMemoryLeaks(WidgetTester tester) async {
  // Navigate through multiple screens to test for memory leaks

  // Complete the full user flow
  await _completeSignUp(tester);

  final onboardingScreen = find.textContaining('Welcome');
  if (onboardingScreen.evaluate().isNotEmpty) {
    await _completeOnboarding(tester);
  }

  final profileScreen = find.textContaining('Create Profile');
  if (profileScreen.evaluate().isNotEmpty) {
    await _completeProfileCreation(tester);
  }

  // Navigate to different sections
  final settingsButton = find.byIcon(Icons.settings);
  await tester.tap(settingsButton);
  await TestUserFlow.waitForNavigation(tester);

  final profileButton = find.byIcon(Icons.person);
  await tester.tap(profileButton);
  await TestUserFlow.waitForNavigation(tester);

  // Navigate back to dashboard
  final projectsButton = find.byIcon(Icons.folder);
  await tester.tap(projectsButton);
  await TestUserFlow.waitForNavigation(tester);

  // Verify app is still responsive
  expect(find.textContaining('Projects'), findsOneWidget);
}

Future<void> _testRaceConditions(WidgetTester tester) async {
  // Test rapid state changes to detect race conditions

  // Rapidly tap buttons to trigger multiple state changes
  final buttons = find.byType(ElevatedButton);

  for (int i = 0; i < buttons.evaluate().length && i < 3; i++) {
    await tester.tap(buttons.at(i));
    await Future.delayed(const Duration(milliseconds: 100));
  }

  await TestUserFlow.waitForNavigation(tester);

  // Verify app is still in a stable state
  final validScreens = [
    find.byType(TextFormField), // Auth screen
    find.textContaining('Projects'), // Dashboard
    find.textContaining('Welcome'), // Onboarding
    find.textContaining('Create Profile'), // Profile creation
  ];

  bool onValidScreen = validScreens.any(
    (finder) => finder.evaluate().isNotEmpty,
  );
  expect(
    onValidScreen,
    true,
    reason: 'App should remain in stable state after rapid interactions',
  );
}

/// Helper methods for completing user flows
Future<void> _completeSignUp(WidgetTester tester) async {
  final emailField = find.byType(TextFormField).at(0);
  await tester.enterText(emailField, TestUserFlow.testEmail);

  final passwordField = find.byType(TextFormField).at(1);
  await tester.enterText(passwordField, TestUserFlow.testPassword);

  final signUpButton = find.textContaining('Sign Up');
  await tester.tap(signUpButton);
  await TestUserFlow.waitForNavigation(tester);
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  final nextButton = find.textContaining('Next');

  while (nextButton.evaluate().isNotEmpty) {
    await tester.tap(nextButton);
    await TestUserFlow.waitForNavigation(tester);
  }

  final finishButton = find.textContaining('Finish');
  if (finishButton.evaluate().isNotEmpty) {
    await tester.tap(finishButton);
    await TestUserFlow.waitForNavigation(tester);
  }
}

Future<void> _completeProfileCreation(WidgetTester tester) async {
  final nameField = find.byType(TextFormField).at(0);
  await tester.enterText(nameField, TestUserFlow.testName);

  final roleDropdown = find.byType(DropdownButtonFormField);
  if (roleDropdown.evaluate().isNotEmpty) {
    await tester.tap(roleDropdown);
    await TestUserFlow.waitForNavigation(tester);

    final producerOption = find.text('Producer');
    await tester.tap(producerOption);
    await TestUserFlow.waitForNavigation(tester);
  }

  final saveButton = find.textContaining('Save');
  await tester.tap(saveButton);
  await TestUserFlow.waitForNavigation(tester);
}
