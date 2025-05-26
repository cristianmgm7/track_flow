import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class OnboardingUseCase {
  final AuthRepository repository;
  OnboardingUseCase(this.repository);

  Future<bool> onboardingCompleted() async {
    return repository.onboardingCompleted();
  }

  Future<void> welcomeScreenSeenCompleted() async {
    return repository.welcomeScreenSeenCompleted();
  }

  Future<bool> checkWelcomeScreenSeen() async {
    return repository.checkWelcomeScreenSeen();
  }

  Future<bool> checkOnboardingCompleted() async {
    return repository.checkOnboardingCompleted();
  }
}
