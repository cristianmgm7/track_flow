import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';

// domain/entities/app_status.dart
enum AppStatus { unknown, onboarding, unauthenticated, authenticated }

// presentation/bloc/app_flow_cubit.dart
class AppFlowCubit extends Cubit<AppStatus> {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;

  AppFlowCubit({
    required this.authRepository,
    required this.onboardingRepository,
  }) : super(AppStatus.unknown) {
    _init();
  }

  Future<void> _init() async {
    final hasSeenOnboarding =
        await onboardingRepository.checkOnboardingCompleted();
    final hasSeenWelcomeScreen =
        await onboardingRepository.checkWelcomeScreenSeen();
    final isLoggedIn = await authRepository.isLoggedIn();

    if (!hasSeenOnboarding) {
      emit(AppStatus.onboarding);
    } else if (!hasSeenWelcomeScreen) {
      emit(AppStatus.onboarding);
    } else if (!isLoggedIn) {
      emit(AppStatus.unauthenticated);
    } else {
      emit(AppStatus.authenticated);
    }
  }

  void loggedIn() => emit(AppStatus.authenticated);

  void loggedOut() => emit(AppStatus.unauthenticated);
}
