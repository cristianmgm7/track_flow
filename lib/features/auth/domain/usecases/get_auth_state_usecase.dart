import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetAuthStateUseCase {
  final AuthRepository repository;
  GetAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.authState;
  }
}
