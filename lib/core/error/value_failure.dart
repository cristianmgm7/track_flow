import 'package:equatable/equatable.dart';

abstract class ValueFailure<T> extends Equatable {
  final T failedValue;
  final String message;
  const ValueFailure(this.failedValue, this.message);

  @override
  List<Object?> get props => [failedValue, message];

  factory ValueFailure.invalidEmail({required T failedValue}) {
    return InvalidEmail<T>(failedValue);
  }

  factory ValueFailure.shortPassword({required T failedValue}) {
    return ShortPassword<T>(failedValue);
  }

  factory ValueFailure.emptyField({required T failedValue}) {
    return EmptyField<T>(failedValue);
  }
}

class InvalidEmail<T> extends ValueFailure<T> {
  const InvalidEmail(T failedValue)
    : super(failedValue, 'Invalid email format');
}

class ShortPassword<T> extends ValueFailure<T> {
  const ShortPassword(T failedValue)
    : super(failedValue, 'Password must be at least 6 characters');
}

class EmptyField<T> extends ValueFailure<T> {
  const EmptyField(T failedValue) : super(failedValue, 'Field cannot be empty');
}

class ExceedingLength<T> extends ValueFailure<T> {
  final int max;
  const ExceedingLength(T failedValue, this.max)
    : super(failedValue, 'Value must be less than $max characters');
}
