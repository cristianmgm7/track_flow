import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingChecked extends OnboardingState {
  final bool hasCompletedOnboarding;
  final bool hasSeenLaunch;

  const OnboardingChecked({
    required this.hasCompletedOnboarding,
    required this.hasSeenLaunch,
  });

  @override
  List<Object?> get props => [hasCompletedOnboarding, hasSeenLaunch];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
