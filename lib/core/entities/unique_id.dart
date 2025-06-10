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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class UserId extends UniqueId {
  factory UserId() => UserId._(const Uuid().v4());

  factory UserId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return UserId._(input);
  }

  const UserId._(super.value) : super._();
}

class ProjectId extends UniqueId {
  factory ProjectId() => ProjectId._(const Uuid().v4());

  factory ProjectId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return ProjectId._(input);
  }

  const ProjectId._(super.value) : super._();
}

class AudioTrackId extends UniqueId {
  factory AudioTrackId() => AudioTrackId._(const Uuid().v4());

  factory AudioTrackId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return AudioTrackId._(input);
  }

  const AudioTrackId._(super.value) : super._();
}

class AudioCommentId extends UniqueId {
  factory AudioCommentId() => AudioCommentId._(const Uuid().v4());

  factory AudioCommentId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return AudioCommentId._(input);
  }

  const AudioCommentId._(super.value) : super._();
}
