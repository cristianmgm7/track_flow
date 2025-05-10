import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingCheckRequested extends OnboardingEvent {}

class OnboardingMarkCompleted extends OnboardingEvent {}

class OnboardingMarkLaunchSeen extends OnboardingEvent {}
