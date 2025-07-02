import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class MagicLink extends Entity<MagicLinkId> {
  final String url;
  final UserId userId; // --> sender
  final String projectId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final MagicLinkStatus status;

  const MagicLink({
    required MagicLinkId id,
    required this.url,
    required this.userId,
    required this.projectId,
    required this.createdAt,
    this.expiresAt,
    required this.isUsed,
    required this.status,
  }) : super(id);

}

enum MagicLinkStatus { valid, expired, used }
