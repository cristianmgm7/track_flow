import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

/// Coordinates the flow between Auth, Onboarding, and UserProfile BLoCs
/// Maintains single responsibility principle while handling complex state coordination
class AppFlowCoordinator {
  final AuthBloc _authBloc;
  final OnboardingBloc _onboardingBloc;
  final UserProfileBloc _userProfileBloc;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<OnboardingState>? _onboardingSubscription;
  StreamSubscription<UserProfileState>? _profileSubscription;

  AppFlowCoordinator({
    required AuthBloc authBloc,
    required OnboardingBloc onboardingBloc,
    required UserProfileBloc userProfileBloc,
  }) : _authBloc = authBloc,
       _onboardingBloc = onboardingBloc,
       _userProfileBloc = userProfileBloc {
    _initializeCoordination();
  }

  void _initializeCoordination() {
    // Listen to auth state changes
    _authSubscription = _authBloc.stream.listen(_handleAuthStateChange);

    // Listen to onboarding state changes
    _onboardingSubscription = _onboardingBloc.stream.listen(
      _handleOnboardingStateChange,
    );

    // Listen to profile state changes
    _profileSubscription = _userProfileBloc.stream.listen(
      _handleProfileStateChange,
    );
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthState state) {
    if (state is AuthAuthenticated) {
      // User just authenticated - check onboarding status
      _onboardingBloc.add(CheckOnboardingStatus());
    } else if (state is AuthUnauthenticated) {
      // User signed out - reset other BLoCs
      _onboardingBloc.add(ResetOnboarding());
      _userProfileBloc.add(ClearUserProfile());
    }
  }

  /// Handle onboarding state changes
  void _handleOnboardingStateChange(OnboardingState state) {
    if (state is OnboardingCompleted) {
      // Onboarding completed - check profile completeness
      _userProfileBloc.add(CheckProfileCompleteness());
    } else if (state is OnboardingIncomplete) {
      // Onboarding incomplete - this is expected for new users
      // No action needed, router will handle navigation
    }
  }

  /// Handle profile state changes
  void _handleProfileStateChange(UserProfileState state) {
    if (state is ProfileComplete) {
      // Profile is complete - user is ready for main app
      // Router will handle navigation to dashboard
    } else if (state is ProfileIncomplete) {
      // Profile incomplete - user needs to complete profile
      // Router will handle navigation to profile creation
    }
  }

  /// Get current app flow state for router decisions
  AppFlowState getCurrentFlowState() {
    final authState = _authBloc.state;
    final onboardingState = _onboardingBloc.state;
    final profileState = _userProfileBloc.state;

    // Determine current flow state
    if (authState is AuthUnauthenticated) {
      return AppFlowState.unauthenticated;
    }

    if (authState is AuthAuthenticated) {
      if (onboardingState is OnboardingIncomplete) {
        return AppFlowState.needsOnboarding;
      }

      if (onboardingState is OnboardingCompleted) {
        if (profileState is ProfileIncomplete) {
          return AppFlowState.needsProfileSetup;
        }

        if (profileState is ProfileComplete) {
          return AppFlowState.ready;
        }

        // Profile still loading
        return AppFlowState.loading;
      }

      // Onboarding still loading
      return AppFlowState.loading;
    }

    // Auth still loading
    return AppFlowState.loading;
  }

  /// Clean up resources
  void dispose() {
    _authSubscription?.cancel();
    _onboardingSubscription?.cancel();
    _profileSubscription?.cancel();
  }
}

/// Represents the current state of the app flow
enum AppFlowState {
  loading,
  unauthenticated,
  needsOnboarding,
  needsProfileSetup,
  ready,
}
