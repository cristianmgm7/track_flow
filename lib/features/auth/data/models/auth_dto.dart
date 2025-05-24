import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:trackflow/features/auth/domain/entities/user.dart';

class AuthDto {
  final String id;
  final String email;
  final String? displayName;

  AuthDto({required this.id, required this.email, this.displayName});

  factory AuthDto.fromFirebase(firebase.User user) {
    return AuthDto(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  User toDomain() {
    return User(id: id, email: email, displayName: displayName);
  }

  factory AuthDto.fromDomain(User user) {
    return AuthDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
