import 'package:trackflow/core/entities/value_object.dart';

class InvalidProjectIdException implements Exception {
  final String message;
  InvalidProjectIdException([this.message = 'ProjectId cannot be empty']);
}

class ProjectId extends ValueObject<String> {
  ProjectId(String input) : super(_validate(input));

  static String _validate(String input) {
    if (input.isEmpty) {
      throw InvalidProjectIdException();
    }
    return input;
  }
}
