import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Data Transfer Object for Notification
/// Used for serialization/deserialization between domain and data layers
class NotificationDto {
  final String id;
  final String recipientUserId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime timestamp;

  // Sync metadata fields for offline-first functionality
  final int version;
  final DateTime? lastModified;

  const NotificationDto({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.body,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.timestamp,
    // Sync metadata
    this.version = 1,
    this.lastModified,
  });

  static const String collection = 'notifications';

  /// Convert domain entity to DTO
  factory NotificationDto.fromDomain(Notification notification) {
    return NotificationDto(
      id: notification.id.value,
      recipientUserId: notification.recipientUserId.value,
      title: notification.title,
      body: notification.body,
      type: notification.type.name,
      payload: notification.payload,
      isRead: notification.isRead,
      timestamp: notification.timestamp,
      // Sync metadata
      version: 1, // Initial version for new notifications
      lastModified: notification.timestamp,
    );
  }

  /// Convert DTO to domain entity
  Notification toDomain() {
    return Notification(
      id: NotificationId.fromUniqueString(id),
      recipientUserId: UserId.fromUniqueString(recipientUserId),
      title: title,
      body: body,
      type: NotificationType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => NotificationType.systemMessage,
      ),
      payload: payload,
      isRead: isRead,
      timestamp: timestamp,
    );
  }

  /// Create from Firestore JSON
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTimestamp;
    if (json['timestamp'] is Timestamp) {
      parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      parsedTimestamp = DateTime.tryParse(json['timestamp'] as String);
    }

    DateTime? parsedLastModified;
    if (json['lastModified'] is Timestamp) {
      parsedLastModified = (json['lastModified'] as Timestamp).toDate();
    } else if (json['lastModified'] is String) {
      parsedLastModified = DateTime.tryParse(json['lastModified'] as String);
    }

    return NotificationDto(
      id: json['id'] as String? ?? '',
      recipientUserId: json['recipientUserId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'systemMessage',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      isRead: json['isRead'] as bool? ?? false,
      timestamp: parsedTimestamp ?? DateTime.now(),
      // Sync metadata
      version: json['version'] as int? ?? 1,
      lastModified: parsedLastModified,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      // Sync metadata
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  NotificationDto copyWith({
    String? id,
    String? recipientUserId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? payload,
    bool? isRead,
    DateTime? timestamp,
    int? version,
    DateTime? lastModified,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationDto &&
        other.id == id &&
        other.recipientUserId == recipientUserId &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.payload == payload &&
        other.isRead == isRead &&
        other.timestamp == timestamp &&
        other.version == version &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      recipientUserId,
      title,
      body,
      type,
      payload,
      isRead,
      timestamp,
      version,
      lastModified,
    );
  }

  @override
  String toString() {
    return 'NotificationDto(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}
