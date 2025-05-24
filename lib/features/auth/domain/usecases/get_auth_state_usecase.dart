import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository repository;
  GetAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.authState;
  }
}
