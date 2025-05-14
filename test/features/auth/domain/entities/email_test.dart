import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/core/error/failures.dart';

void main() {
  group('Email ValueObject', () {
    test('should return Right(email) for a valid email', () {
      final email = Email('test@example.com');
      expect(email.value, right('test@example.com'));
    });

    test('should return Left(InvalidEmailFailure) for an invalid email', () {
      final email = Email('invalid-email');
      expect(email.value, left(const InvalidEmailFailure()));
    });

    test('should be value-equal for same email', () {
      final email1 = Email('test@example.com');
      final email2 = Email('test@example.com');
      expect(email1, equals(email2));
    });
  });
}
