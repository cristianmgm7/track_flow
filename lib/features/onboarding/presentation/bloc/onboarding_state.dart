import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingIncomplete extends OnboardingState {
  final bool hasCompletedOnboarding;

  const OnboardingIncomplete({this.hasCompletedOnboarding = false});

  @override
  List<Object?> get props => [hasCompletedOnboarding];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
