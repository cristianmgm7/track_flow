import 'package:uuid/uuid.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class InvitationId extends UniqueId {
  factory InvitationId() => InvitationId._(const Uuid().v4());

  factory InvitationId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return InvitationId._(input);
  }

  const InvitationId._(super.value);
}
