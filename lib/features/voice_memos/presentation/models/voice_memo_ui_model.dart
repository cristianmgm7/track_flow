import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_memo.dart';

/// UI model wrapping VoiceMemo domain entity with unwrapped primitives
class VoiceMemoUiModel extends Equatable {
  final VoiceMemo memo;

  // Unwrapped primitives
  final String id;
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;
  final String? convertedToTrackId;
  final String? createdBy;

  // UI-specific computed fields
  final String formattedDuration;
  final String formattedDate;
  final bool isConverted;

  const VoiceMemoUiModel({
    required this.memo,
    required this.id,
    required this.title,
    required this.fileLocalPath,
    this.fileRemoteUrl,
    required this.duration,
    required this.recordedAt,
    this.convertedToTrackId,
    this.createdBy,
    required this.formattedDuration,
    required this.formattedDate,
    required this.isConverted,
  });

  factory VoiceMemoUiModel.fromDomain(VoiceMemo memo) {
    return VoiceMemoUiModel(
      memo: memo,
      id: memo.id.value,
      title: memo.title,
      fileLocalPath: memo.fileLocalPath,
      fileRemoteUrl: memo.fileRemoteUrl,
      duration: memo.duration,
      recordedAt: memo.recordedAt,
      convertedToTrackId: memo.convertedToTrackId,
      createdBy: memo.createdBy?.value,
      formattedDuration: _formatDuration(memo.duration),
      formattedDate: _formatDate(memo.recordedAt),
      isConverted: memo.convertedToTrackId != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        fileLocalPath,
        fileRemoteUrl,
        duration,
        recordedAt,
        convertedToTrackId,
        createdBy,
        formattedDuration,
        formattedDate,
        isConverted,
      ];
}
