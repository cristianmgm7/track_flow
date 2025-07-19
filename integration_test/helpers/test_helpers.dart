import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/core/di/injection.dart';

/// Test helper class for managing user states and navigation flows
class TestUserFlow {
  static const String testEmail = 'test@trackflow.com';
  static const String testPassword = 'TestPassword123!';
  static const String testName = 'Test User';
  static const String testCreativeRole = 'Producer';

  /// Mock user for testing
  static domain.User get mockUser => domain.User(
    id: UserId.fromUniqueString('test-user-id'),
    email: testEmail,
    displayName: testName,
  );

  /// Mock complete profile for testing
  static UserProfile get mockCompleteProfile => UserProfile(
    id: UserId.fromUniqueString('test-user-id'),
    name: testName,
    email: testEmail,
    creativeRole: CreativeRole.producer,
    avatarUrl: 'https://example.com/avatar.jpg',
    createdAt: DateTime.now(),
  );

  /// Mock incomplete profile for testing
  static UserProfile get mockIncompleteProfile => UserProfile(
    id: UserId.fromUniqueString('test-user-id'),
    name: '',
    email: testEmail,
    creativeRole: null,
    avatarUrl: '',
    createdAt: DateTime.now(),
  );

  /// Helper to wait for navigation to complete
  static Future<void> waitForNavigation(WidgetTester tester) async {
    await tester.pumpAndSettle();
    // Additional wait to ensure all async operations complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Helper to reset dependencies between tests
  static Future<void> resetDependencies() async {
    await sl.reset();
  }

  /// Helper to start app with clean state
  static Future<void> startApp(WidgetTester tester) async {
    // Reset dependencies first
    await resetDependencies();
    // Start the app
    app.main();
    await waitForNavigation(tester);
  }

  /// Helper to check if we're on a specific route
  static bool isOnRoute(WidgetTester tester, String routeName) {
    // This is a simplified check - in real implementation you'd check the actual route
    return true; // Placeholder
  }

  /// Helper to verify BLoC states
  static void verifyAuthState(AuthState expectedState, AuthState actualState) {
    expect(actualState.runtimeType, expectedState.runtimeType);
    if (expectedState is AuthAuthenticated &&
        actualState is AuthAuthenticated) {
      expect(actualState.user.id, expectedState.user.id);
      expect(actualState.user.email, expectedState.user.email);
    }
  }

  static void verifyOnboardingState(
    OnboardingState expectedState,
    OnboardingState actualState,
  ) {
    expect(actualState.runtimeType, expectedState.runtimeType);
  }

  static void verifyProfileState(
    UserProfileState expectedState,
    UserProfileState actualState,
  ) {
    expect(actualState.runtimeType, expectedState.runtimeType);
    if (expectedState is ProfileComplete && actualState is ProfileComplete) {
      expect(actualState.profile.id, expectedState.profile.id);
    }
  }
}

/// Test scenarios for different user types
class TestScenarios {
  /// Scenario: New user (first time)
  static const String newUserScenario = 'new_user';

  /// Scenario: Returning user with complete profile
  static const String returningUserScenario = 'returning_user';

  /// Scenario: User with incomplete profile
  static const String incompleteProfileScenario = 'incomplete_profile';

  /// Scenario: User with incomplete onboarding
  static const String incompleteOnboardingScenario = 'incomplete_onboarding';
}

/// Test data for different scenarios
class TestData {
  static Map<String, Map<String, dynamic>> get scenarios => {
    TestScenarios.newUserScenario: {
      'authState': AuthUnauthenticated(),
      'onboardingState': OnboardingIncomplete(),
      'profileState': UserProfileInitial(),
      'expectedRoute': '/auth',
      'description': 'New user should be redirected to auth screen',
    },
    TestScenarios.returningUserScenario: {
      'authState': AuthAuthenticated(TestUserFlow.mockUser),
      'onboardingState': OnboardingCompleted(),
      'profileState': ProfileComplete(TestUserFlow.mockCompleteProfile),
      'expectedRoute': '/dashboard',
      'description': 'Returning user should go directly to dashboard',
    },
    TestScenarios.incompleteProfileScenario: {
      'authState': AuthAuthenticated(TestUserFlow.mockUser),
      'onboardingState': OnboardingCompleted(),
      'profileState': ProfileIncomplete(
        profile: TestUserFlow.mockIncompleteProfile,
        reason: 'Missing required fields',
      ),
      'expectedRoute': '/profile/create',
      'description':
          'User with incomplete profile should be redirected to profile creation',
    },
    TestScenarios.incompleteOnboardingScenario: {
      'authState': AuthAuthenticated(TestUserFlow.mockUser),
      'onboardingState': OnboardingIncomplete(),
      'profileState': UserProfileInitial(),
      'expectedRoute': '/onboarding',
      'description':
          'User with incomplete onboarding should be redirected to onboarding',
    },
  };
}
