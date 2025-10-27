import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'user_profile_document.g.dart';

@embedded
class SocialLinkDocument {
  late String platform;
  late String url;
}

@embedded
class ContactInfoDocument {
  String? phone;
}

@collection
class UserProfileDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;

  @Index(unique: true)
  late String email;

  late String avatarUrl;
  String? avatarLocalPath;
  late DateTime createdAt;
  DateTime? updatedAt;

  @Enumerated(EnumType.name)
  late CreativeRole creativeRole;

  // Professional context
  late String? description;
  late String? location;
  late List<String>? roles;
  late List<String>? genres;
  late List<String>? skills;
  late String? availabilityStatus;

  // External links
  late List<SocialLinkDocument>? socialLinks;
  late String? websiteUrl;
  late String? linktreeUrl;

  // Contact (display only)
  late ContactInfoDocument? contactInfo;

  // Meta
  late bool verified;

  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;

  UserProfileDocument();

  factory UserProfileDocument.fromDTO(
    UserProfileDTO dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return UserProfileDocument()
      ..id = dto.id
      ..name = dto.name
      ..email = dto.email
      ..avatarUrl = dto.avatarUrl
      ..avatarLocalPath = dto.avatarLocalPath
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..creativeRole = dto.creativeRole
      ..description = dto.description
      ..location = dto.location
      ..roles = dto.roles
      ..genres = dto.genres
      ..skills = dto.skills
      ..availabilityStatus = dto.availabilityStatus
      ..socialLinks = dto.socialLinks?.map((l) {
        final doc = SocialLinkDocument();
        doc.platform = l['platform']!;
        doc.url = l['url']!;
        return doc;
      }).toList()
      ..websiteUrl = dto.websiteUrl
      ..linktreeUrl = dto.linktreeUrl
      ..contactInfo = dto.contactInfo != null ? (ContactInfoDocument()
        ..phone = dto.contactInfo!['phone'] as String?) : null
      ..verified = dto.verified
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? dto.updatedAt ?? dto.createdAt,
          );
  }

  /// Create UserProfileDocument from remote DTO with sync metadata
  factory UserProfileDocument.fromRemoteDTO(
    UserProfileDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return UserProfileDocument()
      ..id = dto.id
      ..name = dto.name
      ..email = dto.email
      ..avatarUrl = dto.avatarUrl
      ..avatarLocalPath = dto.avatarLocalPath
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..creativeRole = dto.creativeRole
      ..description = dto.description
      ..location = dto.location
      ..roles = dto.roles
      ..genres = dto.genres
      ..skills = dto.skills
      ..availabilityStatus = dto.availabilityStatus
      ..socialLinks = dto.socialLinks?.map((l) {
        final doc = SocialLinkDocument();
        doc.platform = l['platform']!;
        doc.url = l['url']!;
        return doc;
      }).toList()
      ..websiteUrl = dto.websiteUrl
      ..linktreeUrl = dto.linktreeUrl
      ..contactInfo = dto.contactInfo != null ? (ContactInfoDocument()
        ..phone = dto.contactInfo!['phone'] as String?) : null
      ..verified = dto.verified
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? dto.updatedAt ?? dto.createdAt,
      );
  }

  /// Create UserProfileDocument for local updates
  factory UserProfileDocument.forLocalUpdate({
    required String id,
    required String name,
    required String email,
    required String avatarUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
    required CreativeRole creativeRole,
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
    bool verified = false,
  }) {
    return UserProfileDocument()
      ..id = id
      ..name = name
      ..email = email
      ..avatarUrl = avatarUrl
      ..avatarLocalPath = null
      ..createdAt = createdAt
      ..updatedAt = updatedAt ?? DateTime.now()
      ..creativeRole = creativeRole
      ..description = description
      ..location = location
      ..roles = roles
      ..genres = genres
      ..skills = skills
      ..availabilityStatus = availabilityStatus
      ..socialLinks = socialLinks?.map((l) {
        final doc = SocialLinkDocument();
        doc.platform = l['platform']!;
        doc.url = l['url']!;
        return doc;
      }).toList()
      ..websiteUrl = websiteUrl
      ..linktreeUrl = linktreeUrl
      ..contactInfo = contactInfo != null ? (ContactInfoDocument()
        ..phone = contactInfo['phone'] as String?) : null
      ..verified = verified
      ..syncMetadata = SyncMetadataDocument.initial();
  }

  UserProfileDTO toDTO() {
    return UserProfileDTO(
      id: id,
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
      socialLinks: socialLinks?.map((l) => {
        'platform': l.platform,
        'url': l.url,
      }).toList(),
      websiteUrl: websiteUrl,
      linktreeUrl: linktreeUrl,
      contactInfo: contactInfo != null ? {
        'phone': contactInfo!.phone,
      } : null,
      verified: verified,
      // ⭐ NEW: Include sync metadata from document (CRITICAL FIX!)
      version: syncMetadata?.version ?? 1,
      lastModified: syncMetadata?.lastModified ?? updatedAt ?? createdAt,
    );
  }
}
