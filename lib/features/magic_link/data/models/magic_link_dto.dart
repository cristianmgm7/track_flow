import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class MagicLinkDto {
  final String id;
  final String url;
  final String userId;
  final String projectId;
  final Timestamp createdAt;
  final Timestamp? expiresAt;
  final bool isUsed;
  final String status;

  MagicLinkDto({
    required this.id,
    required this.url,
    required this.userId,
    required this.projectId,
    required this.createdAt,
    this.expiresAt,
    required this.isUsed,
    required this.status,
  });

  factory MagicLinkDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MagicLinkDto(
      id: doc.id,
      url: data['url'] as String,
      userId: data['userId'] as String,
      projectId: data['projectId'] as String,
      createdAt: data['createdAt'] as Timestamp,
      expiresAt: data['expiresAt'] as Timestamp?,
      isUsed: data['isUsed'] as bool,
      status: data['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'userId': userId,
      'projectId': projectId,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'isUsed': isUsed,
      'status': status,
    };
  }

  MagicLink toDomain() {
    return MagicLink(
      id: id,
      url: url,
      userId: UserId.fromUniqueString(userId),
      projectId: projectId,
      createdAt: createdAt.toDate(),
      expiresAt: expiresAt?.toDate(),
      isUsed: isUsed,
      status: statusFromString(status),
    );
  }

  static MagicLinkStatus statusFromString(String status) {
    switch (status) {
      case 'valid':
        return MagicLinkStatus.valid;
      case 'expired':
        return MagicLinkStatus.expired;
      case 'used':
        return MagicLinkStatus.used;
      default:
        throw Exception('Unknown status: $status');
    }
  }

  static String statusToString(MagicLinkStatus status) {
    switch (status) {
      case MagicLinkStatus.valid:
        return 'valid';
      case MagicLinkStatus.expired:
        return 'expired';
      case MagicLinkStatus.used:
        return 'used';
    }
  }

  factory MagicLinkDto.fromDomain(MagicLink magicLink) {
    return MagicLinkDto(
      id: magicLink.id,
      url: magicLink.url,
      userId: magicLink.userId.value,
      projectId: magicLink.projectId,
      createdAt: Timestamp.fromDate(magicLink.createdAt),
      expiresAt:
          magicLink.expiresAt != null
              ? Timestamp.fromDate(magicLink.expiresAt!)
              : null,
      isUsed: magicLink.isUsed,
      status: statusToString(magicLink.status),
    );
  }
}
