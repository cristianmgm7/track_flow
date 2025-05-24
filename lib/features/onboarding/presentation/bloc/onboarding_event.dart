import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingMarkCompleted extends OnboardingEvent {}

class WelcomeScreenMarkCompleted extends OnboardingEvent {}
