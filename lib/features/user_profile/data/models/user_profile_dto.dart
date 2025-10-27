import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class UserProfileDTO {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? avatarLocalPath; // local-only (no se serializa a Firestore)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole creativeRole;

  // Professional context
  final String? description;
  final String? location;
  final List<String>? roles;
  final List<String>? genres;
  final List<String>? skills;
  final String? availabilityStatus;

  // External links
  final List<Map<String, String>>? socialLinks;
  final String? websiteUrl;
  final String? linktreeUrl;

  // Contact (display only)
  final Map<String, dynamic>? contactInfo;

  // Meta
  final bool verified;

  // ⭐ NEW: Sync metadata fields for proper offline-first sync
  final int version;
  final DateTime? lastModified;

  UserProfileDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.avatarLocalPath,
    required this.createdAt,
    this.updatedAt,
    required this.creativeRole,
    this.description,
    this.location,
    this.roles,
    this.genres,
    this.skills,
    this.availabilityStatus,
    this.socialLinks,
    this.websiteUrl,
    this.linktreeUrl,
    this.contactInfo,
    this.verified = false,
    // ⭐ NEW: Sync metadata fields
    this.version = 1,
    this.lastModified,
  });

  static const String collection = 'user_profile';

  factory UserProfileDTO.fromDomain(UserProfile userProfile) {
    return UserProfileDTO(
      id: userProfile.id.value,
      name: userProfile.name,
      email: userProfile.email,
      avatarUrl: userProfile.avatarUrl,
      avatarLocalPath: userProfile.avatarLocalPath,
      createdAt: userProfile.createdAt,
      updatedAt: userProfile.updatedAt,
      creativeRole: userProfile.creativeRole ?? CreativeRole.other,
      description: userProfile.description,
      location: userProfile.location,
      roles: userProfile.roles,
      genres: userProfile.genres,
      skills: userProfile.skills,
      availabilityStatus: userProfile.availabilityStatus,
      socialLinks: userProfile.socialLinks?.map((l) => {
        'platform': l.platform,
        'url': l.url,
      }).toList(),
      websiteUrl: userProfile.websiteUrl,
      linktreeUrl: userProfile.linktreeUrl,
      contactInfo: userProfile.contactInfo != null ? {
        'phone': userProfile.contactInfo!.phone,
      } : null,
      verified: userProfile.verified,
      // ⭐ NEW: Include sync metadata for user profiles
      version: 1, // Initial version for new user profiles
      lastModified:
          userProfile.updatedAt ??
          userProfile.createdAt, // Use updatedAt or createdAt
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: UserId.fromUniqueString(id),
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      avatarLocalPath: avatarLocalPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      creativeRole: creativeRole,
      description: description,
      location: location,
      roles: roles,
      genres: genres,
      skills: skills,
      availabilityStatus: availabilityStatus,
      socialLinks: socialLinks?.map((l) => SocialLink(
        platform: l['platform']!,
        url: l['url']!,
      )).toList(),
      websiteUrl: websiteUrl,
      linktreeUrl: linktreeUrl,
      contactInfo: contactInfo != null ? ContactInfo(
        phone: contactInfo!['phone'] as String?,
      ) : null,
      verified: verified,
    );
  }

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
    }

    DateTime? parsedUpdatedAt;
    if (json['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (json['updatedAt'] as Timestamp).toDate();
    } else if (json['updatedAt'] is String) {
      parsedUpdatedAt = DateTime.tryParse(json['updatedAt'] as String);
    }

    return UserProfileDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      avatarLocalPath: null, // nunca viene del remoto
      createdAt: parsedCreatedAt ?? DateTime.now(),
      updatedAt: parsedUpdatedAt,
      creativeRole: _parseCreativeRole(json['creativeRole'] as String?),
      description: json['description'] as String?,
      location: json['location'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
      availabilityStatus: json['availabilityStatus'] as String?,
      socialLinks: (json['socialLinks'] as List<dynamic>?)?.map((e) => Map<String, String>.from(e as Map)).toList(),
      websiteUrl: json['websiteUrl'] as String?,
      linktreeUrl: json['linktreeUrl'] as String?,
      contactInfo: json['contactInfo'] as Map<String, dynamic>?,
      verified: json['verified'] as bool? ?? false,
      // ⭐ NEW: Parse sync metadata from JSON
      version: json['version'] as int? ?? 1,
      lastModified:
          json['lastModified'] != null
              ? DateTime.tryParse(json['lastModified'] as String)
              : null,
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
      'description': description,
      'location': location,
      'roles': roles,
      'genres': genres,
      'skills': skills,
      'availabilityStatus': availabilityStatus,
      'socialLinks': socialLinks,
      'websiteUrl': websiteUrl,
      'linktreeUrl': linktreeUrl,
      'contactInfo': contactInfo,
      'verified': verified,
      // ⭐ NEW: Include sync metadata in JSON
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  UserProfileDTO copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? avatarLocalPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreativeRole? creativeRole,
    String? description,
    String? location,
    List<String>? roles,
    List<String>? genres,
    List<String>? skills,
    String? availabilityStatus,
    List<Map<String, String>>? socialLinks,
    String? websiteUrl,
    String? linktreeUrl,
    Map<String, dynamic>? contactInfo,
    bool? verified,
    int? version,
    DateTime? lastModified,
  }) {
    return UserProfileDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creativeRole: creativeRole ?? this.creativeRole,
      description: description ?? this.description,
      location: location ?? this.location,
      roles: roles ?? this.roles,
      genres: genres ?? this.genres,
      skills: skills ?? this.skills,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      socialLinks: socialLinks ?? this.socialLinks,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linktreeUrl: linktreeUrl ?? this.linktreeUrl,
      contactInfo: contactInfo ?? this.contactInfo,
      verified: verified ?? this.verified,
      // ⭐ NEW: Include sync metadata in copyWith
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

CreativeRole _parseCreativeRole(String? roleName) {
  if (roleName == null) {
    return CreativeRole.other;
  }
  try {
    return CreativeRole.values.byName(roleName);
  } catch (e) {
    return CreativeRole.other;
  }
}
