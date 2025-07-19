import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboardingStatus extends OnboardingEvent {}

class MarkOnboardingCompleted extends OnboardingEvent {}

class ResetOnboarding extends OnboardingEvent {}

class ResetOnboardingStatus extends OnboardingEvent {}

class ClearAllOnboardingData extends OnboardingEvent {}
