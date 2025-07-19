import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<Either<Failure, User>> call(
    EmailAddress email,
    PasswordValue password,
  ) async {
    // ✅ Only authenticate user - no profile creation
    // Profile will be created by the profile creation flow
    final authResult = await _authRepository.signUpWithEmailAndPassword(
      email.value.getOrElse(() => ''),
      password.value.getOrElse(() => ''),
    );

    return authResult.fold((failure) => Left(failure), (user) => Right(user));
  }
}
