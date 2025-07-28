// lib/features/invitations/domain/entities/invitation_id.dart
import 'package:uuid/uuid.dart';
import 'package:trackflow/core/entities/value_object.dart';

class InvitationId extends ValueObject<String> {
  factory InvitationId() => InvitationId._(const Uuid().v4());

  factory InvitationId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return InvitationId._(input);
  }

  const InvitationId._(super.value); // ✅ Fixed: removed : super._();
}
