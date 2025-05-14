import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:trackflow/features/auth/domain/entities/user.dart';

class UserDto {
  final String id;
  final String email;
  final String? displayName;

  UserDto({required this.id, required this.email, this.displayName});

  factory UserDto.fromFirebase(firebase.User user) {
    return UserDto(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  User toDomain() {
    return User(id: id, email: email, displayName: displayName);
  }

  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
