import 'package:uuid/uuid.dart';
import '../../../../core/entities/value_object.dart';

/// Voice memo unique identifier
class VoiceMemoId extends ValueObject<String> {
  factory VoiceMemoId() => VoiceMemoId._(const Uuid().v4());
      
  factory VoiceMemoId.fromUniqueString(String input) {
    assert(input.isNotEmpty);
    return VoiceMemoId._(input);
  }

  const VoiceMemoId._(super.value);

  @override
  List<Object?> get props => [value];
}
