import 'package:uuid/uuid.dart';
import '../../../../core/entities/value_object.dart';

/// Voice memo unique identifier
class VoiceMemoId extends ValueObject<String> {
  VoiceMemoId._(super.value);
      
  /// Generate new UUID
  factory VoiceMemoId() {
    return VoiceMemoId._(const Uuid().v4());
  }

  /// Create from existing string
  factory VoiceMemoId.fromUniqueString(String uniqueId) {
    return VoiceMemoId._(uniqueId);
  }

  @override
  List<Object?> get props => [value];
}
