// core/domain/aggregate_root.dart
import 'package:trackflow/core/domain/entity.dart';

// core/domain/aggregate_root.dart
abstract class AggregateRoot<T> extends Entity<T> {
  const AggregateRoot(super.id);
}
