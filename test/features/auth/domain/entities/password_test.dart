import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';
import 'package:trackflow/core/error/failures.dart';

void main() {
  group('Password ValueObject', () {
    test('should return Right(password) for a valid password', () {
      final password = Password('123456');
      expect(password.value, right('123456'));
    });

    test('should return Left(InvalidPasswordFailure) for a short password', () {
      final password = Password('123');
      expect(password.value, left(const InvalidPasswordFailure()));
    });

    test('should be value-equal for same password', () {
      final password1 = Password('abcdef');
      final password2 = Password('abcdef');
      expect(password1, equals(password2));
    });
  });
}
