import 'package:equatable/equatable.dart';

abstract class ValueObject<T> extends Equatable {
  final T value;
  const ValueObject(this.value);

  @override
  List<Object?> get props => [value];
}
