import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GoogleSignInUseCase {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return repository.signInWithGoogle();
  }
}
