import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class UserProfileDTO {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole creativeRole;

  UserProfileDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    required this.creativeRole,
  });

  static const String collection = 'user_profile';

  factory UserProfileDTO.fromDomain(UserProfile userProfile) {
    return UserProfileDTO(
      id: userProfile.id.value,
      name: userProfile.name,
      email: userProfile.email,
      avatarUrl: userProfile.avatarUrl,
      createdAt: userProfile.createdAt,
      updatedAt: userProfile.updatedAt,
      creativeRole: userProfile.creativeRole ?? CreativeRole.other,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: UserId.fromUniqueString(id),
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      creativeRole: creativeRole,
    );
  }

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      createdAt:
          (json['createdAt'] is Timestamp)
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          (json['updatedAt'] != null)
              ? (json['updatedAt'] is Timestamp)
                  ? (json['updatedAt'] as Timestamp).toDate()
                  : DateTime.parse(json['updatedAt'] as String)
              : null,
      creativeRole: CreativeRole.values.byName(json['creativeRole'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'creativeRole': creativeRole.name,
    };
  }
}
