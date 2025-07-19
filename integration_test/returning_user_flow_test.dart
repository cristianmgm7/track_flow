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

  group('Returning User Flow End-to-End Tests', () {
    testWidgets('Returning user with complete profile: Splash → Dashboard', (
      WidgetTester tester,
    ) async {
      // Arrange: Start the app
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Step 1: Verify we start at splash screen
      expect(find.text('Welcome to TrackFlow'), findsOneWidget);

      // Step 2: Wait for initial state checks and verify direct redirect to dashboard
      await TestUserFlow.waitForNavigation(tester);

      // Verify we're directly on dashboard (returning user should skip auth/onboarding/profile)
      expect(find.textContaining('Projects'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Add project button

      // Step 3: Verify user data is loaded
      await _verifyUserDataLoaded(tester);

      // Step 4: Verify all main app features are accessible
      await _verifyMainAppAccess(tester);
    });

    testWidgets(
      'Returning user with incomplete profile: Splash → Profile Creation → Dashboard',
      (WidgetTester tester) async {
        app.main();
        await TestUserFlow.waitForNavigation(tester);

        // Step 1: Verify splash screen
        expect(find.text('Welcome to TrackFlow'), findsOneWidget);

        // Step 2: Wait for state checks and verify redirect to profile creation
        await TestUserFlow.waitForNavigation(tester);

        // Verify we're on profile creation screen (user authenticated but incomplete profile)
        expect(find.textContaining('Create Profile'), findsOneWidget);

        // Step 3: Complete profile creation
        await _completeProfileCreation(tester);

        // Step 4: Verify redirect to dashboard
        await TestUserFlow.waitForNavigation(tester);
        expect(find.textContaining('Projects'), findsOneWidget);
      },
    );

    testWidgets(
      'Returning user with incomplete onboarding: Splash → Onboarding → Profile Creation → Dashboard',
      (WidgetTester tester) async {
        app.main();
        await TestUserFlow.waitForNavigation(tester);

        // Step 1: Verify splash screen
        expect(find.text('Welcome to TrackFlow'), findsOneWidget);

        // Step 2: Wait for state checks and verify redirect to onboarding
        await TestUserFlow.waitForNavigation(tester);

        // Verify we're on onboarding screen (user authenticated but incomplete onboarding)
        expect(find.textContaining('Welcome'), findsOneWidget);

        // Step 3: Complete onboarding
        await _completeOnboarding(tester);

        // Step 4: Verify redirect to profile creation
        await TestUserFlow.waitForNavigation(tester);
        expect(find.textContaining('Create Profile'), findsOneWidget);

        // Step 5: Complete profile creation
        await _completeProfileCreation(tester);

        // Step 6: Verify redirect to dashboard
        await TestUserFlow.waitForNavigation(tester);
        expect(find.textContaining('Projects'), findsOneWidget);
      },
    );

    testWidgets('Returning user session persistence', (
      WidgetTester tester,
    ) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify direct access to dashboard
      expect(find.textContaining('Projects'), findsOneWidget);

      // Test app restart - should still be logged in
      await _testSessionPersistence(tester);
    });

    testWidgets('Returning user offline mode', (WidgetTester tester) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify dashboard access
      expect(find.textContaining('Projects'), findsOneWidget);

      // Test offline functionality
      await _testOfflineMode(tester);
    });

    testWidgets('Returning user data synchronization', (
      WidgetTester tester,
    ) async {
      app.main();
      await TestUserFlow.waitForNavigation(tester);

      // Verify dashboard access
      expect(find.textContaining('Projects'), findsOneWidget);

      // Test data sync after returning
      await _testDataSynchronization(tester);
    });
  });
}

/// Helper methods for returning user flow tests
Future<void> _verifyUserDataLoaded(WidgetTester tester) async {
  // Verify user profile is loaded
  final userProfileButton = find.byIcon(Icons.person);
  await tester.tap(userProfileButton);
  await TestUserFlow.waitForNavigation(tester);

  // Verify profile information is displayed
  expect(find.text(TestUserFlow.testName), findsOneWidget);
  expect(find.text(TestUserFlow.testCreativeRole), findsOneWidget);
}

Future<void> _verifyMainAppAccess(WidgetTester tester) async {
  // Test projects section
  expect(find.textContaining('Projects'), findsOneWidget);

  // Test settings access
  final settingsButton = find.byIcon(Icons.settings);
  await tester.tap(settingsButton);
  await TestUserFlow.waitForNavigation(tester);
  expect(find.textContaining('Settings'), findsOneWidget);

  // Test notifications access
  final notificationsButton = find.byIcon(Icons.notifications);
  await tester.tap(notificationsButton);
  await TestUserFlow.waitForNavigation(tester);
  expect(find.textContaining('Notifications'), findsOneWidget);

  // Test user profile access
  final profileButton = find.byIcon(Icons.person);
  await tester.tap(profileButton);
  await TestUserFlow.waitForNavigation(tester);
  expect(find.textContaining('Profile'), findsOneWidget);
}

Future<void> _completeProfileCreation(WidgetTester tester) async {
  // Enter profile information
  final nameField = find.byType(TextFormField).at(0);
  await tester.enterText(nameField, TestUserFlow.testName);

  // Select creative role (if dropdown)
  final roleDropdown = find.byType(DropdownButtonFormField);
  if (roleDropdown.evaluate().isNotEmpty) {
    await tester.tap(roleDropdown);
    await TestUserFlow.waitForNavigation(tester);

    final producerOption = find.text('Producer');
    await tester.tap(producerOption);
    await TestUserFlow.waitForNavigation(tester);
  }

  // Save profile
  final saveButton = find.textContaining('Save');
  await tester.tap(saveButton);
  await TestUserFlow.waitForNavigation(tester);
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  // Navigate through onboarding screens
  final nextButton = find.textContaining('Next');
  final skipButton = find.textContaining('Skip');

  // Complete all onboarding steps or skip
  while (nextButton.evaluate().isNotEmpty) {
    await tester.tap(nextButton);
    await TestUserFlow.waitForNavigation(tester);
  }

  // If there's a finish button, tap it
  final finishButton = find.textContaining('Finish');
  if (finishButton.evaluate().isNotEmpty) {
    await tester.tap(finishButton);
    await TestUserFlow.waitForNavigation(tester);
  }
}

Future<void> _testSessionPersistence(WidgetTester tester) async {
  // This would test that the user remains logged in after app restart
  // In a real test, you'd restart the app and verify the user is still authenticated
  // For now, we'll just verify the current session is maintained
  expect(find.textContaining('Projects'), findsOneWidget);
}

Future<void> _testOfflineMode(WidgetTester tester) async {
  // Test offline functionality
  // This would require mocking network connectivity
  // For now, we'll just verify the app doesn't crash in offline scenarios

  // Test creating a project offline
  final addButton = find.byIcon(Icons.add);
  await tester.tap(addButton);
  await TestUserFlow.waitForNavigation(tester);

  // Verify project creation form is accessible
  expect(find.byType(TextFormField), findsAtLeast(1));
}

Future<void> _testDataSynchronization(WidgetTester tester) async {
  // Test that user data is properly synchronized
  // This would verify that projects, audio tracks, etc. are loaded

  // Verify projects are loaded
  expect(find.textContaining('Projects'), findsOneWidget);

  // Test refresh functionality
  final refreshButton = find.byIcon(Icons.refresh);
  if (refreshButton.evaluate().isNotEmpty) {
    await tester.tap(refreshButton);
    await TestUserFlow.waitForNavigation(tester);
  }
}
