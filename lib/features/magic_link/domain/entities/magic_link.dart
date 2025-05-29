import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class MagicLink extends Equatable {
  final String id;
  final String url;
  final UserId userId; // --> sender
  final String projectId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final MagicLinkStatus status;

  const MagicLink({
    required this.id,
    required this.url,
    required this.userId,
    required this.projectId,
    required this.createdAt,
    this.expiresAt,
    required this.isUsed,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    url,
    userId,
    createdAt,
    expiresAt,
    isUsed,
    status,
  ];
}

enum MagicLinkStatus { valid, expired, used }
