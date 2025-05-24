import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() async {
    return repository.signOut();
  }
}
