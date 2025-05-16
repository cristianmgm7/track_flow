import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/core/error/failures.dart';

void main() {
  group('Email ValueObject', () {
    test('should return Right(email) for a valid email', () {
      final email = EmailAddress('test@example.com');
      expect(email.value, right('test@example.com'));
    });

    test('should return Left(InvalidEmailFailure) for an invalid email', () {
      final email = EmailAddress('invalid-email');
      expect(email.value, left(const InvalidEmailFailure()));
    });

    test('should be value-equal for same email', () {
      final email1 = EmailAddress('test@example.com');
      final email2 = EmailAddress('test@example.com');
      expect(email1, equals(email2));
    });
  });
}
