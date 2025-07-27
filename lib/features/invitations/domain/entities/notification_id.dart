import 'package:uuid/uuid.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class NotificationId extends UniqueId {
  factory NotificationId() => NotificationId._(const Uuid().v4());

  factory NotificationId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return NotificationId._(input);
  }

  const NotificationId._(super.value) : super._();
}
