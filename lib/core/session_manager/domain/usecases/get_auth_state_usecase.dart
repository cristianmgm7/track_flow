import 'package:injectable/injectable.dart';

import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetAuthStateUseCase {
  final AuthRepository repository;
  GetAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.authState;
  }
}