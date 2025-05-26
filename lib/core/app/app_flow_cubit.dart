import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';

// domain/entities/app_status.dart
enum AppStatus { unknown, onboarding, unauthenticated, authenticated }

@injectable // presentation/bloc/app_flow_cubit.dart
class AppFlowCubit extends Cubit<AppStatus> {
  final AuthRepository authRepository;
  final OnboardingUseCase onboardingRepository;

  AppFlowCubit({
    required this.authRepository,
    required this.onboardingRepository,
  }) : super(AppStatus.unknown) {
    //--> Initialize the cubit with the unknown status
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
