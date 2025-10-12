import '../../../../core/domain/entity.dart';
import '../../../../core/entities/unique_id.dart';

/// Voice memo entity representing a recorded audio memo
class VoiceMemo extends Entity<VoiceMemoId> {
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;

  /// Future scalability: track if this memo was converted to a track version
  /// Null means not converted yet
  final String? convertedToTrackId;

  /// The user who created this voice memo. Null for legacy/app local only contexts.
  final UserId? createdBy;

  const VoiceMemo({
    required VoiceMemoId id,
    required this.title,
    required this.fileLocalPath,
    this.fileRemoteUrl,
    required this.duration,
    required this.recordedAt,
    this.convertedToTrackId,
    this.createdBy,
  }) : super(id);

  /// Factory method for creating new voice memos
  factory VoiceMemo.create({
    required String fileLocalPath,
    String? fileRemoteUrl,
    required Duration duration,
    UserId? createdBy,
  }) {
    final now = DateTime.now();
    return VoiceMemo(
      id: VoiceMemoId(),
      title: _generateTitle(now),
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      duration: duration,
      recordedAt: now,
      convertedToTrackId: null,
      createdBy: createdBy,
    );
  }

  /// Generate auto-title from timestamp
  static String _generateTitle(DateTime timestamp) {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return 'Voice Memo $month/$day/${timestamp.year} $hour:$minute';
  }

  VoiceMemo copyWith({
    VoiceMemoId? id,
    String? title,
    String? fileLocalPath,
    String? fileRemoteUrl,
    Duration? duration,
    DateTime? recordedAt,
    String? convertedToTrackId,
    UserId? createdBy,
  }) {
    return VoiceMemo(
      id: id ?? this.id,
      title: title ?? this.title,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileRemoteUrl: fileRemoteUrl ?? this.fileRemoteUrl,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      convertedToTrackId: convertedToTrackId ?? this.convertedToTrackId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
