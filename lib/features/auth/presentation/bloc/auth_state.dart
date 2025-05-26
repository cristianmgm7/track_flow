import 'package:equatable/equatable.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final domain.User user;
  final bool isOfflineMode;

  const AuthAuthenticated(this.user, [this.isOfflineMode = false]);

  @override
  List<Object?> get props => [user, isOfflineMode];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Onboarding States

class OnboardingInitial extends AuthState {}

class OnboardingLoading extends AuthState {}

class WelcomeScreenInitial extends AuthState {}

class OnboardingChecked extends AuthState {
  final bool hasCompletedOnboarding;
  final bool hasSeenLaunch;

  const OnboardingChecked({
    required this.hasCompletedOnboarding,
    required this.hasSeenLaunch,
  });

  @override
  List<Object?> get props => [hasCompletedOnboarding, hasSeenLaunch];
}

class OnboardingError extends AuthState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
