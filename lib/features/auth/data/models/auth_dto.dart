import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AuthDto {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl; // ✅ NUEVO: URL de foto de Google
  final bool isNewUser; // ✅ NUEVO: Distinguir sign in vs sign up

  AuthDto({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isNewUser = false,
  });

  factory AuthDto.fromFirebase(firebase.User user, {bool isNewUser = false}) {
    return AuthDto(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL, // ✅ Extraer foto de Google
      isNewUser: isNewUser,
    );
  }

  User toDomain() {
    return User(
      id: UserId.fromUniqueString(id),
      email: email,
      displayName: displayName,
      photoUrl: photoUrl, // ✅ Incluir foto en el dominio
    );
  }

  factory AuthDto.fromDomain(User user) {
    return AuthDto(
      id: user.id.value,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isNewUser: false, // Default para usuarios existentes
    );
  }

  @override
  String toString() {
    return 'AuthDto(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, isNewUser: $isNewUser)';
  }
}
