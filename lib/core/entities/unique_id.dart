import 'package:uuid/uuid.dart';
import 'value_object.dart'; // your abstract ValueObject<T>

class UniqueId extends ValueObject<String> {
  factory UniqueId() => UniqueId._(const Uuid().v4());

  factory UniqueId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return UniqueId._(input);
  }

  const UniqueId._(super.value);

  static UniqueId fromString(String projectId) {
    return UniqueId.fromUniqueString(projectId);
  }
}

class UserId extends ValueObject<String> {
  factory UserId() => UserId._(const Uuid().v4());

  factory UserId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return UserId._(input);
  }

  factory UserId.fromNullableString(String? input) {
    if (input == null) return UserId();
    return UserId.fromUniqueString(input);
  }

  const UserId._(super.value); // ✅ Fixed: removed : super._();
}

class ProjectId extends ValueObject<String> {
  factory ProjectId() => ProjectId._(const Uuid().v4());

  factory ProjectId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return ProjectId._(input);
  }

  const ProjectId._(super.value); // ✅ Fixed: removed : super._();
}

class AudioTrackId extends ValueObject<String> {
  factory AudioTrackId() => AudioTrackId._(const Uuid().v4());

  factory AudioTrackId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return AudioTrackId._(input);
  }

  const AudioTrackId._(super.value); // ✅ Fixed: removed : super._();
}

class AudioCommentId extends ValueObject<String> {
  factory AudioCommentId() => AudioCommentId._(const Uuid().v4());

  factory AudioCommentId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return AudioCommentId._(input);
  }

  const AudioCommentId._(super.value); // ✅ Fixed: removed : super._();
}

class MagicLinkId extends ValueObject<String> {
  factory MagicLinkId() => MagicLinkId._(const Uuid().v4());

  factory MagicLinkId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return MagicLinkId._(input);
  }

  const MagicLinkId._(super.value); // ✅ Fixed: removed : super._();
}

class PlaylistId extends ValueObject<String> {
  factory PlaylistId() => PlaylistId._(const Uuid().v4());

  factory PlaylistId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return PlaylistId._(input);
  }

  const PlaylistId._(super.value); // ✅ Fixed: removed : super._();
}
