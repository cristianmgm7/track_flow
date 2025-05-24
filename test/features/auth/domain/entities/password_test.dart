import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';
import 'package:trackflow/core/error/failures.dart';

void main() {
  group('Password ValueObject', () {
    test('should return Right(password) for a valid password', () {
      final password = PasswordValue('123456');
      expect(password.value, right('123456'));
    });

    test('should return Left(InvalidPasswordFailure) for a short password', () {
      final password = PasswordValue('123');
      expect(password.value, left(const InvalidPasswordFailure()));
    });

    test('should be value-equal for same password', () {
      final password1 = PasswordValue('abcdef');
      final password2 = PasswordValue('abcdef');
      expect(password1, equals(password2));
    });
  });
}
